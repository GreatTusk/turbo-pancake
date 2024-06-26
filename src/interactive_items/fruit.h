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
        [[signal_slot]] void _on_area_2d_body_entered(const godot::CharacterBody2D* body);
        [[signal_slot]] void _on_animation_finished();

        // Overriding from Node
        void _ready() override;
        // Getters and setters
        [[property]] void set_fruit(const godot::StringName& p_fruit);
        [[property]] godot::StringName get_fruit();

    protected:
        static void _bind_methods();

    private:
        // Pointers to the children of this node
        godot::AnimatedSprite2D* sprite_2d{ nullptr };
        [[property]] godot::StringName fruit{ "Apple" };
    };

}
#endif  // FRUIT_H
