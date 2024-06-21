//
// Created by F776 on 09-06-2024.
//

#ifndef FAN_H
#define FAN_H

#include <godot_cpp/classes/animated_sprite2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/audio_stream_player2d.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/node2d.hpp>

#include "util/bind.hpp"

namespace tp
{

    class Fan final : public godot::Node2D
    {
        GDCLASS(Fan, godot::Node2D)

    public:
        Fan() = default;
        ~Fan() override = default;

        void connect_signal();
        void _on_area_2d_body_entered(godot::CharacterBody2D* body);
        void _on_area_2d_body_exited(godot::CharacterBody2D* body);
        // Overriding from Node
        void _ready() override;
        void _process(double delta) override;

    protected:
        static void _bind_methods();

    private:
        // Pointers to the children of this node
        godot::Area2D* area_2d{ nullptr };
        godot::AnimatedSprite2D* sprite_2d{ nullptr };
        godot::AudioStreamPlayer2D* sfx_player{ nullptr };
        // Pointer to the character body that is colliding, if any
        godot::CharacterBody2D* collider{ nullptr };
    };

}

#endif  // FAN_H
