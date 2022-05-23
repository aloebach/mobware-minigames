rescues = {}

local guy_left_x = 0
local guy_right_x = 0
local spot = 0
local jumper1_y = 0
local jumper1_y_direction = 0
local jumper2_y = 0
local jumper2_y_direction = 0
local jumper3_y = 0
local jumper3_y_direction = 0
local jumper4_y = 0
local jumper4_y_direction = 0
local points = 0
local misses = 0
local jumper1_x = 0
local jumper2_x = 0
local jumper3_x = 0
local jumper4_x = 0
local high_score = 0
local jumper1_x_direction = 0
local jumper2_x_direction = 0
local jumper3_x_direction = 0
local jumper4_x_direction = 0
local crankRot = 0
local jumper_speed = 0
local tile_name1 = 0
local tile_name2 = 0
local tile_name3 = 0
local tile_name4 = 0
local jumper_frames = 0
local sameY_1 = 0
local sameY_2 = 0
local sameY_3 = 0
local sameY_4 = 0
local sameY_5 = 0
local sameY_6 = 0
local has_played = 0
local jumper_speed_per_second = 0
local sensNeg = 0
local sensitivity = 0
local guy_left_y = 0
local guy_right_y = 0
local goal_x = 0
local goal_y = 0
local player_x = 0
local player_y = 0
local spot1_x = 0
local spot2_x = 0
local spot3_x = 0
local spot4_x = 0

-- tweak sound engine to sound as it sounded on firefox prior to 1.10.0.
-- set this to true to make the sfx sound as it did prior to 1.10.0.
-- set this to false to make the sfx sound as it does on pdx export.
-- currently, there is no compatability mode to make the music sound as it did in 1.10.0.
local FIREFOX_SOUND_COMPAT = false

-- set random seed
math.randomseed(playdate.getSecondsSinceEpoch())

-- pulp options (must be set before `import "pulp"`)
___pulp = {
  playerid = 2,
  startroom = 0,
  startx = 11,
  starty = 10,
  gamename = "Rescues",
  halfwidth = false,
  pipe_img = playdate.graphics.imagetable.new("extras/rescues/pipe"),
  font_img = playdate.graphics.imagetable.new("extras/rescues/font"),
  tile_img = playdate.graphics.imagetable.new("extras/rescues/tiles")
}
local __pulp <const> = ___pulp
import "extras/rescues/pulp"
local __sin <const> = math.sin
local __cos <const> = math.cos
local __tan <const> = math.tan
local __floor <const> = math.floor
local __ceil <const> = math.ceil
local __round <const> = function(x) return math.ceil(x + 0.5) end
local __random <const> = math.random
local __tau <const> = math.pi * 2
local __tostring <const> = tostring
local __roomtiles <const> = __pulp.roomtiles
local __print <const> = print
local __getTime <const> = playdate.getTime
local __getSecondsSinceEpoch <const> = playdate.getSecondsSinceEpoch
local __fillrect <const> = playdate.graphics.fillRect
local __setcolour <const> = playdate.graphics.setColor
local __fillcolours <const> = {
    black = playdate.graphics.kColorBlack,
    white = playdate.graphics.kColorWhite
}
local __pix8scale = __pulp.pix8scale
local __script <const> = {}

__pulp.tiles = {}
__pulp.tiles[0] = {
    id = 0,
    fps = 1,
    name = "white",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[1] = {
    id = 1,
    fps = 1,
    name = "black",
    type = 0,
    btype = -1,
    solid = true,
    frames = {2, }
  }
__pulp.tiles[2] = {
    id = 2,
    fps = 0,
    name = "player",
    type = 1,
    btype = 1,
    solid = false,
    frames = {3,93, }
  }
__pulp.tiles[3] = {
    id = 3,
    fps = 1,
    name = "jumper",
    type = 2,
    btype = 1,
    solid = true,
    frames = {4,72,73,74, }
  }
__pulp.tiles[4] = {
    id = 4,
    fps = 1,
    name = "disk",
    type = 3,
    btype = 0,
    solid = false,
    says = "You found a floppy disk!",    frames = {5, }
  }
__pulp.tiles[5] = {
    id = 5,
    fps = 1,
    name = "white 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {6, }
  }
__pulp.tiles[6] = {
    id = 6,
    fps = 1,
    name = "tile 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {7, }
  }
__pulp.tiles[7] = {
    id = 7,
    fps = 1,
    name = "tile 7",
    type = 0,
    btype = -1,
    solid = false,
    frames = {8, }
  }
__pulp.tiles[8] = {
    id = 8,
    fps = 1,
    name = "tile 8",
    type = 0,
    btype = -1,
    solid = false,
    frames = {9, }
  }
__pulp.tiles[9] = {
    id = 9,
    fps = 1,
    name = "tile 9",
    type = 0,
    btype = -1,
    solid = false,
    frames = {9, }
  }
__pulp.tiles[10] = {
    id = 10,
    fps = 1,
    name = "tile 10",
    type = 0,
    btype = -1,
    solid = true,
    frames = {10, }
  }
__pulp.tiles[11] = {
    id = 11,
    fps = 1,
    name = "tile 11",
    type = 0,
    btype = -1,
    solid = false,
    frames = {11, }
  }
__pulp.tiles[12] = {
    id = 12,
    fps = 1,
    name = "tile 12",
    type = 0,
    btype = -1,
    solid = false,
    frames = {8, }
  }
__pulp.tiles[13] = {
    id = 13,
    fps = 1,
    name = "tile 13",
    type = 0,
    btype = -1,
    solid = false,
    frames = {12, }
  }
__pulp.tiles[14] = {
    id = 14,
    fps = 1,
    name = "tile 14",
    type = 0,
    btype = -1,
    solid = false,
    frames = {13, }
  }
__pulp.tiles[15] = {
    id = 15,
    fps = 3,
    name = "balcony",
    type = 0,
    btype = -1,
    solid = false,
    frames = {14,102, }
  }
__pulp.tiles[16] = {
    id = 16,
    fps = 1,
    name = "tile 16",
    type = 0,
    btype = -1,
    solid = false,
    frames = {15, }
  }
__pulp.tiles[17] = {
    id = 17,
    fps = 1,
    name = "tile 17",
    type = 0,
    btype = -1,
    solid = false,
    frames = {16, }
  }
__pulp.tiles[18] = {
    id = 18,
    fps = 1,
    name = "tile 18",
    type = 0,
    btype = -1,
    solid = false,
    frames = {17, }
  }
__pulp.tiles[19] = {
    id = 19,
    fps = 1,
    name = "tile 19",
    type = 0,
    btype = -1,
    solid = false,
    frames = {18, }
  }
__pulp.tiles[20] = {
    id = 20,
    fps = 1,
    name = "tile 20",
    type = 0,
    btype = -1,
    solid = false,
    frames = {19, }
  }
__pulp.tiles[21] = {
    id = 21,
    fps = 1,
    name = "tile 21",
    type = 0,
    btype = -1,
    solid = false,
    frames = {20, }
  }
__pulp.tiles[22] = {
    id = 22,
    fps = 1,
    name = "tile 22",
    type = 0,
    btype = -1,
    solid = true,
    frames = {21, }
  }
__pulp.tiles[23] = {
    id = 23,
    fps = 1,
    name = "tile 23",
    type = 0,
    btype = -1,
    solid = false,
    frames = {22, }
  }
__pulp.tiles[24] = {
    id = 24,
    fps = 1,
    name = "tile 24",
    type = 0,
    btype = -1,
    solid = false,
    frames = {23, }
  }
__pulp.tiles[25] = {
    id = 25,
    fps = 1,
    name = "tile 25",
    type = 0,
    btype = -1,
    solid = false,
    frames = {24, }
  }
__pulp.tiles[26] = {
    id = 26,
    fps = 1,
    name = "tile 26",
    type = 0,
    btype = -1,
    solid = true,
    frames = {25, }
  }
__pulp.tiles[27] = {
    id = 27,
    fps = 1,
    name = "tile 27",
    type = 0,
    btype = -1,
    solid = false,
    frames = {26, }
  }
__pulp.tiles[28] = {
    id = 28,
    fps = 1,
    name = "tile 28",
    type = 0,
    btype = -1,
    solid = false,
    frames = {27, }
  }
__pulp.tiles[29] = {
    id = 29,
    fps = 1,
    name = "tile 29",
    type = 0,
    btype = -1,
    solid = false,
    frames = {28, }
  }
__pulp.tiles[30] = {
    id = 30,
    fps = 1,
    name = "tile 30",
    type = 0,
    btype = -1,
    solid = false,
    frames = {29, }
  }
__pulp.tiles[31] = {
    id = 31,
    fps = 1,
    name = "tile 31",
    type = 0,
    btype = -1,
    solid = false,
    frames = {30, }
  }
__pulp.tiles[32] = {
    id = 32,
    fps = 1,
    name = "tile 32",
    type = 0,
    btype = -1,
    solid = false,
    frames = {31, }
  }
__pulp.tiles[33] = {
    id = 33,
    fps = 1,
    name = "tile 33",
    type = 0,
    btype = -1,
    solid = false,
    frames = {10, }
  }
__pulp.tiles[34] = {
    id = 34,
    fps = 1,
    name = "tile 34",
    type = 0,
    btype = -1,
    solid = true,
    frames = {32, }
  }
__pulp.tiles[35] = {
    id = 35,
    fps = 1,
    name = "tile 35",
    type = 0,
    btype = -1,
    solid = true,
    frames = {33, }
  }
__pulp.tiles[36] = {
    id = 36,
    fps = 1,
    name = "tile 36",
    type = 0,
    btype = -1,
    solid = false,
    frames = {34, }
  }
__pulp.tiles[37] = {
    id = 37,
    fps = 1,
    name = "tile 37",
    type = 0,
    btype = -1,
    solid = true,
    frames = {26, }
  }
__pulp.tiles[38] = {
    id = 38,
    fps = 1,
    name = "guy left",
    type = 0,
    btype = -1,
    solid = false,
    frames = {35, }
  }
__pulp.tiles[39] = {
    id = 39,
    fps = 1,
    name = "guy right",
    type = 0,
    btype = -1,
    solid = false,
    frames = {36, }
  }
__pulp.tiles[40] = {
    id = 40,
    fps = 1,
    name = "tile 40",
    type = 0,
    btype = -1,
    solid = true,
    frames = {37, }
  }
__pulp.tiles[41] = {
    id = 41,
    fps = 1,
    name = "tile 41",
    type = 0,
    btype = -1,
    solid = false,
    frames = {38, }
  }
__pulp.tiles[42] = {
    id = 42,
    fps = 1,
    name = "tile 42",
    type = 0,
    btype = -1,
    solid = false,
    frames = {39, }
  }
__pulp.tiles[43] = {
    id = 43,
    fps = 1,
    name = "tile 43",
    type = 0,
    btype = -1,
    solid = false,
    frames = {40, }
  }
__pulp.tiles[44] = {
    id = 44,
    fps = 1,
    name = "tile 44",
    type = 0,
    btype = -1,
    solid = false,
    frames = {41, }
  }
__pulp.tiles[45] = {
    id = 45,
    fps = 1,
    name = "tile 45",
    type = 0,
    btype = -1,
    solid = false,
    frames = {42, }
  }
__pulp.tiles[46] = {
    id = 46,
    fps = 1,
    name = "tile 46",
    type = 0,
    btype = -1,
    solid = false,
    frames = {43, }
  }
__pulp.tiles[47] = {
    id = 47,
    fps = 1,
    name = "tile 47",
    type = 0,
    btype = -1,
    solid = true,
    frames = {27, }
  }
__pulp.tiles[48] = {
    id = 48,
    fps = 1,
    name = "van top corner",
    type = 0,
    btype = -1,
    solid = true,
    frames = {44, }
  }
__pulp.tiles[49] = {
    id = 49,
    fps = 1,
    name = "van back",
    type = 0,
    btype = -1,
    solid = true,
    frames = {45, }
  }
__pulp.tiles[50] = {
    id = 50,
    fps = 1,
    name = "tile 50",
    type = 0,
    btype = -1,
    solid = true,
    frames = {46, }
  }
__pulp.tiles[51] = {
    id = 51,
    fps = 1,
    name = "tile 51",
    type = 0,
    btype = -1,
    solid = false,
    frames = {47, }
  }
__pulp.tiles[52] = {
    id = 52,
    fps = 1,
    name = "white 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {48, }
  }
__pulp.tiles[53] = {
    id = 53,
    fps = 1,
    name = "white wall",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1, }
  }
__pulp.tiles[54] = {
    id = 54,
    fps = 1,
    name = "tile 54",
    type = 0,
    btype = -1,
    solid = true,
    frames = {28, }
  }
__pulp.tiles[55] = {
    id = 55,
    fps = 1,
    name = "tile 55",
    type = 0,
    btype = -1,
    solid = true,
    frames = {49, }
  }
__pulp.tiles[56] = {
    id = 56,
    fps = 1,
    name = "tile 56",
    type = 0,
    btype = -1,
    solid = true,
    frames = {26, }
  }
__pulp.tiles[57] = {
    id = 57,
    fps = 1,
    name = "tile 57",
    type = 0,
    btype = -1,
    solid = true,
    frames = {50, }
  }
__pulp.tiles[58] = {
    id = 58,
    fps = 1,
    name = "tile 58",
    type = 0,
    btype = -1,
    solid = true,
    frames = {51, }
  }
__pulp.tiles[59] = {
    id = 59,
    fps = 1,
    name = "tile 59",
    type = 0,
    btype = -1,
    solid = false,
    frames = {52, }
  }
__pulp.tiles[60] = {
    id = 60,
    fps = 1,
    name = "tile 60",
    type = 0,
    btype = -1,
    solid = false,
    frames = {53, }
  }
__pulp.tiles[61] = {
    id = 61,
    fps = 1,
    name = "tile 61",
    type = 0,
    btype = -1,
    solid = true,
    frames = {54, }
  }
__pulp.tiles[62] = {
    id = 62,
    fps = 1,
    name = "tile 62",
    type = 0,
    btype = -1,
    solid = true,
    frames = {55, }
  }
__pulp.tiles[63] = {
    id = 63,
    fps = 1,
    name = "tile 63",
    type = 0,
    btype = -1,
    solid = false,
    frames = {54, }
  }
__pulp.tiles[64] = {
    id = 64,
    fps = 1,
    name = "tile 64",
    type = 0,
    btype = -1,
    solid = false,
    frames = {55, }
  }
__pulp.tiles[65] = {
    id = 65,
    fps = 1,
    name = "tile 65",
    type = 0,
    btype = -1,
    solid = false,
    frames = {56, }
  }
__pulp.tiles[66] = {
    id = 66,
    fps = 1,
    name = "tile 66",
    type = 0,
    btype = -1,
    solid = false,
    frames = {57, }
  }
__pulp.tiles[67] = {
    id = 67,
    fps = 1,
    name = "tile 67",
    type = 0,
    btype = -1,
    solid = false,
    frames = {31, }
  }
__pulp.tiles[68] = {
    id = 68,
    fps = 1,
    name = "tile 68",
    type = 0,
    btype = -1,
    solid = true,
    frames = {49, }
  }
__pulp.tiles[69] = {
    id = 69,
    fps = 1,
    name = "tile 69",
    type = 0,
    btype = -1,
    solid = true,
    frames = {58, }
  }
__pulp.tiles[70] = {
    id = 70,
    fps = 1,
    name = "van top",
    type = 0,
    btype = -1,
    solid = true,
    frames = {59, }
  }
__pulp.tiles[71] = {
    id = 71,
    fps = 1,
    name = "tile 71",
    type = 0,
    btype = -1,
    solid = true,
    frames = {60, }
  }
__pulp.tiles[72] = {
    id = 72,
    fps = 1,
    name = "tile 72",
    type = 0,
    btype = -1,
    solid = false,
    frames = {61, }
  }
__pulp.tiles[73] = {
    id = 73,
    fps = 1,
    name = "tile 73",
    type = 0,
    btype = -1,
    solid = false,
    frames = {62, }
  }
__pulp.tiles[74] = {
    id = 74,
    fps = 6,
    name = "white wall 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {63,65,66,67,68,69,70,71, }
  }
__pulp.tiles[75] = {
    id = 75,
    fps = 1,
    name = "white wall 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {64, }
  }
__pulp.tiles[76] = {
    id = 76,
    fps = 1,
    name = "up right",
    type = 0,
    btype = -1,
    solid = false,
    frames = {77, }
  }
__pulp.tiles[77] = {
    id = 77,
    fps = 1,
    name = "angle down",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[78] = {
    id = 78,
    fps = 1,
    name = "straight down",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[79] = {
    id = 79,
    fps = 1,
    name = "tile 79",
    type = 0,
    btype = -1,
    solid = false,
    frames = {75, }
  }
__pulp.tiles[80] = {
    id = 80,
    fps = 1,
    name = "tile 80",
    type = 0,
    btype = -1,
    solid = false,
    frames = {76, }
  }
__pulp.tiles[81] = {
    id = 81,
    fps = 1,
    name = "tile 81",
    type = 0,
    btype = -1,
    solid = false,
    frames = {78, }
  }
__pulp.tiles[82] = {
    id = 82,
    fps = 1,
    name = "tile 82",
    type = 0,
    btype = -1,
    solid = false,
    frames = {79, }
  }
__pulp.tiles[83] = {
    id = 83,
    fps = 1,
    name = "tile 83",
    type = 0,
    btype = -1,
    solid = false,
    frames = {80, }
  }
__pulp.tiles[84] = {
    id = 84,
    fps = 3,
    name = "smoke bottom",
    type = 0,
    btype = -1,
    solid = false,
    frames = {81,85,86,87,88,89,90,91, }
  }
__pulp.tiles[85] = {
    id = 85,
    fps = 3,
    name = "smoke end",
    type = 0,
    btype = -1,
    solid = false,
    frames = {82,104,105, }
  }
__pulp.tiles[86] = {
    id = 86,
    fps = 1,
    name = "tile 86",
    type = 0,
    btype = -1,
    solid = false,
    frames = {83, }
  }
__pulp.tiles[87] = {
    id = 87,
    fps = 1,
    name = "tile 87",
    type = 0,
    btype = -1,
    solid = false,
    frames = {84, }
  }
__pulp.tiles[88] = {
    id = 88,
    fps = 0,
    name = "player down",
    type = 1,
    btype = -1,
    solid = false,
    frames = {93, }
  }
__pulp.tiles[89] = {
    id = 89,
    fps = 1,
    name = "jumper ouch",
    type = 2,
    btype = 0,
    solid = true,
    frames = {100, }
  }
__pulp.tiles[90] = {
    id = 90,
    fps = 1,
    name = "goal",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[91] = {
    id = 91,
    fps = 1,
    name = "spot1",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[92] = {
    id = 92,
    fps = 1,
    name = "spot2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[93] = {
    id = 93,
    fps = 1,
    name = "spot3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[94] = {
    id = 94,
    fps = 1,
    name = "spot4",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[95] = {
    id = 95,
    fps = 3,
    name = "tile 95",
    type = 0,
    btype = -1,
    solid = false,
    frames = {101,103, }
  }
__pulp.tiles[96] = {
    id = 96,
    fps = 1,
    name = "miss",
    type = 0,
    btype = -1,
    solid = false,
    frames = {92, }
  }
__pulp.tiles[97] = {
    id = 97,
    fps = 1,
    name = "S",
    type = 0,
    btype = -1,
    solid = false,
    frames = {94, }
  }
__pulp.tiles[98] = {
    id = 98,
    fps = 1,
    name = "R",
    type = 0,
    btype = -1,
    solid = false,
    frames = {95, }
  }
__pulp.tiles[99] = {
    id = 99,
    fps = 1,
    name = "E",
    type = 0,
    btype = -1,
    solid = false,
    frames = {96, }
  }
__pulp.tiles[100] = {
    id = 100,
    fps = 1,
    name = "C",
    type = 0,
    btype = -1,
    solid = false,
    frames = {97, }
  }
__pulp.tiles[101] = {
    id = 101,
    fps = 1,
    name = "U",
    type = 0,
    btype = -1,
    solid = false,
    frames = {98, }
  }
__pulp.tiles[102] = {
    id = 102,
    fps = 1,
    name = "tile 102",
    type = 0,
    btype = -1,
    solid = false,
    frames = {99, }
  }
__pulp.tiles[103] = {
    id = 103,
    fps = 1,
    name = "tile 103",
    type = 0,
    btype = -1,
    solid = false,
    frames = {106, }
  }

__pulp.rooms = {}
__pulp.rooms[0] = {
  id = 0,
  name = "start",
  song = -1,
  tiles = {
      14,  11,  12,  84,  84,  84,  84,  84,  84,  85,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      11,   6,  21,  84,  84,  84,  84,  84,  85,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       6,  13,  84,  84,  84,  84,  84,  85,   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      18,  17,  15,  95,   0,   0,   0,   0,   0,  77,   0,   0,   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      16,  19,  13,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,   0,   0,   0,   0,  78,   0,   0,   0,   0,   0,   0,
      22,  20,  13,   0,   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,   0,   0,   0,   0,   0,   0,   0,
      23,  11,   7,   0,   0,  77,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      11,   6,  11,   0,   0,   0,   0,   0,   0,   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       6,  13,   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      11,   7,  53,  53,  53,  53,  53,  53,  53,  53,  53,  53,  53,  53,  53,  53,  53,  53,  53,  90,   0,  53,  75,  74,  53,
       0,   7,  10,  53,  91,  53,  53,  92,  53,  53,  53,  93,  53,  53,  53,  94,  53,  53,  53,  48,  51,  70,  71,  45,  44,
       6,   5,   8,  37,  54,  47,  53,  53,  35,  34,  37,  53,  69,  57,  58,  53,  61,  62,  37,  49,  52,  72,  73,  46,  43,
       5,   9,  27,  29,  28,  53,  53,  53,  67,  37,  53,  53,  53,  68,  59,  53,  53,  63,  64,  50,  40,  41,  41,  40,  42,
       9,   0,  24,  25,   0,  53,  53,  53,  30,  53,  53,  53,  53,  53,  60,  53,  53,  53,  66,  65,  53,  53,   0,  53,  53,
      26,  26,  26,  31,   0,  53,  53,  26,  26,  26,  53,  53,  53,  26,  26,  26,  53,  53,  26,  26,  26,  26,  26,  26,  26, },
  exits = {
  nil},
}
__pulp.rooms[1] = {
  id = 1,
  name = "card",
  song = -1,
  tiles = {
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   1,   1,   1,   0,   0,   0,   0,   0,   1,   1,   0,   0,   0,   0,   0,   0,   1,   1,   1,   0,   0,   0,
       0,   0,   0,   1,   1,   1,   1,   0,   0,   0,   0,   1,   1,   1,   0,   0,   0,   0,   1,   1,   1,   1,   0,   0,   0,
       0,   0,   0,   1,   1,   1,   0,   0,   0,   1,   0,   1,   1,   0,   0,   0,   0,   0,   0,   1,   1,   1,   0,   0,   0,
       0,   0,   0,   1,   1,   0,   0,   1,   0,   0,   1,   1,   0,   0,   1,   0,   0,   1,   0,   0,   1,   1,   0,   0,   0,
       0,   0,   0,   1,   1,   1,   1,   1,   1,   0,   0,   1,   0,   1,   1,   0,   1,   1,   1,   1,   1,   1,   0,   0,   0,
       0,   0,   0,   1,   1,   1,   0,   0,   0,   1,   0,   1,   1,   0,   0,   1,   0,   0,   0,   1,   1,   1,   0,   0,   0,
       0,   0,   0,   1,   1,   1,   0,   0,   0,   0,   1,   1,   1,   1,   1,   0,   0,   0,   0,   1,   1,   1,   0,   0,   0,
       0,   0,   0,   1,   0,   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   0,   1,   0,   0,   0,
       0,   0,   1,   1,   0,   1,   1,   0, 102,  98,  99,  97, 100, 101,  99,  97, 103,   0,   1,   1,   0,   1,   1,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, },
  exits = {
  nil},
}

__pulp.sounds = {}
__pulp.sounds[0] = {
  bpm = 120,
  name = "beep",
  type = 1,
  notes = {1, 6, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  ticks = 7,
  volume = 0.5,
  sustain = 0.1,
}
__pulp.sounds[1] = {
  bpm = 120,
  name = "bounce",
  type = 2,
  notes = {1, 4, 1, },
  ticks = 1,
  decay = 0.5,
  volume = 0.5,
}
__pulp.sounds[2] = {
  bpm = 120,
  name = "ouch",
  type = 2,
  notes = {1, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  ticks = 11,
  volume = 0.5,
}

__pulp.songs = {}
__pulp.songs[#__pulp.songs + 1] = {
  bpm = 120,
  id = 0,
  name = "theme",
  ticks = 0,
  notes = {
    {},
    {},
    {},
    {},
    {},
  },
  loopFrom = 0
,}

----------------- game ----------------------------

__pulp:newScript("game")
__script[1] = __pulp:getScript("game")
__pulp:associateScript("game", "global", 0)

__pulp:getScript("game").load = function(__actor, event, __evname)
  local __self = __script[1] --[this script]
  --first time playing the game, this needs to be 0
  has_played = 0
  --if the game has been played, this will set has_played to 1
  __pulp.__fn_restore()
  __self.init(__actor, event, "init") 
end

__pulp:getScript("game").init = function(__actor, event, __evname)
  local __event_py = __pulp.player.y
  local __event_px = __pulp.player.x
  player_x = __event_px
  player_y = __event_py
  spot1_x = 4
  spot2_x = 7
  spot3_x = 11
  spot4_x = 15
  goal_x = 21
  goal_y = 10
  guy_left_x = 10
  guy_left_y = 10
  guy_right_x = 12
  guy_right_y = 10
  jumper1_x = 4
  jumper1_y = 2
  jumper1_y_direction = "down"
  jumper1_x_direction = "straight"
  jumper2_x = 4
  jumper2_y = 0
  jumper2_y_direction = "down"
  jumper2_x_direction = "straight"
  jumper3_x = 4
  jumper3_y = 0
  jumper3_y_direction = "down"
  jumper3_x_direction = "straight"
  jumper4_x = 4
  jumper4_y = 0
  jumper4_y_direction = "down"
  jumper4_x_direction = "straight"
  jumper_frames = 0
  jumper_speed_per_second = 1.8
  --^moves per second
  jumper_speed = 20
  --^game fps
  jumper_speed /= jumper_speed_per_second
  jumper_speed = __round(jumper_speed)
  --^germ speed is now the number of frames per move
  spot = "spot3"
  points = 0
  misses = 0
end

__pulp:getScript("game").loop = function(__actor, event, __evname)
  local __self = __script[1] --[this script]
  tile_name1 = __roomtiles[jumper1_y][jumper1_x].name
  tile_name2 = __roomtiles[jumper2_y][jumper2_x].name
  tile_name3 = __roomtiles[jumper3_y][jumper3_x].name
  tile_name4 = __roomtiles[jumper4_y][jumper4_x].name
  jumper_frames += 1
  if jumper_frames == jumper_speed then
    __self.moveJumper1(__actor, event, "moveJumper1") 
    if points > 9 then
      __self.moveJumper2(__actor, event, "moveJumper2") 
    end
    if points > 22 then
      __self.moveJumper3(__actor, event, "moveJumper3") 
    end
    if points > 67 then
      __self.moveJumper4(__actor, event, "moveJumper4") 
    end
    --reset the frame count
    --this is a kludge to do something every n frames
    jumper_frames = 1
  end
  __self.checkForMatches(__actor, event, "checkForMatches") 
  __self.checkForMisses(__actor, event, "checkForMisses") 
  __self.increaseSpeed(__actor, event, "increaseSpeed") 
end

__pulp:getScript("game").moveJumper1 = function(__actor, event, __evname)
  local __self = __script[1] --[this script]
  local __event_py = __pulp.player.y
  local __event_px = __pulp.player.x
  if jumper1_y < 11 then
    if jumper1_y > 1 then
      if jumper1_y_direction == "up" then
        jumper1_y -= 1
        __pulp.__fn_sound("beep")
      else
        if sameY_1 ~= 1 then
          if sameY_2 ~= 1 then
            if sameY_4 ~= 1 then
              jumper1_y += 1
              __pulp.__fn_sound("beep")
            end
          end
        end
      end
    end
  end
  if jumper1_x_direction == "right" then
    jumper1_x += 1
  end
  if jumper1_x == __event_px then
    if jumper1_y == __event_py then
      jumper1_y_direction = "up"
      points += 1
      __pulp.__fn_sound("bounce")
    end
  end
  --Check for each position while the jumper bounces
  if jumper1_y_direction == "up" then
    if tile_name1 == "straight down" then
      jumper1_x_direction = "right"
      jumper1_y_direction = "up"
    end
  end
  if jumper1_y_direction == "up" then
    if tile_name1 == "angle down" then
      jumper1_y_direction = "down"
      jumper1_x_direction = "right"
    end
  end
  if jumper1_y_direction == "down" then
    if tile_name1 == "straight down" then
      jumper1_x_direction = "straight"
      jumper1_y_direction = "down"
    end
  end
  if jumper1_y == 11 then
    misses += 1
    __pulp.__fn_shake(1)
    __pulp.__fn_sound("ouch")
    do --[tell x,y to]
      local __actor = __roomtiles[jumper1_y][jumper1_x]
      if __actor and __actor.tile then
        __pulp.__fn_swap(__actor, "jumper ouch")
      end
    end

    __self.resetJumper1(__actor, event, "resetJumper1") 
  end
  --Get a point when jumper reaches ambulance
  if tile_name1 == "goal" then
    __self.resetJumper1(__actor, event, "resetJumper1") 
  end
  --end
end

__pulp:getScript("game").resetJumper1 = function(__actor, event, __evname)
  jumper1_x = 4
  jumper1_y = 2
  jumper1_y_direction = "down"
  jumper1_x_direction = "straight"
end

__pulp:getScript("game").moveJumper2 = function(__actor, event, __evname)
  local __self = __script[1] --[this script]
  local __event_py = __pulp.player.y
  local __event_px = __pulp.player.x
  if jumper2_y < 11 then
    if jumper2_y_direction == "up" then
      jumper2_y -= 1
      __pulp.__fn_sound("beep")
    else
      --if sameY_5!=1 then
      jumper2_y += 1
      __pulp.__fn_sound("beep")
      --end
    end
  end
  if jumper2_x_direction == "right" then
    jumper2_x += 1
  end
  if jumper2_x == __event_px then
    if jumper2_y == __event_py then
      jumper2_y_direction = "up"
      points += 1
      __pulp.__fn_sound("bounce")
    end
  end
  --Check for each position while the jumper bounces
  if jumper2_y_direction == "up" then
    if tile_name2 == "straight down" then
      jumper2_x_direction = "right"
      jumper2_y_direction = "up"
    end
  end
  if jumper2_y_direction == "up" then
    if tile_name2 == "angle down" then
      jumper2_y_direction = "down"
      jumper2_x_direction = "right"
    end
  end
  if jumper2_y_direction == "down" then
    if tile_name2 == "straight down" then
      jumper2_x_direction = "straight"
      jumper2_y_direction = "down"
    end
  end
  if jumper2_y == 11 then
    misses += 1
    __pulp.__fn_shake(1)
    __pulp.__fn_sound("ouch")
    do --[tell x,y to]
      local __actor = __roomtiles[jumper2_y][jumper2_x]
      if __actor and __actor.tile then
        __pulp.__fn_swap(__actor, "jumper ouch")
      end
    end

    __self.resetJumper2(__actor, event, "resetJumper2") 
  end
  --Get a point when jumper reaches ambulance
  if tile_name2 == "goal" then
    __self.resetJumper2(__actor, event, "resetJumper2") 
  end
end

__pulp:getScript("game").resetJumper2 = function(__actor, event, __evname)
  jumper2_x = 4
  jumper2_y = 0
  jumper2_y_direction = "down"
  jumper2_x_direction = "straight"
end

__pulp:getScript("game").moveJumper3 = function(__actor, event, __evname)
  local __self = __script[1] --[this script]
  local __event_py = __pulp.player.y
  local __event_px = __pulp.player.x
  if jumper3_y < 11 then
    if jumper3_y_direction == "up" then
      jumper3_y -= 1
      __pulp.__fn_sound("beep")
    else
      if sameY_3 ~= 1 then
        jumper3_y += 1
        __pulp.__fn_sound("beep")
      end
    end
  end
  if jumper3_x_direction == "right" then
    jumper3_x += 1
  end
  if jumper3_x == __event_px then
    if jumper3_y == __event_py then
      jumper3_y_direction = "up"
      points += 1
      __pulp.__fn_sound("bounce")
    end
  end
  --Check for each position while the jumper bounces
  if jumper3_y_direction == "up" then
    if tile_name3 == "straight down" then
      jumper3_x_direction = "right"
      jumper3_y_direction = "up"
    end
  end
  if jumper3_y_direction == "up" then
    if tile_name3 == "angle down" then
      jumper3_y_direction = "down"
      jumper3_x_direction = "right"
    end
  end
  if jumper3_y_direction == "down" then
    if tile_name3 == "straight down" then
      jumper3_x_direction = "straight"
      jumper3_y_direction = "down"
    end
  end
  if jumper3_y == 11 then
    misses += 1
    __pulp.__fn_shake(1)
    __pulp.__fn_sound("ouch")
    do --[tell x,y to]
      local __actor = __roomtiles[jumper3_y][jumper3_x]
      if __actor and __actor.tile then
        __pulp.__fn_swap(__actor, "jumper ouch")
      end
    end

    __self.resetJumper3(__actor, event, "resetJumper3") 
  end
  --Get a point when jumper reaches ambulance
  if tile_name3 == "goal" then
    __self.resetJumper3(__actor, event, "resetJumper3") 
  end
  --end
end

__pulp:getScript("game").resetJumper3 = function(__actor, event, __evname)
  jumper3_x = 4
  jumper3_y = 1
  jumper3_y_direction = "down"
  jumper3_x_direction = "straight"
end

__pulp:getScript("game").moveJumper4 = function(__actor, event, __evname)
  local __self = __script[1] --[this script]
  local __event_py = __pulp.player.y
  local __event_px = __pulp.player.x
  if jumper4_y < 11 then
    if jumper4_y_direction == "up" then
      jumper4_y -= 1
      __pulp.__fn_sound("beep")
    else
      if sameY_5 ~= 1 then
        if sameY_6 ~= 1 then
          jumper4_y += 1
          __pulp.__fn_sound("beep")
        end
      end
    end
  end
  if jumper4_x_direction == "right" then
    jumper4_x += 1
  end
  if jumper4_x == __event_px then
    if jumper4_y == __event_py then
      jumper4_y_direction = "up"
      points += 1
      __pulp.__fn_sound("bounce")
    end
  end
  --Check for each position while the jumper bounces
  if jumper4_y_direction == "up" then
    if tile_name4 == "straight down" then
      jumper4_x_direction = "right"
      jumper4_y_direction = "up"
    end
  end
  if jumper4_y_direction == "up" then
    if tile_name4 == "angle down" then
      jumper4_y_direction = "down"
      jumper4_x_direction = "right"
    end
  end
  if jumper4_y_direction == "down" then
    if tile_name4 == "straight down" then
      jumper4_x_direction = "straight"
      jumper4_y_direction = "down"
    end
  end
  if jumper4_y == 11 then
    misses += 1
    __pulp.__fn_shake(1)
    __pulp.__fn_sound("ouch")
    do --[tell x,y to]
      local __actor = __roomtiles[jumper4_y][jumper4_x]
      if __actor and __actor.tile then
        __pulp.__fn_swap(__actor, "jumper ouch")
      end
    end

    __self.resetJumper4(__actor, event, "resetJumper4") 
  end
  --Get a point when jumper reaches ambulance
  if tile_name4 == "goal" then
    __self.resetJumper4(__actor, event, "resetJumper4") 
  end
  --end
end

__pulp:getScript("game").resetJumper4 = function(__actor, event, __evname)
  jumper4_x = 4
  jumper4_y = 0
  jumper4_y_direction = "down"
  jumper4_x_direction = "straight"
end

__pulp:getScript("game").checkForMatches = function(__actor, event, __evname)
  sameY_1 = 0
  --^1 and 2
  sameY_2 = 0
  --^1 and 3
  sameY_3 = 0
  --^2 and 3
  sameY_4 = 0
  --^1 and 4
  sameY_5 = 0
  --^2 and 4
  sameY_6 = 0
  --^3 and 4
  if jumper1_y_direction == "down" then
    if jumper2_y_direction == "down" then
      if jumper1_y == jumper2_y then
        sameY_1 = 1
      else
        sameY_1 = 0
      end
    end
  end
  if jumper1_y_direction == "down" then
    if jumper3_y_direction == "down" then
      if jumper1_y == jumper3_y then
        sameY_2 = 1
      else
        sameY_2 = 0
      end
    end
  end
  if jumper2_y_direction == "down" then
    if jumper3_y_direction == "down" then
      if jumper2_y == jumper3_y then
        sameY_3 = 1
      else
        sameY_3 = 0
      end
    end
  end
  if jumper1_y_direction == "down" then
    if jumper4_y_direction == "down" then
      if jumper1_y == jumper4_y then
        sameY_4 = 1
      else
        sameY_4 = 0
      end
    end
  end
  if jumper2_y_direction == "down" then
    if jumper4_y_direction == "down" then
      if jumper2_y == jumper4_y then
        sameY_5 = 1
      else
        sameY_5 = 0
      end
    end
  end
  if jumper3_y_direction == "down" then
    if jumper4_y_direction == "down" then
      if jumper3_y == jumper4_y then
        sameY_6 = 1
      else
        sameY_6 = 0
      end
    end
  end
end

__pulp:getScript("game").checkForMisses = function(__actor, event, __evname)
  if misses == 3 then
    if has_played == 0 then
      high_score = points
    else
      if points > high_score then
        high_score = points
      else
        high_score = high_score
      end
    end
    __pulp.__fn_wait(__actor, event, __evname, function(__actor, event, evname)
        __pulp.__fn_fin("HI SCORE: " .. __tostring(high_score))
      end, 2)
  end
end

__pulp:getScript("game").increaseSpeed = function(__actor, event, __evname)
  --increase overall speed a little bit after 30 points
  if points > 30 then
    jumper_speed_per_second = 2
  end
end

__pulp:getScript("game").finish = function(__actor, event, __evname)
  __pulp.__fn_store("high_score")
  has_played = 1
  __pulp.__fn_store("has_played")
end

----------------- player ----------------------------

__pulp:newScript("player")
__script[2] = __pulp:getScript("player")
__pulp:associateScript("player", "tile", 2)

__pulp:getScript("player").draw = function(__actor, event, __evname)
  __pulp.__fn_label(13, 0, nil, nil, __tostring(points))
  __pulp.__fn_label(18, 0, nil, nil, "MISS")
  if misses >= 1 then
    __pulp.__fn_draw(21, 1, "miss")
  end
  if misses >= 2 then
    __pulp.__fn_draw(20, 1, "miss")
  end
  if misses >= 3 then
    __pulp.__fn_draw(19, 1, "miss")
  end
  --Move guys on both sides of the trampoline
  __pulp.__fn_draw(guy_left_x, guy_left_y, "guy left")
  __pulp.__fn_draw(guy_right_x, guy_right_y, "guy right")
  __pulp.__fn_draw(jumper1_x, jumper1_y, "jumper")
  __pulp.__fn_draw(jumper2_x, jumper2_y, "jumper")
  __pulp.__fn_draw(jumper3_x, jumper3_y, "jumper")
  __pulp.__fn_draw(jumper4_x, jumper4_y, "jumper")
  __pulp.__fn_draw(3, 0, "smoke bottom")
  __pulp.__fn_draw(4, 0, "smoke bottom")
  __pulp.__fn_draw(5, 0, "smoke bottom")
  __pulp.__fn_draw(6, 0, "smoke bottom")
  __pulp.__fn_draw(7, 0, "smoke bottom")
  __pulp.__fn_draw(8, 0, "smoke bottom")
  __pulp.__fn_draw(9, 0, "smoke end")
  __pulp.__fn_draw(3, 1, "smoke bottom")
  __pulp.__fn_draw(4, 1, "smoke bottom")
  __pulp.__fn_draw(5, 1, "smoke bottom")
  __pulp.__fn_draw(6, 1, "smoke bottom")
  __pulp.__fn_draw(7, 1, "smoke bottom")
  __pulp.__fn_draw(8, 1, "smoke end")
  __pulp.__fn_draw(3, 2, "smoke bottom")
  __pulp.__fn_draw(4, 2, "smoke bottom")
  __pulp.__fn_draw(5, 2, "smoke bottom")
  __pulp.__fn_draw(6, 2, "smoke bottom")
  __pulp.__fn_draw(7, 2, "smoke end")
end

__pulp:getScript("player").update = function(__actor, event, __evname)
  local __event_py = __pulp.player.y
  local __event_px = __pulp.player.x
  local __event_dx = event.dx or 0
  spot = __roomtiles[__event_py][__event_px].name
  if __event_dx == 1 then
    if spot == "spot1" then
      __pulp.__fn_goto(7, 10)
      guy_left_x = 6
      guy_right_x = 8
    elseif spot == "spot2" then
      __pulp.__fn_goto(11, 10)
      guy_left_x = 10
      guy_right_x = 12
    elseif spot == "spot3" then
      __pulp.__fn_goto(15, 10)
      guy_left_x = 14
      guy_right_x = 16
    end
  end
  if __event_dx == -1 then
    if spot == "spot4" then
      __pulp.__fn_goto(11, 10)
      guy_left_x = 10
      guy_right_x = 12
    elseif spot == "spot3" then
      __pulp.__fn_goto(7, 10)
      guy_left_x = 6
      guy_right_x = 8
    elseif spot == "spot2" then
      __pulp.__fn_goto(4, 10)
      guy_left_x = 3
      guy_right_x = 5
    end
  end
end

__pulp:getScript("player").confirm = function(__actor, event, __evname)
  if spot == "spot1" then
    __pulp.__fn_goto(7, 10)
    guy_left_x = 6
    guy_right_x = 8
  elseif spot == "spot2" then
    __pulp.__fn_goto(11, 10)
    guy_left_x = 10
    guy_right_x = 12
  elseif spot == "spot3" then
    __pulp.__fn_goto(15, 10)
    guy_left_x = 14
    guy_right_x = 16
  end
end

__pulp:getScript("player").cancel = function(__actor, event, __evname)
  if spot == "spot4" then
    __pulp.__fn_goto(11, 10)
    guy_left_x = 10
    guy_right_x = 12
  elseif spot == "spot3" then
    __pulp.__fn_goto(7, 10)
    guy_left_x = 6
    guy_right_x = 8
  elseif spot == "spot2" then
    __pulp.__fn_goto(4, 10)
    guy_left_x = 3
    guy_right_x = 5
  end
end

__pulp:getScript("player").crank = function(__actor, event, __evname)
  crankRot += event.ra
  sensitivity = 70
  sensNeg = sensitivity
  sensNeg *= -1
  if crankRot >= sensitivity then
    crankRot = 0
    if spot == "spot1" then
      __pulp.__fn_goto(7, 10)
      guy_left_x = 6
      guy_right_x = 8
    elseif spot == "spot2" then
      __pulp.__fn_goto(11, 10)
      guy_left_x = 10
      guy_right_x = 12
    elseif spot == "spot3" then
      __pulp.__fn_goto(15, 10)
      guy_left_x = 14
      guy_right_x = 16
    end
  elseif crankRot <= sensNeg then
    crankRot = 0
    if spot == "spot4" then
      __pulp.__fn_goto(11, 10)
      guy_left_x = 10
      guy_right_x = 12
    elseif spot == "spot3" then
      __pulp.__fn_goto(7, 10)
      guy_left_x = 6
      guy_right_x = 8
    elseif spot == "spot2" then
      __pulp.__fn_goto(4, 10)
      guy_left_x = 3
      guy_right_x = 5
    end
  end
end

----------------- jumper ----------------------------

__pulp:newScript("jumper")
__script[3] = __pulp:getScript("jumper")
__pulp:associateScript("jumper", "tile", 3)

local __LOCVARSET = {
  ["guy_left_x"] = function(__guy_left_x) guy_left_x = __guy_left_x end,
  ["guy_right_x"] = function(__guy_right_x) guy_right_x = __guy_right_x end,
  ["spot"] = function(__spot) spot = __spot end,
  ["jumper1_y"] = function(__jumper1_y) jumper1_y = __jumper1_y end,
  ["jumper1_y_direction"] = function(__jumper1_y_direction) jumper1_y_direction = __jumper1_y_direction end,
  ["jumper2_y"] = function(__jumper2_y) jumper2_y = __jumper2_y end,
  ["jumper2_y_direction"] = function(__jumper2_y_direction) jumper2_y_direction = __jumper2_y_direction end,
  ["jumper3_y"] = function(__jumper3_y) jumper3_y = __jumper3_y end,
  ["jumper3_y_direction"] = function(__jumper3_y_direction) jumper3_y_direction = __jumper3_y_direction end,
  ["jumper4_y"] = function(__jumper4_y) jumper4_y = __jumper4_y end,
  ["jumper4_y_direction"] = function(__jumper4_y_direction) jumper4_y_direction = __jumper4_y_direction end,
  ["points"] = function(__points) points = __points end,
  ["misses"] = function(__misses) misses = __misses end,
  ["jumper1_x"] = function(__jumper1_x) jumper1_x = __jumper1_x end,
  ["jumper2_x"] = function(__jumper2_x) jumper2_x = __jumper2_x end,
  ["jumper3_x"] = function(__jumper3_x) jumper3_x = __jumper3_x end,
  ["jumper4_x"] = function(__jumper4_x) jumper4_x = __jumper4_x end,
  ["high_score"] = function(__high_score) high_score = __high_score end,
  ["jumper1_x_direction"] = function(__jumper1_x_direction) jumper1_x_direction = __jumper1_x_direction end,
  ["jumper2_x_direction"] = function(__jumper2_x_direction) jumper2_x_direction = __jumper2_x_direction end,
  ["jumper3_x_direction"] = function(__jumper3_x_direction) jumper3_x_direction = __jumper3_x_direction end,
  ["jumper4_x_direction"] = function(__jumper4_x_direction) jumper4_x_direction = __jumper4_x_direction end,
  ["crankRot"] = function(__crankRot) crankRot = __crankRot end,
  ["jumper_speed"] = function(__jumper_speed) jumper_speed = __jumper_speed end,
  ["tile_name1"] = function(__tile_name1) tile_name1 = __tile_name1 end,
  ["tile_name2"] = function(__tile_name2) tile_name2 = __tile_name2 end,
  ["tile_name3"] = function(__tile_name3) tile_name3 = __tile_name3 end,
  ["tile_name4"] = function(__tile_name4) tile_name4 = __tile_name4 end,
  ["jumper_frames"] = function(__jumper_frames) jumper_frames = __jumper_frames end,
  ["sameY_1"] = function(__sameY_1) sameY_1 = __sameY_1 end,
  ["sameY_2"] = function(__sameY_2) sameY_2 = __sameY_2 end,
  ["sameY_3"] = function(__sameY_3) sameY_3 = __sameY_3 end,
  ["sameY_4"] = function(__sameY_4) sameY_4 = __sameY_4 end,
  ["sameY_5"] = function(__sameY_5) sameY_5 = __sameY_5 end,
  ["sameY_6"] = function(__sameY_6) sameY_6 = __sameY_6 end,
  ["has_played"] = function(__has_played) has_played = __has_played end,
  ["jumper_speed_per_second"] = function(__jumper_speed_per_second) jumper_speed_per_second = __jumper_speed_per_second end,
  ["sensNeg"] = function(__sensNeg) sensNeg = __sensNeg end,
  ["sensitivity"] = function(__sensitivity) sensitivity = __sensitivity end,
  ["guy_left_y"] = function(__guy_left_y) guy_left_y = __guy_left_y end,
  ["guy_right_y"] = function(__guy_right_y) guy_right_y = __guy_right_y end,
  ["goal_x"] = function(__goal_x) goal_x = __goal_x end,
  ["goal_y"] = function(__goal_y) goal_y = __goal_y end,
  ["player_x"] = function(__player_x) player_x = __player_x end,
  ["player_y"] = function(__player_y) player_y = __player_y end,
  ["spot1_x"] = function(__spot1_x) spot1_x = __spot1_x end,
  ["spot2_x"] = function(__spot2_x) spot2_x = __spot2_x end,
  ["spot3_x"] = function(__spot3_x) spot3_x = __spot3_x end,
  ["spot4_x"] = function(__spot4_x) spot4_x = __spot4_x end,
nil}
local __LOCVARGET = {
  ["guy_left_x"] = function() return guy_left_x end,
  ["guy_right_x"] = function() return guy_right_x end,
  ["spot"] = function() return spot end,
  ["jumper1_y"] = function() return jumper1_y end,
  ["jumper1_y_direction"] = function() return jumper1_y_direction end,
  ["jumper2_y"] = function() return jumper2_y end,
  ["jumper2_y_direction"] = function() return jumper2_y_direction end,
  ["jumper3_y"] = function() return jumper3_y end,
  ["jumper3_y_direction"] = function() return jumper3_y_direction end,
  ["jumper4_y"] = function() return jumper4_y end,
  ["jumper4_y_direction"] = function() return jumper4_y_direction end,
  ["points"] = function() return points end,
  ["misses"] = function() return misses end,
  ["jumper1_x"] = function() return jumper1_x end,
  ["jumper2_x"] = function() return jumper2_x end,
  ["jumper3_x"] = function() return jumper3_x end,
  ["jumper4_x"] = function() return jumper4_x end,
  ["high_score"] = function() return high_score end,
  ["jumper1_x_direction"] = function() return jumper1_x_direction end,
  ["jumper2_x_direction"] = function() return jumper2_x_direction end,
  ["jumper3_x_direction"] = function() return jumper3_x_direction end,
  ["jumper4_x_direction"] = function() return jumper4_x_direction end,
  ["crankRot"] = function() return crankRot end,
  ["jumper_speed"] = function() return jumper_speed end,
  ["tile_name1"] = function() return tile_name1 end,
  ["tile_name2"] = function() return tile_name2 end,
  ["tile_name3"] = function() return tile_name3 end,
  ["tile_name4"] = function() return tile_name4 end,
  ["jumper_frames"] = function() return jumper_frames end,
  ["sameY_1"] = function() return sameY_1 end,
  ["sameY_2"] = function() return sameY_2 end,
  ["sameY_3"] = function() return sameY_3 end,
  ["sameY_4"] = function() return sameY_4 end,
  ["sameY_5"] = function() return sameY_5 end,
  ["sameY_6"] = function() return sameY_6 end,
  ["has_played"] = function() return has_played end,
  ["jumper_speed_per_second"] = function() return jumper_speed_per_second end,
  ["sensNeg"] = function() return sensNeg end,
  ["sensitivity"] = function() return sensitivity end,
  ["guy_left_y"] = function() return guy_left_y end,
  ["guy_right_y"] = function() return guy_right_y end,
  ["goal_x"] = function() return goal_x end,
  ["goal_y"] = function() return goal_y end,
  ["player_x"] = function() return player_x end,
  ["player_y"] = function() return player_y end,
  ["spot1_x"] = function() return spot1_x end,
  ["spot2_x"] = function() return spot2_x end,
  ["spot3_x"] = function() return spot3_x end,
  ["spot4_x"] = function() return spot4_x end,
nil}
function __pulp.setvariable(varname, value)
  if varname:find("__") then varname = "__" .. varname end -- prevent namespace conflicts with builtins
  local __varsetter = __LOCVARSET[varname]
  if __varsetter then __varsetter(value) else _G[varname] = value end
end
function __pulp.getvariable(varname)
  if varname:find("__") then varname = "__" .. varname end -- prevent namespace conflicts with builtins
  local __vargetter = __LOCVARGET[varname]
  if __vargetter then return __vargetter() else return _G[varname] end
end
function __pulp.resetvars()
  guy_left_x = 0
  guy_right_x = 0
  spot = 0
  jumper1_y = 0
  jumper1_y_direction = 0
  jumper2_y = 0
  jumper2_y_direction = 0
  jumper3_y = 0
  jumper3_y_direction = 0
  jumper4_y = 0
  jumper4_y_direction = 0
  points = 0
  misses = 0
  jumper1_x = 0
  jumper2_x = 0
  jumper3_x = 0
  jumper4_x = 0
  high_score = 0
  jumper1_x_direction = 0
  jumper2_x_direction = 0
  jumper3_x_direction = 0
  jumper4_x_direction = 0
  crankRot = 0
  jumper_speed = 0
  tile_name1 = 0
  tile_name2 = 0
  tile_name3 = 0
  tile_name4 = 0
  jumper_frames = 0
  sameY_1 = 0
  sameY_2 = 0
  sameY_3 = 0
  sameY_4 = 0
  sameY_5 = 0
  sameY_6 = 0
  has_played = 0
  jumper_speed_per_second = 0
  sensNeg = 0
  sensitivity = 0
  guy_left_y = 0
  guy_right_y = 0
  goal_x = 0
  goal_y = 0
  player_x = 0
  player_y = 0
  spot1_x = 0
  spot2_x = 0
  spot3_x = 0
  spot4_x = 0
end

__pulp:load()
__pulp:start()

return rescues