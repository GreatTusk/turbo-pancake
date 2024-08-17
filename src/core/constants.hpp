#pragma once

namespace tp::constants
{
    namespace name::fruit
    {
        constexpr auto area2d{ "Area2D" };
        constexpr auto sprite{ "AnimatedSprite2D" };
        constexpr const char* fruit_types[]{ "Apple", "Banana", "Cherry",    "Kiwi",
                                             "Melon", "Orange", "Pineapple", "Strawberry" };
    }

    namespace event
    {
        constexpr auto body_entered{ "_on_area_2d_body_entered" };
        constexpr auto animation_finished{ "_on_animation_finished" };
        constexpr auto fruit_collected{ "fruit_score_changed" };
        constexpr auto fruit_collected_player{ "fruit_collected" };

    }
}