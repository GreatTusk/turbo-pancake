#pragma once

#include <godot_cpp/classes/os.hpp>

namespace tp::inline utils
{
    struct os
    {
        static godot::OS* get()
        {
            return godot::OS::get_singleton();
        }
    };
}
