//
// Created by F776 on 08-06-2024.
//

#include "core/constants.hpp"
#include "trampoline.h"

namespace tp
{
    void Trampoline::_ready()
    {
        auto* area_2d = this->get_node<godot::Area2D>(name::trampoline::area2d);
        area_2d->connect("body_entered", godot::Callable(this, event::body_entered));

        auto* player = this->get_node<godot::CharacterBody2D>("../../../Main/Player");
        this->connect(event::on_trampoline, godot::Callable(player, "_on_trampoline_jump"));

        sprite_2d = this->get_node<godot::AnimatedSprite2D>(name::trampoline::sprite);
        sfx_player = this->get_node<godot::AudioStreamPlayer2D>(name::trampoline::sfx_player);
        // This is necessary to connect the built-in signal "body_entered" from the Area2D to this node
    }

    [[signal_slot]]
    void Trampoline::_on_area_2d_body_entered(godot::CharacterBody2D* body)
    {
        sprite_2d->play(name::trampoline::animation::launch);
        sfx_player->play();
        emit_signal(event::on_trampoline);
    }

    void Trampoline::_bind_methods()
    {
        // This is also needed to connect the signal
        godot::ClassDB::bind_method(godot::D_METHOD(event::body_entered, "body"),
                                    &Trampoline::_on_area_2d_body_entered);
        signal_binding<Trampoline, event::on_trampoline>::add();
    }
}
