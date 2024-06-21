//
// Created by F776 on 08-06-2024.
//

#ifndef TRAMPOLINE_H
#define TRAMPOLINE_H

#include <godot_cpp/classes/animated_sprite2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/audio_stream_player2d.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/node2d.hpp>

#include "util/bind.hpp"

namespace tp
{

    class Trampoline final : public godot::Node2D
    {
        GDCLASS(Trampoline, godot::Node2D)

    public:
        Trampoline() = default;
        ~Trampoline() override = default;

        void connect_signal();
        void _on_area_2d_body_entered(godot::CharacterBody2D* body) const;
        // Overriding from Node
        void _ready() override;

    protected:
        static void _bind_methods();

    private:
        // Pointers to the children of this node
        godot::Area2D* area_2d{ nullptr };
        godot::AnimatedSprite2D* sprite_2d{ nullptr };
        godot::AudioStreamPlayer2D* sfx_player{ nullptr };
    };

}
#endif  // TRAMPOLINE_H
