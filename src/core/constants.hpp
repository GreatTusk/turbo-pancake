#pragma once

#include <cstdint>
#include <string>

namespace tp::inline constants
{
    namespace name
    {
        namespace fan
        {
            constexpr inline auto sfx_player{ "SFX/AudioStreamPlayer2D" };
        }

        namespace trampoline
        {
            constexpr inline auto area2d{ "Area2D" };
            constexpr inline auto sprite{ "AnimatedSprite2D" };
            constexpr inline auto sfx_player{ "SFX/AudioStreamPlayer2D" };

            namespace animation
            {
                constexpr inline auto launch{ "launch" };
            }
        }

        namespace ui
        {
            constexpr inline auto score_label{ "../../CanvasLayer/Score" };
        }

        namespace player
        {
            namespace animations
            {
                constexpr inline auto double_jump{ "double_jump" };
                constexpr inline auto jump{ "jump" };
                constexpr inline auto wall_jump{ "wall_jump" };
                constexpr inline auto disappearing{ "disappearing" };
                constexpr inline auto appearing{ "appearing" };
                constexpr inline auto idle{ "idle" };
                constexpr inline auto run{ "run" };
                constexpr inline auto fall{ "fall" };
            }

            namespace nodes
            {
                constexpr inline auto main{ "../../Main" };
                constexpr inline auto world_border{ "WorldBorder" };
                constexpr inline auto jump_cooldown{ "Timers/JumpCooldownTimer" };
                constexpr inline auto left_ray{ "RayCastLeft" };
                constexpr inline auto right_ray{ "RayCastRight" };
                constexpr inline auto down_ray_1{ "RayCastDown1" };
                constexpr inline auto down_ray_2{ "RayCastDown2" };
                constexpr inline auto collision_shape{ "CollisionShape2D" };
                constexpr inline auto animated_sprites{ "AnimatedSprite2D" };
                constexpr inline auto animation_label{ "CanvasLayer/Control/Animation" };
                constexpr inline auto velocity_label{ "CanvasLayer/Control/Velocity" };
                constexpr inline auto state_label{ "CanvasLayer/Control/State" };
                constexpr inline auto die_sfx{ "VoiceLines/Die/Die_1" };
                constexpr inline auto find_sfx{ "VoiceLines/Find/Find_1" };
                constexpr inline auto jump_sfx{ "VoiceLines/Jump/Jump_1" };
                constexpr inline auto landing_sfx{ "VoiceLines/FallToFloor/Landing_1" };
                constexpr inline auto respawn_sfx{ "VoiceLines/Respawn/Respawn_1" };
            }

            namespace signals
            {
                constexpr inline auto world_border{ "_on_world_border_entered" };
                constexpr inline auto respawn_finished{ "_on_respawn_animation_finished" };
                constexpr inline auto dying_sfx_finished{ "_on_dying_sfx_finished" };
                constexpr inline auto respawn{ "_on_respawn" };
            }
        }

    }

    namespace event
    {
        constexpr inline auto position_changed{ "position_changed" };
        constexpr inline auto entered_area{ "entered_area" };
        constexpr inline auto exited_area{ "exited_area" };
        constexpr inline auto body_entered{ "_on_area_2d_body_entered" };
        constexpr inline auto body_exited{ "_on_area_2d_body_exited" };
        constexpr inline auto animation_finished{ "_on_animation_finished" };
        constexpr inline auto fruit_collected{ "fruit_score_changed" };
        constexpr inline auto fruit_collected_player{ "fruit_collected" };
        constexpr inline auto fan_colliding{ "fan_colliding" };
        constexpr inline auto on_trampoline{ "on_trampoline" };

    }

    enum class LayerID : uint32_t {
        Player = 0x00000001,
        NPCs = 0x00000002,
        Projectiles = 0x00000004,
        Walls = 0x00000008,
        DamageZones = 0x00000010,
        DeathZones = 0x00000020,
        PhysicsObjects = 0x00000040,
        Layer08 = 0x00000080,
        Layer09 = 0x00000100,
        Layer10 = 0x00000200,
        Layer11 = 0x00000400,
        Layer12 = 0x00000800,
        Layer13 = 0x00001000,
        Layer14 = 0x00002000,
        Layer15 = 0x00004000,
        Layer16 = 0x00008000,
    };

    namespace path

    {
        namespace scene
        {
            constexpr inline auto Level1{ "res://scenes/levels/level1.tscn" };
            constexpr inline auto Player{ "res://scenes/characters/player.tscn" };
            constexpr inline auto Enemy{ "res://scenes/characters/enemy.tscn" };
            constexpr inline auto Bullet{ "res://scenes/projectiles/bullet.tscn" };
        }

        namespace ui
        {
            constexpr inline auto MainDialog{ "res://scenes/ui/main_dialog.tscn" };
        }
    }
}
