#pragma once

#include <cstdint>

namespace tp::inline constants
{
    namespace name
    {
        namespace fan
        {
            constexpr auto sfx_player{ "SFX/AudioStreamPlayer2D" };
        }

        namespace trampoline
        {
            constexpr auto area2d{ "Area2D" };
            constexpr auto sprite{ "AnimatedSprite2D" };
            constexpr auto sfx_player{ "SFX/AudioStreamPlayer2D" };

            namespace animation
            {
                constexpr auto launch{ "launch" };
            }
        }

        namespace ui
        {
            constexpr auto score_label{ "../../CanvasLayer/Score" };
        }

        namespace player
        {
            namespace animations
            {
                constexpr auto double_jump{ "double_jump" };
                constexpr auto jump{ "jump" };
                constexpr auto wall_jump{ "wall_jump" };
                constexpr auto disappearing{ "disappearing" };
                constexpr auto appearing{ "appearing" };
                constexpr auto idle{ "idle" };
                constexpr auto run{ "run" };
                constexpr auto fall{ "fall" };
            }

            namespace nodes
            {
                constexpr auto main{ "../../Main" };
                constexpr auto world_border{ "WorldBorder" };
                constexpr auto jump_cooldown{ "Timers/JumpCooldownTimer" };
                constexpr auto left_ray{ "RayCastLeft" };
                constexpr auto right_ray{ "RayCastRight" };
                constexpr auto down_ray_1{ "RayCastDown1" };
                constexpr auto down_ray_2{ "RayCastDown2" };
                constexpr auto collision_shape{ "CollisionShape2D" };
                constexpr auto animated_sprites{ "AnimatedSprite2D" };
                constexpr auto animation_label{ "CanvasLayer/Control/Animation" };
                constexpr auto velocity_label{ "CanvasLayer/Control/Velocity" };
                constexpr auto state_label{ "CanvasLayer/Control/State" };
                constexpr auto die_sfx{ "VoiceLines/Die/Die_1" };
                constexpr auto find_sfx{ "VoiceLines/Find/Find_1" };
                constexpr auto jump_sfx{ "VoiceLines/Jump/Jump_1" };
                constexpr auto landing_sfx{ "VoiceLines/FallToFloor/Landing_1" };
                constexpr auto respawn_sfx{ "VoiceLines/Respawn/Respawn_1" };
            }

            namespace signals
            {
                constexpr auto world_border{ "_on_world_border_entered" };
                constexpr auto respawn_finished{ "_on_respawn_animation_finished" };
                constexpr auto dying_sfx_finished{ "_on_dying_sfx_finished" };
                constexpr auto respawn{ "_on_respawn" };
            }
        }

    }

    namespace event
    {
        constexpr auto position_changed{ "position_changed" };
        constexpr auto entered_area{ "entered_area" };
        constexpr auto exited_area{ "exited_area" };
        constexpr auto body_entered{ "_on_area_2d_body_entered" };
        constexpr auto body_exited{ "_on_area_2d_body_exited" };
        constexpr auto animation_finished{ "_on_animation_finished" };
        constexpr auto fruit_collected{ "fruit_score_changed" };
        constexpr auto fruit_collected_player{ "fruit_collected" };
        constexpr auto fan_colliding{ "fan_collided" };
        constexpr auto on_trampoline{ "jumped_on" };

    }

    namespace path
    {
        namespace scene
        {
            constexpr auto Level1{ "res://scenes/levels/level1.tscn" };
            constexpr auto Player{ "res://scenes/characters/player.tscn" };
            constexpr auto Enemy{ "res://scenes/characters/enemy.tscn" };
            constexpr auto Bullet{ "res://scenes/projectiles/bullet.tscn" };
        }

        namespace ui
        {
            constexpr auto MainDialog{ "res://scenes/ui/main_dialog.tscn" };
        }
    }
}