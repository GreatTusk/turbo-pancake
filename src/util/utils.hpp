#pragma once

#include "util/debug.hpp"
#include "util/io.hpp"

#include <concepts>

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/engine_debugger.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_map.hpp>
#include <godot_cpp/classes/main_loop.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/variant/string.hpp>

namespace rl
{
    namespace project
    {
        constexpr inline godot::String&& project_path(const godot::String& rel_path)
        {
            return std::move("res://" + rel_path);
        }

        constexpr inline godot::String&& user_data_path(const godot::String& rel_path)
        {
            return std::move("user://" + rel_path);
        }
    }

    namespace scene
    {
        template <typename TNode = godot::Node>
        inline godot::Node* edited_root(TNode* node)
        {
            godot::Node* edited_root{ node->get_tree()->get_edited_scene_root() };
            debug::assert(edited_root != nullptr);
            return edited_root;
        }
    }

    namespace resource
    {
        namespace loader
        {
            static inline godot::ResourceLoader* get()
            {
                return godot::ResourceLoader::get_singleton();
            }
        }

        namespace preload
        {
            template <typename TObj, typename TScene = godot::PackedScene>
                requires std::derived_from<TScene, godot::Resource> &&
                         std::convertible_to<TObj, godot::Node>
            struct scene
            {
                using scene_t = typename TScene;
                using object_t = typename TObj;

                scene(const char* const resource_path)
                {
                    godot::ResourceLoader* const resource_loader{ resource::loader::get() };
                    debug::assert(resource_loader != nullptr);
                    m_packed_resource = resource_loader->load(resource_path);
                }

                [[nodiscard]]
                inline auto instantiate() -> TObj*
                {
                    debug::assert(m_packed_resource.is_valid());
                    TObj* ret{ godot::Object::cast_to<TObj>(m_packed_resource->instantiate()) };
                    debug::assert(ret != nullptr);
                    return ret;
                }

                godot::Ref<TScene> m_packed_resource{};
            };
        }
    }
}

struct os
{
    static inline godot::OS* get()
    {
        return godot::OS::get_singleton();
    }
};

struct variant
{
    [[nodiscard]]
    const static inline std::string to_string(const godot::Variant& var)
    {
        return var.stringify().utf8().get_data();
    }
};

struct engine
{
    static inline godot::Engine* const get()
    {
        return godot::Engine::get_singleton();
    }

    static inline godot::MainLoop* const main_loop()
    {
        auto engine{ engine::get() };
        if (engine != nullptr) [[likely]]
            return engine->get_main_loop();
        return nullptr;
    }

    static inline godot::SceneTree* const scene_tree()
    {
        auto loop{ engine::main_loop() };
        if (loop != nullptr) [[likely]]
            return godot::Object::cast_to<godot::SceneTree>(loop);
        return nullptr;
    }

    static inline godot::Window* const root_window()
    {
        auto tree{ engine::scene_tree() };
        if (tree != nullptr) [[likely]]
            return tree->get_root();
        return nullptr;
    }

    static inline godot::Node* root_node()
    {
        return godot::Object::cast_to<godot::Node>(engine::root_window());
    }

    const static inline int32_t max_fps()
    {
        auto engine{ engine::get() };
        if (engine != nullptr) [[likely]]
            return engine->get_max_fps();

        rl::log::error("Failed to get max fps");
    }

    static inline void set_fps(const uint32_t fps)
    {
        auto engine{ engine::get() };
        if (engine != nullptr) [[likely]]
            return engine->set_max_fps(fps);

        rl::log::error("Failed to set max fps");
    }
};

struct editor
{
    const static inline bool active()
    {
        auto engine{ engine::get() };
        if (engine != nullptr) [[likely]]
            return engine->is_editor_hint();
        return false;
    }
};

struct game
{
    const static inline bool active()
    {
        return !editor::active();
    }
};
