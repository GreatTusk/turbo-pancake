//
// Created by F776 on 20/06/2024.
//

#ifndef PLAYER_H
#define PLAYER_H

#include <godot_cpp/classes/animated_sprite2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/collision_shape2d.hpp>
#include <godot_cpp/classes/label.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ray_cast2d.hpp>
#include <godot_cpp/classes/timer.hpp>

#include "core/attributes.hpp"

namespace tp
{
    class Player : public godot::CharacterBody2D
    {
        GDCLASS(Player, godot::CharacterBody2D)
    private:
        static constexpr float JUMP_VEL = -200.0f;
        static constexpr float WALL_VEL = 120.0f;
        static constexpr float WALL_FRICTION = 0.1f;
        static constexpr float DOUBLE_JUMP_VEL = JUMP_VEL * 1.2f;
        static constexpr float MAX_SPEED_X = 200.0f;
        static constexpr double MAX_SPEED_Y = 900.0f;
        static constexpr float ACC = 400.0f;
        static constexpr float AIR_ACC_Y = 620.0f;
        static constexpr float GROUND_DEC = 900.0f;
        static constexpr float AIR_DEC_X = 450.0f;
        static constexpr float WALL_COLL_POS_R = 400.0f;
        static constexpr float WALL_COLL_POS_L = 410.0f;
        static constexpr float RAYC_COLL_POS_L = 45.0f;
        static constexpr float RAYC_COLL_POS_R = 40.0f;
        enum class States {
            GROUND,
            AIR,
            WALL
        };

        godot::Vector2 spawn_pos{ -24, 259 };
        // Control flow vars

        bool double_jump{ true };
        real_t double_jump_pos{};
        States current_state = States::GROUND;

        // Child nodes

        godot::Timer* jump_cooldown{ nullptr };
        godot::AnimatedSprite2D* animated_sprites{ nullptr };
        godot::RayCast2D* left_ray{ nullptr };
        godot::RayCast2D* right_ray{ nullptr };
        godot::RayCast2D* down_ray_1{ nullptr };
        godot::RayCast2D* down_ray_2{ nullptr };
        godot::CollisionShape2D* collision_shape{ nullptr };

        // SFX

        godot::AudioStreamPlayer* die_sfx{ nullptr };
        godot::AudioStreamPlayer* jump_sfx{ nullptr };
        godot::AudioStreamPlayer* landing_sfx{ nullptr };
        godot::AudioStreamPlayer* respawn_sfx{ nullptr };

        // External nodes

        godot::Node2D* main{ nullptr };

        // Debug

        godot::Label* animation_label{ nullptr };
        godot::Label* velocity_label{ nullptr };
        godot::Label* state_label{ nullptr };

    public:
        Player() = default;
        ~Player() override = default;
        // Overriding from
        void _ready() override;
        void _physics_process(double delta) override;
        // Player movement
        void ground_movement(double delta);
        void air_movement(double delta);
        void wall_movement(double delta);
        // State machine
        void exit_state(States prev_state, States new_state);
        void enter_state(States new_state);
        void change_state(States new_state);
        // Helper
        void die();
        void adjust_hitbox() const;
        static bool holding_x_dir();
        [[nodiscard]] bool changed_dir() const;
        [[nodiscard]] bool is_coll_wall() const;
        [[nodiscard]] bool is_on_ground() const;
        [[signal_slot]] void _on_world_border_entered(CharacterBody2D* player);
        [[signal_slot]] void _on_respawn();
        [[signal_slot]] void _on_dying_sfx_finished();
        [[signal_slot]] void _on_respawn_animation_finished();

        static const char* state_to_string(States state);

    protected:
        static void _bind_methods();
    };
}

#endif  // PLAYER_H
