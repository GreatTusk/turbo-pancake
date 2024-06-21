//
// Created by F776 on 09-06-2024.
//

#include <random>

#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/variant/string.hpp>

#include "core/constants.hpp"
#include "fruit.h"
#include "util/conversions.hpp"
#include "util/engine.hpp"

namespace tp
{
    void Fruit::connect_signal()
    {
        // This is necessary to connect the built-in signal "body_entered" from the Area2D to this node
        area_2d->connect("body_entered", godot::Callable(this, event::body_entered));
        area_2d->connect("body_exited", godot::Callable(this, event::body_exited));
        sprite_2d->connect("animation_finished", godot::Callable(this, event::animation_finished));
    }

    void Fruit::_on_area_2d_body_entered(const godot::CharacterBody2D* body) const
    {
        // Play a random voice line
        godot::AudioStreamPlayer* voice_line = body->get_node<godot::AudioStreamPlayer>(
            name::character::voice_lines::find);
        voice_line->play();

        // Update the score label
        score_label->set_text(godot::String::num(score_label->get_text().to_int() + 100));

        // Play the collected animation
        sprite_2d->play("collected");
    }

    void Fruit::_ready()
    {
        if (engine::editor_active())
            return;
        area_2d = this->get_node<godot::Area2D>(name::trampoline::area2d);
        sprite_2d = this->get_node<godot::AnimatedSprite2D>(name::trampoline::sprite);
        score_label = this->get_node<godot::Label>(name::ui::score_label);

        sprite_2d->play(fruit);
        this->connect_signal();
    }

    void Fruit::_on_animation_finished()
    {
        queue_free();
    }

    void Fruit::set_fruit(const godot::String& p_fruit)
    {
        fruit = p_fruit;
    }

    godot::String Fruit::get_fruit()
    {
        return fruit;
    }

    void Fruit::_bind_methods()
    {
        // This is also needed to connect the signal
        godot::ClassDB::bind_method(godot::D_METHOD(event::body_entered, "body"),
                                    &Fruit::_on_area_2d_body_entered);
        godot::ClassDB::bind_method(godot::D_METHOD(event::animation_finished),
                                    &Fruit::_on_animation_finished);
        godot::ClassDB::bind_method(godot::D_METHOD("set_fruit", "fruit"), &Fruit::set_fruit);
        godot::ClassDB::bind_method(godot::D_METHOD("get_fruit"), &Fruit::get_fruit);
        godot::ClassDB::add_property("Fruit",
                                     godot::PropertyInfo(godot::Variant::STRING_NAME, "fruit"),
                                     "set_fruit", "get_fruit");
    }
}
