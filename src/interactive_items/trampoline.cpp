//
// Created by F776 on 08-06-2024.
//

#include "core/constants.hpp"
#include "trampoline.h"

namespace tp
{

    void Trampoline::connect_signal()
    {
        // This is necessary to connect the built-in signal "body_entered" from the Area2D to this node
        area_2d->connect("body_entered", godot::Callable(this, event::body_entered));
    }

    void Trampoline::_on_area_2d_body_entered(godot::CharacterBody2D* body) const
    {
        sprite_2d->play(name::trampoline::animation::launch);
        sfx_player->play();
        body->set_velocity({ body->get_velocity().x, body->get_velocity().y - 300 });
    }

    void Trampoline::_ready()
    {
        area_2d = this->get_node<godot::Area2D>(name::trampoline::area2d);
        sprite_2d = this->get_node<godot::AnimatedSprite2D>(name::trampoline::sprite);
        sfx_player = this->get_node<godot::AudioStreamPlayer2D>(name::trampoline::sfx_player);
        this->connect_signal();
    }

    void Trampoline::_bind_methods()
    {
        // This is also needed to connect the signal
        godot::ClassDB::bind_method(godot::D_METHOD(event::body_entered, "body"),
                                    &Trampoline::_on_area_2d_body_entered);
    }
}
