#include <type_traits>

#include <gdextension_interface.h>

#include "api/extension_interface.hpp"
#include "interactive_items/fruit.h"
#include "util/engine.hpp"

namespace tp
{

    void initialize_static_objects()
    {
    }

    void teardown_static_objects()
    {
    }

    void initialize_extension_module(godot::ModuleInitializationLevel init_level)
    {
        if (init_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
            return;
        // Interactive Items
        // godot::ClassDB::register_class<Trampoline>();
        // godot::ClassDB::register_class<Fan>();
        godot::ClassDB::register_class<Fruit>();
        // godot::ClassDB::register_class<Player>();

        initialize_static_objects();
    }

    void uninitialize_extension_module(const godot::ModuleInitializationLevel init_level)
    {
        if (init_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
            return;

        teardown_static_objects();
    }

    extern "C"
    {
        GDExtensionBool GDE_EXPORT extension_library_init(
            const GDExtensionInterfaceGetProcAddress addr, const GDExtensionClassLibraryPtr lib,
            GDExtensionInitialization* init)
        {
            constexpr auto init_level = godot::MODULE_INITIALIZATION_LEVEL_SCENE;
            const godot::GDExtensionBinding::InitObject init_obj(addr, lib, init);

            init_obj.register_initializer(initialize_extension_module);
            init_obj.register_terminator(uninitialize_extension_module);
            init_obj.set_minimum_library_initialization_level(init_level);

            return init_obj.init();
        }
    }
}
