#include <godot_cpp/classes/window.hpp>

#include "core/assert.hpp"
#include "core/constants.hpp"
#include "main.hpp"
#include "util/conversions.hpp"
#include "util/engine.hpp"
#include "util/input.hpp"
#include "util/scene.hpp"

namespace tp
{

    void Main::_ready()
    {
    }

    void Main::set_player_pos(const godot::Vector2 pos)
    {
        player_pos = pos;
    }

    godot::Vector2 Main::get_player_pos() const
    {
        return player_pos;
    }

}
