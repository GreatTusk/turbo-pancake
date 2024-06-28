//
// Created by F776 on 09-06-2024.
//

#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/variant/string.hpp>

#include "core/attributes.hpp"
#include "core/constants.hpp"
#include "fruit.h"
#include "util/bind.hpp"
#include "util/engine.hpp"

namespace tp
{

    void Fruit::_ready()
    {
        if (engine::editor_active())
            return;

        auto* area_2d = this->get_node<godot::Area2D>(name::trampoline::area2d);
        area_2d->connect("body_entered", godot::Callable(this, event::body_entered));
        area_2d->connect("body_exited", godot::Callable(this, event::body_exited));

        // Getting pointers to external nodes to connect signals
        auto* score_label = this->get_node<godot::Label>(name::ui::score_label);
        this->connect(event::fruit_collected, godot::Callable(score_label, "_on_fruit_collected"));
        auto* player = this->get_node<godot::CharacterBody2D>("../../../Main/Player");
        this->connect(event::fruit_collected_player, godot::Callable(player, "_on_fruit_collected"));

        // Sprite2D is used on methods, so its pointer is stored in the class for easy access
        sprite_2d = this->get_node<godot::AnimatedSprite2D>(name::trampoline::sprite);
        // runtime_assert(sprite_2d != nullptr);
        sprite_2d->connect("animation_finished", godot::Callable(this, event::animation_finished));
        sprite_2d->play(fruit);
    }

    [[signal_slot]]
    void Fruit::_on_area_2d_body_entered(const godot::CharacterBody2D* body)
    {
        // Notify the player
        this->emit_signal(event::fruit_collected_player);
        // Update the score label
        this->emit_signal(event::fruit_collected, fruit);
        // Play the collected animation
        sprite_2d->play("collected");
    }

    [[signal_slot]]
    void Fruit::_on_animation_finished()
    {
        queue_free();
    }

    [[property]]
    void Fruit::set_fruit(const godot::StringName& p_fruit)
    {
        fruit = p_fruit;
    }

    [[property]]
    godot::StringName Fruit::get_fruit()
    {
        return fruit;
    }

    void Fruit::_bind_methods()
    {
        // Register getter and setters to expose the enum to the editor
        godot::ClassDB::bind_method(godot::D_METHOD("set_fruit", "fruit"), &Fruit::set_fruit);
        godot::ClassDB::bind_method(godot::D_METHOD("get_fruit"), &Fruit::get_fruit);
        ADD_PROPERTY(
            godot::PropertyInfo(godot::Variant::STRING_NAME, "fruit", godot::PROPERTY_HINT_ENUM,
                                "Apple,Banana,Cherry,Kiwi,Melon,Orange,Pineapple,Strawberry"),
            "set_fruit", "get_fruit");
        // This is also needed to connect the signal
        godot::ClassDB::bind_method(godot::D_METHOD(event::body_entered, "body"),
                                    &Fruit::_on_area_2d_body_entered);
        godot::ClassDB::bind_method(godot::D_METHOD(event::animation_finished),
                                    &Fruit::_on_animation_finished);

        signal_binding<Fruit, event::fruit_collected_player>::add();
        signal_binding<Fruit, event::fruit_collected>::add<godot::StringName>();
    }
}
