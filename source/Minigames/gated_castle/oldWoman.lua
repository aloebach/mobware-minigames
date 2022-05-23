import "Minigames/gated_castle/creature"

OldWoman = {}
OldWoman._index = Minotaur

local sprite_sheet = "Minigames/gated_castle/images/oldwoman"

function OldWoman:new(x, y, speed)
    local self = Creature:new(x, y, speed, sprite_sheet, 6, 24)
end