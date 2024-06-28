//
// Created by F776 on 09-06-2024.
//


#include "core/constants.hpp"
#include "fan.h"
#include "godot_cpp/variant/utility_functions.hpp"
#include "util/engine.hpp"

namespace tp
{

    void Fan::_ready()
    {
        this->set_process(false);
        if (engine::editor_active())
            return;
        sfx_player = this->get_node<godot::AudioStreamPlayer2D>(name::fan::sfx_player);
        auto* area_2d = this->get_node<godot::Area2D>(name::trampoline::area2d);
        area_2d->connect("body_entered", godot::Callable(this, event::body_entered));
        area_2d->connect("body_exited", godot::Callable(this, event::body_exited));
        auto* player = this->get_node<godot::CharacterBody2D>("../../../Main/Player");
        runtime_assert(player != nullptr);
        this->connect(event::fan_colliding, godot::Callable(player, "_on_fan_collision"));
    }

    [[signal_slot]]
    void Fan::_on_area_2d_body_entered(godot::CharacterBody2D* body)
    {
        this->set_process(true);
    }

    [[signal_slot]]
    void Fan::_on_area_2d_body_exited(godot::CharacterBody2D* body)
    {
        this->set_process(false);
    }

    void Fan::_process(const double delta)
    {
        sfx_player->play();
        emit_signal(event::fan_colliding, delta);
    }

    void Fan::_bind_methods()
    {
        // This is also needed to connect the signal
        godot::ClassDB::bind_method(godot::D_METHOD(event::body_entered, "body"),
                                    &Fan::_on_area_2d_body_entered);
        godot::ClassDB::bind_method(godot::D_METHOD(event::body_exited, "body"),
                                    &Fan::_on_area_2d_body_exited);
        signal_binding<Fan, event::fan_colliding>::add<double>();
    }
}
