#pragma once

#include <godot_cpp/classes/canvas_layer.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/node2d.hpp>

namespace tp
{
    class Main : public godot::Node2D
    {
        GDCLASS(Main, godot::Node);

    public:
        Main() = default;
        ~Main() override = default;

        void _ready() override;
        void set_player_pos(godot::Vector2 pos);
        godot::Vector2 get_player_pos() const;

    protected:
        static void _bind_methods()
        {
        }

    private:
        godot::Vector2 player_pos{ -24, 259 };
    };
}
