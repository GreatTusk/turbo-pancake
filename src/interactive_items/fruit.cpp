//
// Created by F776 on 09-06-2024.
//

#include <godot_cpp/classes/area2d.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include "core/attributes.hpp"
#include "core/constants.hpp"
#include "fruit.h"

namespace tp
{

    void Fruit::_ready()
    {
        auto* area_2d = this->get_node<godot::Area2D>(constants::name::fruit::area2d);
        area_2d->connect("body_entered", godot::Callable(this, constants::event::body_entered));

        // Sprite2D is used on methods, so its pointer is stored in the class for easy access
        sprite_2d = this->get_node<godot::AnimatedSprite2D>(constants::name::fruit::sprite);
        sprite_2d->connect("animation_finished",
                           godot::Callable(this, constants::event::animation_finished));

        const char* fruits[]{ "Apple", "Banana", "Cherry",    "Kiwi",
                              "Melon", "Orange", "Pineapple", "Strawberry" };
        sprite_2d->play({ fruits[godot::UtilityFunctions::randi_range(0, 7)] });
    }

    [[signal_slot]]
    void Fruit::_on_area_2d_body_entered(const godot::CharacterBody2D* body)
    {
        // Notify the player
        this->emit_signal(constants::event::fruit_collected_player);
        // Update the score label
        this->emit_signal(constants::event::fruit_collected, 100);
        // Play the collected animation
        sprite_2d->play("collected");
    }

    [[signal_slot]]
    void Fruit::_on_animation_finished()
    {
        queue_free();
    }

    // [[property]]
    // void Fruit::set_fruit(const godot::StringName& p_fruit)
    // {
    //     // To be executed only once
    //     fruit = p_fruit;
    //     if (sprite_2d) sprite_2d->play(fruit);
    // }
    //
    // [[property]]
    // godot::StringName Fruit::get_fruit()
    // {
    //     return fruit;
    // }

    void Fruit::_bind_methods()
    {
        // Register getter and setters to expose the enum to the editor
        // godot::ClassDB::bind_method(godot::D_METHOD("set_fruit", "fruit"), &Fruit::set_fruit);
        // godot::ClassDB::bind_method(godot::D_METHOD("get_fruit"), &Fruit::get_fruit);
        // ADD_PROPERTY(
        //     godot::PropertyInfo(godot::Variant::STRING_NAME, "fruit", godot::PROPERTY_HINT_ENUM,
        //                         "Apple,Banana,Cherry,Kiwi,Melon,Orange,Pineapple,Strawberry"),
        //     "set_fruit", "get_fruit");
        // Connect signals
        godot::ClassDB::bind_method(godot::D_METHOD(constants::event::body_entered, "body"),
                                    &Fruit::_on_area_2d_body_entered);
        godot::ClassDB::bind_method(godot::D_METHOD(constants::event::animation_finished),
                                    &Fruit::_on_animation_finished);

        ADD_SIGNAL(godot::MethodInfo(constants::event::fruit_collected_player));
        ADD_SIGNAL(godot::MethodInfo(constants::event::fruit_collected,
                                     godot::PropertyInfo(godot::Variant::INT, "score")));
    }
}
