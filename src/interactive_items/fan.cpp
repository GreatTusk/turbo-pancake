//
// Created by F776 on 09-06-2024.
//

#include "core/constants.hpp"
#include "fan.h"

namespace tp
{
    void Fan::connect_signal()
    {
        // This is necessary to connect the built-in signal "body_entered" from the Area2D to this node
        area_2d->connect("body_entered", godot::Callable(this, event::body_entered));
        area_2d->connect("body_exited", godot::Callable(this, event::body_exited));
    }

    void Fan::_on_area_2d_body_entered(godot::CharacterBody2D* body)
    {
        collider = body;
    }

    void Fan::_on_area_2d_body_exited(godot::CharacterBody2D* body)
    {
        collider = nullptr;
    }

    void Fan::_ready()
    {
        area_2d = this->get_node<godot::Area2D>(name::trampoline::area2d);
        sprite_2d = this->get_node<godot::AnimatedSprite2D>(name::trampoline::sprite);
        sfx_player = this->get_node<godot::AudioStreamPlayer2D>(name::trampoline::sfx_player);
        this->connect_signal();
    }

    void Fan::_process(const double delta)
    {
        if (collider != nullptr)
        {
            collider->set_velocity(
                { collider->get_velocity().x,
                  collider->get_velocity().y - static_cast<real_t>(500.0 * delta) });
        }
    }

    void Fan::_bind_methods()
    {
        // This is also needed to connect the signal
        godot::ClassDB::bind_method(godot::D_METHOD(event::body_entered, "body"),
                                    &Fan::_on_area_2d_body_entered);
        godot::ClassDB::bind_method(godot::D_METHOD(event::body_exited, "body"),
                                    &Fan::_on_area_2d_body_exited);
    }
}
