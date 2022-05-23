import "Minigames/gated_castle/creature"

Minotaur = {}
Minotaur._index = Minotaur

local sprite_sheet = "Minigames/gated_castle/images/minotaur"

function Minotaur:new(x, y, speed)
    local self = Creature:new(x, y, speed, sprite_sheet, 8, 70)
end