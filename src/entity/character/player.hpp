#pragma once

#include "core/constants.hpp"
#include "entity/character/character.hpp"
#include "util/bind.hpp"

namespace rl
{
    class Player final : public Character
    {
        GDCLASS(Player, Character);

    public:
        Player();
        ~Player() override = default;

        void _ready() override;

    protected:
        static void _bind_methods();
    };
}
