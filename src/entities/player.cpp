//
// Created by F776 on 20/06/2024.
//

#include "core/constants.hpp"
#include "godot_cpp/classes/input.hpp"
#include "godot_cpp/classes/os.hpp"
#include "godot_cpp/variant/utility_functions.hpp"
#include "main.hpp"
#include "player.h"
#include "util/engine.hpp"
#include "util/input.hpp"

namespace tp
{
    void Player::_ready()
    {
        set_physics_process(false);
        if (engine::editor_active())
            return;
        main = get_node<Node2D>("../../Main");
        this->set_position(spawn_pos);
        animated_sprites = this->get_node<godot::AnimatedSprite2D>("AnimatedSprite2D");
        animation_label = main->get_node<godot::Label>("CanvasLayer/Control/Animation");
        velocity_label = main->get_node<godot::Label>("CanvasLayer/Control/Velocity");
        state_label = main->get_node<godot::Label>("CanvasLayer/Control/State");

        // Initialize child nodes
        jump_cooldown = this->get_node<godot::Timer>("Timers/JumpCooldownTimer");
        left_ray = this->get_node<godot::RayCast2D>("RayCastLeft");
        right_ray = this->get_node<godot::RayCast2D>("RayCastRight");
        down_ray_1 = this->get_node<godot::RayCast2D>("RayCastDown1");
        down_ray_2 = this->get_node<godot::RayCast2D>("RayCastDown2");
        collision_shape = this->get_node<godot::CollisionShape2D>("CollisionShape2D");

        die_sfx = this->get_node<godot::AudioStreamPlayer>("VoiceLines/Die/Die_1");
        jump_sfx = this->get_node<godot::AudioStreamPlayer>("VoiceLines/Jump/Jump_1");
        landing_sfx = this->get_node<godot::AudioStreamPlayer>("VoiceLines/FallToFloor/Landing_1");
        respawn_sfx = this->get_node<godot::AudioStreamPlayer>("VoiceLines/Respawn/Respawn_1");

        godot::Area2D* world_border = main->get_node<godot::Area2D>("WorldBorder");
        world_border->connect("body_entered", godot::Callable(this, "_on_world_border_entered"));
        animated_sprites->connect("animation_finished",
                                  godot::Callable(this, "_on_respawn_animation_finished"));
        die_sfx->connect("finished", godot::Callable(this, "_on_dying_sfx_finished"));
        this->connect("respawn", godot::Callable(this, "_on_respawn"));
        set_physics_process(true);
    }

    void Player::_physics_process(const double delta)
    {
        switch (current_state)
        {
            case States::GROUND:
                if (!is_on_ground())
                    change_state(States::AIR);
                ground_movement(delta);
                break;
            case States::AIR:
                if (is_on_ground())
                    change_state(States::GROUND);
                else if (is_coll_wall() & holding_x_dir() & !changed_dir())
                    change_state(States::WALL);
                air_movement(delta);
                break;
            case States::WALL:
                if (!holding_x_dir() || !is_coll_wall() || changed_dir())
                    change_state(States::AIR);
                else if (is_on_ground())
                    change_state(States::GROUND);
                wall_movement(delta);
                break;
        }
        animation_label->set_text(animated_sprites->get_animation());
        velocity_label->set_text(this->get_velocity());
        state_label->set_text(state_to_string(current_state));
        this->move_and_slide();
    }

    void Player::ground_movement(const double delta)
    {
        if (input::get()->is_action_just_pressed(input::action::jump))
        {
            jump_sfx->play();
            this->set_velocity({ get_velocity().x, JUMP_VEL });
            return;
        }
        const double dir = input::get()->get_axis(input::action::move_left,
                                                  input::action::move_right);

        godot::Vector2 vel = this->get_velocity();
        if (dir == 0.0)
        {
            animated_sprites->play("idle");
            vel.x = static_cast<real_t>(
                godot::Math::move_toward(static_cast<double>(vel.x), 0.0, GROUND_DEC * delta));
        }
        else
        {
            animated_sprites->play("run");
            animated_sprites->set_flip_h(dir < 0);
            vel.x = static_cast<real_t>(godot::Math::move_toward(static_cast<double>(vel.x),
                                                                 dir * MAX_SPEED_X, ACC * delta));
        }
        set_velocity(vel);
    }

    void Player::air_movement(const double delta)
    {
        godot::Vector2 vel = this->get_velocity();
        // Adjust the hitbox
        adjust_hitbox();

        // Apply gravity
        vel.y = static_cast<real_t>(
            godot::Math::move_toward(static_cast<double>(vel.y), MAX_SPEED_Y, AIR_ACC_Y * delta));

        // Handle double jumping
        if (input::get()->is_action_just_pressed(input::action::jump) && double_jump)
        {
            animated_sprites->play("double_jump");
            jump_sfx->play();
            vel.y = DOUBLE_JUMP_VEL;
            double_jump = false;
            double_jump_pos = this->get_position().y;
        }
        else if (vel.y < 0.0 && animated_sprites->get_animation() != godot::StringName("double_jump"))
        {
            animated_sprites->play("jump");
        }
        else if (vel.y > 0.0 &&
                 (animated_sprites->get_animation() != godot::StringName("double_jump") ||
                  get_position().y >= double_jump_pos))
        {
            animated_sprites->play("fall");
        }

        // Horizontal movement
        if (const double dir = input::get()->get_axis(input::action::move_left,
                                                      input::action::move_right);
            dir == 0.0)
        {
            vel.x = static_cast<real_t>(
                godot::Math::move_toward(static_cast<double>(vel.x), 0.0, AIR_DEC_X * delta));
        }
        else
        {
            animated_sprites->set_flip_h(dir < 0);
            vel.x = static_cast<real_t>(godot::Math::move_toward(static_cast<double>(vel.x),
                                                                 dir * MAX_SPEED_X, ACC * delta));
        }

        // Set the new velocity
        set_velocity(vel);
    }

    void Player::wall_movement(const double delta)
    {
        if (input::get()->is_action_just_pressed(input::action::jump))
        {
            animated_sprites->play("jump");
            jump_cooldown->start();
            jump_sfx->play();
            this->set_velocity(
                { static_cast<real_t>(WALL_VEL * (animated_sprites->is_flipped_h() ? 1.0 : -1.0)),
                  JUMP_VEL });
            change_state(States::AIR);
            return;
        }

        godot::Vector2 vel = this->get_velocity();
        animated_sprites->play("wall_jump");
        vel.y = static_cast<real_t>(godot::Math::move_toward(
            static_cast<double>(vel.y), MAX_SPEED_Y, AIR_ACC_Y * delta * WALL_FRICTION));
        this->set_velocity(vel);
    }

    void Player::exit_state(const States prev_state, const States new_state)
    {
        switch (prev_state)
        {
            case States::AIR:
                double_jump = true;
                if (new_state == States::GROUND)
                    landing_sfx->play();
                break;
            default:
                break;
        }
    }

    void Player::enter_state(const States new_state)
    {
        switch (new_state)
        {
            case States::WALL:
                set_velocity({ get_velocity().x, 0.0 });
            default:
                break;
        }
        current_state = new_state;
    }

    void Player::change_state(const States new_state)
    {
        exit_state(current_state, new_state);
        enter_state(new_state);
    }

    void Player::die()
    {
        animated_sprites->play("disappearing");
        this->set_physics_process(false);
        die_sfx->play();
    }

    bool Player::holding_x_dir()
    {
        const godot::Input* input = input::get();
        return input->is_action_pressed(input::action::move_left) ||
               input->is_action_pressed(input::action::move_right);
    }

    bool Player::changed_dir() const
    {
        const godot::Input* input = input::get();
        const bool is_flipped_h = animated_sprites->is_flipped_h();
        return (input->is_action_pressed(input::action::move_left) && !is_flipped_h) ||
               (input->is_action_pressed(input::action::move_right) && is_flipped_h);
    }

    void Player::adjust_hitbox() const
    {
        collision_shape->set_position(
            { animated_sprites->is_flipped_h() ? WALL_COLL_POS_L : WALL_COLL_POS_R,
              collision_shape->get_position().y });

        right_ray->set_target_position(
            { animated_sprites->is_flipped_h() ? RAYC_COLL_POS_L : RAYC_COLL_POS_R,
              right_ray->get_target_position().y });

        // Ensure left_ray matches the right_ray's x position
        left_ray->set_target_position(right_ray->get_target_position());
    }

    bool Player::is_coll_wall() const
    {
        return (animated_sprites->is_flipped_h() ? left_ray : right_ray)->is_colliding();
    }

    bool Player::is_on_ground() const
    {
        return down_ray_1->is_colliding() || down_ray_2->is_colliding();
    }

    void Player::_on_world_border_entered(CharacterBody2D* player)
    {
        die();
    }

    void Player::_on_respawn()
    {
        set_position(spawn_pos);
        animated_sprites->play("appearing");
        respawn_sfx->play();
    }

    void Player::_on_dying_sfx_finished()
    {
        emit_signal("respawn");
    }

    void Player::_on_respawn_animation_finished()
    {
        if (animated_sprites->get_animation() == godot::StringName("appearing"))
        {
            change_state(States::GROUND);
            set_physics_process(true);
        }
    }

    godot::Vector2 Player::get_respawn_pos() const
    {
        return spawn_pos;
    }

    void Player::set_respawn_pos(const godot::Vector2 pos)
    {
        spawn_pos = pos;
    }

    const char* Player::state_to_string(const States state)
    {
        switch (state)
        {
            case States::AIR:
                return "AIR";
            case States::WALL:
                return "WALL";
            case States::GROUND:
                return "GROUND";
            default:
                return "Unknown";
        }
    }

    void Player::_bind_methods()
    {
        // Bind signals from child nodes
        godot::ClassDB::bind_method(godot::D_METHOD("_on_dying_sfx_finished"),
                                    &Player::_on_dying_sfx_finished);
        godot::ClassDB::bind_method(godot::D_METHOD("_on_respawn_animation_finished"),
                                    &Player::_on_respawn_animation_finished);
        // From external nodes
        godot::ClassDB::bind_method(godot::D_METHOD("_on_world_border_entered", "body"),
                                    &Player::_on_world_border_entered);
        godot::ClassDB::bind_method(godot::D_METHOD("die"), &Player::die);

        ADD_SIGNAL(godot::MethodInfo("respawn"));
        godot::ClassDB::bind_method(godot::D_METHOD("_on_respawn"), &Player::_on_respawn);
        godot::ClassDB::bind_method(godot::D_METHOD("set_respawn_pos", "pos"), &Player::set_respawn_pos);
    }
}
