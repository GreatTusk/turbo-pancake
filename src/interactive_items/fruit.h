//
// Created by F776 on 09-06-2024.
//

#ifndef FRUIT_H
#define FRUIT_H

#include <godot_cpp/classes/animated_sprite2d.hpp>
#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/label.hpp>
#include <godot_cpp/classes/node2d.hpp>

#include "core/attributes.hpp"

namespace tp
{

    class Fruit final : public godot::Node2D
    {
        GDCLASS(Fruit, godot::Node2D)

    public:
        Fruit() = default;
        ~Fruit() override = default;
        void connect_signal();
        [[signal_slot]] void _on_area_2d_body_entered(const godot::CharacterBody2D* body) const;
        // Overriding from Node
        void _ready() override;
        [[signal_slot]] void _on_animation_finished();

        // Getters and setters
        void set_fruit(const godot::String& p_fruit);
        godot::String get_fruit();

    protected:
        static void _bind_methods();

    private:
        // Pointers to the children of this node
        godot::Area2D* area_2d{ nullptr };
        godot::AnimatedSprite2D* sprite_2d{ nullptr };
        godot::Label* score_label{ nullptr };
        godot::String fruit{ "Apple" };
    };

}
#endif  // FRUIT_H
