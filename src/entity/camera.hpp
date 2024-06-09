#pragma once

#include <godot_cpp/classes/camera2d.hpp>

namespace rl
{
    class Camera : public godot::Camera2D
    {
        GDCLASS(Camera, godot::Camera2D);

    public:
        Camera();
        ~Camera() override = default;

    protected:
        static void _bind_methods()
        {
        }
    };
}
