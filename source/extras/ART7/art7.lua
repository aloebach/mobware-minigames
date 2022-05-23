
art7 = {}

local x = 0
local y = 0
local f = 0
local disks = 0
local idle = 0
local maze = 0
local movin = 0
local anomaly = 0
local hasPlayed = 0
local maxIdle = 0

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
  startx = 8,
  starty = 13,
  gamename = "ART7 DEMO",
  halfwidth = false,
  pipe_img = playdate.graphics.imagetable.new("extras/ART7/pipe"),
  font_img = playdate.graphics.imagetable.new("extras/ART7/font"),
  tile_img = playdate.graphics.imagetable.new("extras/ART7/tiles")
}
local __pulp <const> = ___pulp
import "pulp"
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
    fps = 1,
    name = "player",
    type = 1,
    btype = 1,
    solid = false,
    frames = {3, }
  }
__pulp.tiles[3] = {
    id = 3,
    fps = 1,
    name = "computer",
    type = 2,
    btype = 1,
    solid = true,
    frames = {4, }
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
    fps = 2,
    name = "eyeball U",
    type = 1,
    btype = -1,
    solid = false,
    frames = {6,7, }
  }
__pulp.tiles[6] = {
    id = 6,
    fps = 2,
    name = "eyeball move",
    type = 1,
    btype = -1,
    solid = false,
    frames = {11,346, }
  }
__pulp.tiles[7] = {
    id = 7,
    fps = 2,
    name = "player-walk",
    type = 1,
    btype = -1,
    solid = false,
    frames = {9,10, }
  }
__pulp.tiles[8] = {
    id = 8,
    fps = 2,
    name = "eyeball R",
    type = 1,
    btype = -1,
    solid = false,
    frames = {348,350,348,350,348,350,348,350,355,350,348,354,348,350,348,350,348,350,348,350,348,350,348,350, }
  }
__pulp.tiles[9] = {
    id = 9,
    fps = 1,
    name = "player-touchR",
    type = 1,
    btype = -1,
    solid = false,
    frames = {12, }
  }
__pulp.tiles[10] = {
    id = 10,
    fps = 1,
    name = "player-touchL",
    type = 1,
    btype = -1,
    solid = false,
    frames = {13, }
  }
__pulp.tiles[11] = {
    id = 11,
    fps = 1,
    name = "pathL-in",
    type = 0,
    btype = -1,
    solid = true,
    frames = {14, }
  }
__pulp.tiles[12] = {
    id = 12,
    fps = 3,
    name = "player-arrow 2",
    type = 1,
    btype = -1,
    solid = false,
    frames = {20,21,22,23,24,1, }
  }
__pulp.tiles[13] = {
    id = 13,
    fps = 1,
    name = "pathR-in",
    type = 0,
    btype = -1,
    solid = true,
    frames = {15, }
  }
__pulp.tiles[14] = {
    id = 14,
    fps = 1,
    name = "pathR-out",
    type = 0,
    btype = -1,
    solid = true,
    frames = {16, }
  }
__pulp.tiles[15] = {
    id = 15,
    fps = 1,
    name = "pathL-out",
    type = 0,
    btype = -1,
    solid = true,
    frames = {17, }
  }
__pulp.tiles[16] = {
    id = 16,
    fps = 1,
    name = "grass",
    type = 0,
    btype = -1,
    solid = true,
    frames = {18, }
  }
__pulp.tiles[17] = {
    id = 17,
    fps = 1,
    name = "cactus",
    type = 0,
    btype = -1,
    solid = true,
    frames = {19, }
  }
__pulp.tiles[18] = {
    id = 18,
    fps = 1,
    name = "treetop",
    type = 0,
    btype = -1,
    solid = true,
    frames = {25, }
  }
__pulp.tiles[19] = {
    id = 19,
    fps = 1,
    name = "treetrunk",
    type = 0,
    btype = -1,
    solid = true,
    frames = {26, }
  }
__pulp.tiles[20] = {
    id = 20,
    fps = 1,
    name = "extwall",
    type = 0,
    btype = -1,
    solid = true,
    frames = {27, }
  }
__pulp.tiles[21] = {
    id = 21,
    fps = 1,
    name = "dblDoor-bot",
    type = 0,
    btype = -1,
    solid = false,
    frames = {28, }
  }
__pulp.tiles[22] = {
    id = 22,
    fps = 1,
    name = "dblDoor-top",
    type = 0,
    btype = -1,
    solid = true,
    frames = {29, }
  }
__pulp.tiles[23] = {
    id = 23,
    fps = 1,
    name = "archL",
    type = 0,
    btype = -1,
    solid = true,
    frames = {30, }
  }
__pulp.tiles[24] = {
    id = 24,
    fps = 1,
    name = "archR",
    type = 0,
    btype = -1,
    solid = true,
    frames = {31, }
  }
__pulp.tiles[25] = {
    id = 25,
    fps = 1,
    name = "archR-bot",
    type = 0,
    btype = -1,
    solid = true,
    frames = {32, }
  }
__pulp.tiles[26] = {
    id = 26,
    fps = 1,
    name = "archL-bot",
    type = 0,
    btype = -1,
    solid = true,
    frames = {33, }
  }
__pulp.tiles[27] = {
    id = 27,
    fps = 1,
    name = "extwall-L",
    type = 0,
    btype = -1,
    solid = true,
    frames = {34, }
  }
__pulp.tiles[28] = {
    id = 28,
    fps = 1,
    name = "extwall-R",
    type = 0,
    btype = -1,
    solid = true,
    frames = {35, }
  }
__pulp.tiles[29] = {
    id = 29,
    fps = 1,
    name = "wall-top",
    type = 0,
    btype = -1,
    solid = true,
    frames = {36, }
  }
__pulp.tiles[30] = {
    id = 30,
    fps = 1,
    name = "wall-topR",
    type = 0,
    btype = -1,
    solid = true,
    frames = {37, }
  }
__pulp.tiles[31] = {
    id = 31,
    fps = 1,
    name = "wall-topL",
    type = 0,
    btype = -1,
    solid = true,
    frames = {38, }
  }
__pulp.tiles[32] = {
    id = 32,
    fps = 1,
    name = "window",
    type = 0,
    btype = -1,
    solid = true,
    frames = {39, }
  }
__pulp.tiles[33] = {
    id = 33,
    fps = 1,
    name = "sign-top",
    type = 0,
    btype = -1,
    solid = false,
    frames = {40, }
  }
__pulp.tiles[34] = {
    id = 34,
    fps = 3,
    name = "windowDude",
    type = 0,
    btype = -1,
    solid = true,
    frames = {39,39,39,39,39,39,39,41,42,43,44,45,48,49,52,47,47,47,48,45,42,50,48,51, }
  }
__pulp.tiles[35] = {
    id = 35,
    fps = 1,
    name = "sign-bot",
    type = 0,
    btype = -1,
    solid = false,
    frames = {46, }
  }
__pulp.tiles[36] = {
    id = 36,
    fps = 1,
    name = "sign-R",
    type = 0,
    btype = -1,
    solid = false,
    frames = {53, }
  }
__pulp.tiles[37] = {
    id = 37,
    fps = 1,
    name = "sign-L",
    type = 0,
    btype = -1,
    solid = false,
    frames = {54, }
  }
__pulp.tiles[38] = {
    id = 38,
    fps = 1,
    name = "sign-topL",
    type = 0,
    btype = -1,
    solid = false,
    frames = {55, }
  }
__pulp.tiles[39] = {
    id = 39,
    fps = 1,
    name = "sign-topR",
    type = 0,
    btype = -1,
    solid = false,
    frames = {56, }
  }
__pulp.tiles[40] = {
    id = 40,
    fps = 1,
    name = "sign-botR",
    type = 0,
    btype = -1,
    solid = false,
    frames = {57, }
  }
__pulp.tiles[41] = {
    id = 41,
    fps = 1,
    name = "sign-botL",
    type = 0,
    btype = -1,
    solid = false,
    frames = {58, }
  }
__pulp.tiles[42] = {
    id = 42,
    fps = 1,
    name = "A",
    type = 0,
    btype = -1,
    solid = true,
    frames = {59, }
  }
__pulp.tiles[43] = {
    id = 43,
    fps = 1,
    name = "R",
    type = 0,
    btype = -1,
    solid = true,
    frames = {60, }
  }
__pulp.tiles[44] = {
    id = 44,
    fps = 1,
    name = "T",
    type = 0,
    btype = -1,
    solid = true,
    frames = {61, }
  }
__pulp.tiles[45] = {
    id = 45,
    fps = 1,
    name = "intwallTop",
    type = 0,
    btype = -1,
    solid = true,
    frames = {62, }
  }
__pulp.tiles[46] = {
    id = 46,
    fps = 1,
    name = "intwall-R",
    type = 0,
    btype = -1,
    solid = true,
    frames = {63, }
  }
__pulp.tiles[47] = {
    id = 47,
    fps = 1,
    name = "intwall-L",
    type = 0,
    btype = -1,
    solid = true,
    frames = {64, }
  }
__pulp.tiles[48] = {
    id = 48,
    fps = 1,
    name = "intwall-top-L",
    type = 0,
    btype = -1,
    solid = true,
    frames = {65, }
  }
__pulp.tiles[49] = {
    id = 49,
    fps = 1,
    name = "intwallBot-L",
    type = 0,
    btype = -1,
    solid = true,
    frames = {66, }
  }
__pulp.tiles[50] = {
    id = 50,
    fps = 1,
    name = "intwallBot-R 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {67, }
  }
__pulp.tiles[51] = {
    id = 51,
    fps = 1,
    name = "intwall-top-R",
    type = 0,
    btype = -1,
    solid = true,
    frames = {68, }
  }
__pulp.tiles[52] = {
    id = 52,
    fps = 1,
    name = "extwall 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {69, }
  }
__pulp.tiles[53] = {
    id = 53,
    fps = 1,
    name = "extwall 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {35, }
  }
__pulp.tiles[54] = {
    id = 54,
    fps = 1,
    name = "intwallBot 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {70, }
  }
__pulp.tiles[55] = {
    id = 55,
    fps = 1,
    name = "intwall-top-L 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {71, }
  }
__pulp.tiles[56] = {
    id = 56,
    fps = 1,
    name = "intwall-L 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {72, }
  }
__pulp.tiles[57] = {
    id = 57,
    fps = 1,
    name = "intwall-L 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {73, }
  }
__pulp.tiles[58] = {
    id = 58,
    fps = 1,
    name = "intwall-L 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {74, }
  }
__pulp.tiles[59] = {
    id = 59,
    fps = 1,
    name = "intwallBOT",
    type = 0,
    btype = -1,
    solid = true,
    frames = {75, }
  }
__pulp.tiles[60] = {
    id = 60,
    fps = 1,
    name = "intwall-L 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {76, }
  }
__pulp.tiles[61] = {
    id = 61,
    fps = 1,
    name = "intwall-R 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {77, }
  }
__pulp.tiles[62] = {
    id = 62,
    fps = 1,
    name = "intwall-L 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {78, }
  }
__pulp.tiles[63] = {
    id = 63,
    fps = 1,
    name = "intwall-L 7",
    type = 0,
    btype = -1,
    solid = true,
    frames = {79, }
  }
__pulp.tiles[64] = {
    id = 64,
    fps = 1,
    name = "intwallTop 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {80, }
  }
__pulp.tiles[65] = {
    id = 65,
    fps = 1,
    name = "intwallBot 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {81, }
  }
__pulp.tiles[66] = {
    id = 66,
    fps = 1,
    name = "intWall-texture",
    type = 0,
    btype = -1,
    solid = true,
    frames = {82, }
  }
__pulp.tiles[67] = {
    id = 67,
    fps = 1,
    name = "frame-bot",
    type = 0,
    btype = -1,
    solid = true,
    frames = {83, }
  }
__pulp.tiles[68] = {
    id = 68,
    fps = 1,
    name = "frame-top",
    type = 0,
    btype = -1,
    solid = true,
    frames = {84, }
  }
__pulp.tiles[69] = {
    id = 69,
    fps = 1,
    name = "frame-botR",
    type = 0,
    btype = -1,
    solid = true,
    frames = {85, }
  }
__pulp.tiles[70] = {
    id = 70,
    fps = 1,
    name = "frame-R",
    type = 0,
    btype = -1,
    solid = true,
    frames = {86, }
  }
__pulp.tiles[71] = {
    id = 71,
    fps = 1,
    name = "frame-topR",
    type = 0,
    btype = -1,
    solid = true,
    frames = {87, }
  }
__pulp.tiles[72] = {
    id = 72,
    fps = 1,
    name = "frame-topL",
    type = 0,
    btype = -1,
    solid = true,
    frames = {88, }
  }
__pulp.tiles[73] = {
    id = 73,
    fps = 1,
    name = "frame-L",
    type = 0,
    btype = -1,
    solid = true,
    frames = {89, }
  }
__pulp.tiles[74] = {
    id = 74,
    fps = 1,
    name = "frame-botL",
    type = 0,
    btype = -1,
    solid = true,
    frames = {90, }
  }
__pulp.tiles[75] = {
    id = 75,
    fps = 1,
    name = "art-tag",
    type = 0,
    btype = -1,
    solid = true,
    frames = {91, }
  }
__pulp.tiles[76] = {
    id = 76,
    fps = 1,
    name = "plinth",
    type = 0,
    btype = -1,
    solid = true,
    frames = {92, }
  }
__pulp.tiles[77] = {
    id = 77,
    fps = 1,
    name = "intwall-R 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {93, }
  }
__pulp.tiles[78] = {
    id = 78,
    fps = 1,
    name = "intwall-L 8",
    type = 0,
    btype = -1,
    solid = true,
    frames = {94, }
  }
__pulp.tiles[79] = {
    id = 79,
    fps = 1,
    name = "archL 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {95, }
  }
__pulp.tiles[80] = {
    id = 80,
    fps = 1,
    name = "archR 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {96, }
  }
__pulp.tiles[81] = {
    id = 81,
    fps = 1,
    name = "archR-bot 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {97, }
  }
__pulp.tiles[82] = {
    id = 82,
    fps = 1,
    name = "archL-bot 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {98, }
  }
__pulp.tiles[83] = {
    id = 83,
    fps = 1,
    name = "art center",
    type = 0,
    btype = -1,
    solid = false,
    frames = {99, }
  }
__pulp.tiles[84] = {
    id = 84,
    fps = 1,
    name = "art center 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {100, }
  }
__pulp.tiles[85] = {
    id = 85,
    fps = 1,
    name = "art center 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {101, }
  }
__pulp.tiles[86] = {
    id = 86,
    fps = 2,
    name = "patron1 sam",
    type = 2,
    btype = 0,
    solid = true,
    says = "Art is moment is truth.",    frames = {102,102,102,102,102,102,102,102,102,102,103,103,103, }
  }
__pulp.tiles[87] = {
    id = 87,
    fps = 1,
    name = "patron2 cynthia",
    type = 2,
    btype = 0,
    solid = true,
    says = "There is.. versimilitude and transience in Art.",    frames = {106,104, }
  }
__pulp.tiles[88] = {
    id = 88,
    fps = 1,
    name = "deskL",
    type = 0,
    btype = -1,
    solid = true,
    frames = {105, }
  }
__pulp.tiles[89] = {
    id = 89,
    fps = 1,
    name = "deskR",
    type = 0,
    btype = -1,
    solid = true,
    frames = {107, }
  }
__pulp.tiles[90] = {
    id = 90,
    fps = 1,
    name = "velvet rope-L",
    type = 0,
    btype = -1,
    solid = true,
    frames = {108, }
  }
__pulp.tiles[91] = {
    id = 91,
    fps = 1,
    name = "velvet rope-R",
    type = 0,
    btype = -1,
    solid = true,
    frames = {109, }
  }
__pulp.tiles[92] = {
    id = 92,
    fps = 1,
    name = "velvet rope-Center",
    type = 2,
    btype = 0,
    solid = true,
    says = "temporarily closed for remodeling",    frames = {110, }
  }
__pulp.tiles[93] = {
    id = 93,
    fps = 2,
    name = "attendant",
    type = 2,
    btype = 0,
    solid = true,
    says = "Welcome to ARTARTARTARTARTARTART! We don't answer questions here. Please enjoy!",    frames = {111,111,111,111,111,111,111,111,111,401,111,111,111,111,401, }
  }
__pulp.tiles[94] = {
    id = 94,
    fps = 1,
    name = "intWall-texture 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {112, }
  }
__pulp.tiles[95] = {
    id = 95,
    fps = 1,
    name = "intWall-texture 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {113, }
  }
__pulp.tiles[96] = {
    id = 96,
    fps = 1,
    name = "art-tag 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {114, }
  }
__pulp.tiles[97] = {
    id = 97,
    fps = 1,
    name = "art-tag 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {115, }
  }
__pulp.tiles[98] = {
    id = 98,
    fps = 1,
    name = "art-tag 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {116, }
  }
__pulp.tiles[99] = {
    id = 99,
    fps = 1,
    name = "art-tag 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {117, }
  }
__pulp.tiles[100] = {
    id = 100,
    fps = 1,
    name = "art-tag 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {118, }
  }
__pulp.tiles[101] = {
    id = 101,
    fps = 1,
    name = "art-tag 7",
    type = 0,
    btype = -1,
    solid = true,
    frames = {119, }
  }
__pulp.tiles[102] = {
    id = 102,
    fps = 1,
    name = "art-tag 8",
    type = 0,
    btype = -1,
    solid = true,
    frames = {120, }
  }
__pulp.tiles[103] = {
    id = 103,
    fps = 3,
    name = "viewsymbol",
    type = 0,
    btype = -1,
    solid = false,
    frames = {122,122,122,122,122,121,121, }
  }
__pulp.tiles[104] = {
    id = 104,
    fps = 1,
    name = "signpost-Studios",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n Artist Studios \n down the hall\n",    frames = {123, }
  }
__pulp.tiles[105] = {
    id = 105,
    fps = 1,
    name = "open door wall",
    type = 0,
    btype = -1,
    solid = true,
    frames = {124, }
  }
__pulp.tiles[106] = {
    id = 106,
    fps = 1,
    name = "entrance",
    type = 0,
    btype = -1,
    solid = false,
    frames = {125, }
  }
__pulp.tiles[107] = {
    id = 107,
    fps = 1,
    name = "intwall-L 9",
    type = 0,
    btype = -1,
    solid = true,
    frames = {126, }
  }
__pulp.tiles[108] = {
    id = 108,
    fps = 1,
    name = "signpost-Studios 2",
    type = 2,
    btype = 0,
    solid = true,
    says = "\nSculpture grounds down the hall",    frames = {123, }
  }
__pulp.tiles[109] = {
    id = 109,
    fps = 1,
    name = "pathL-out 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {127, }
  }
__pulp.tiles[110] = {
    id = 110,
    fps = 1,
    name = "grass-walk",
    type = 0,
    btype = -1,
    solid = false,
    frames = {18, }
  }
__pulp.tiles[111] = {
    id = 111,
    fps = 1,
    name = "cactus walk",
    type = 0,
    btype = -1,
    solid = false,
    frames = {19, }
  }
__pulp.tiles[112] = {
    id = 112,
    fps = 3,
    name = "windowDude 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,39,41,42,43,44,45,48,49,52,47,128,129,48,45,42,50,48,51, }
  }
__pulp.tiles[113] = {
    id = 113,
    fps = 1,
    name = "7",
    type = 0,
    btype = -1,
    solid = true,
    frames = {130, }
  }
__pulp.tiles[114] = {
    id = 114,
    fps = 1,
    name = "intWall-txtWalk",
    type = 0,
    btype = -1,
    solid = false,
    frames = {82, }
  }
__pulp.tiles[115] = {
    id = 115,
    fps = 0,
    name = "dblCrowArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,1,1,1,1,1,1,132,133,134,135,1,1,136,2,137,1,1,1,138,139,140,141,1,1,143,142,144,145,1,1,1,268,269,270,271,1,272,273,274,275,276,1,277,278,279,280,1, }
  }
__pulp.tiles[116] = {
    id = 116,
    fps = 0,
    name = "doogArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {2,2,281,282,2,2,2,283,284,285,286,2,287,288,289,290,291,2,2,292,293,294,295,2,2,296,297,298,299,2,2,300,301,302,303,2,304,305,306,307,308,2,309,310,311,312,2,2, }
  }
__pulp.tiles[117] = {
    id = 117,
    fps = 3,
    name = "blank-eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'xxx' \n\nXxxxx, 20XX",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[118] = {
    id = 118,
    fps = 0,
    name = "nophotoArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {149,150,151,152,153,155,154,156,157,158,159,160,161,162,163,164,166,167,165,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,2,192,193,194,2,313,314,189,315,316,316,317,2,318,319,320,321,189,322,2,2,323,2,324,2,325,326,189,322,2,2,328,327,329,2,330,331,189,277,332,332,332,332,332,332,333,334,335,336,336,336,336,336,336,336,336,337, }
  }
__pulp.tiles[119] = {
    id = 119,
    fps = 3,
    name = "nophoto-eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'No Photo' \n\nLedbetter, 2022\n@LDBR_art\nArt of Art of Art telling you not to reproduce the Art. The Artist disagrees, humbly. Please reproduce at your leisure. We Do appreciate attribution.\n\n-- ART7",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[120] = {
    id = 120,
    fps = 0,
    name = "triptychTplt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {338,338,338,338,338,338,338,339,338,338,338,338,338,338,338,340,338,338,341,338,338,338,338,338,338,338,338,338,342,338,338,343,338,344,338,338,338,338,338,338,338,345,338,338,338,338,338,338,338,338, }
  }
__pulp.tiles[121] = {
    id = 121,
    fps = 2,
    name = "eyeball L",
    type = 1,
    btype = -1,
    solid = false,
    frames = {8,349,8,349,8,349,8,352,8,349,8,349,8,349,353,349, }
  }
__pulp.tiles[122] = {
    id = 122,
    fps = 3,
    name = "dapperdoog-eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Dapper Doog' \n\nLedbetter, 2015\n@LDBR_art\nNew Years Eve means everyone dresses their best. Even Doogs. This is Dooglas Stanton von Woofington and he was a very, very good boy. And he is missed every day.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[123] = {
    id = 123,
    fps = 2,
    name = "eyeball D",
    type = 1,
    btype = -1,
    solid = false,
    frames = {347,351,347,7,347,351,347,351,347,351,347,351,6,351,347,351,347, }
  }
__pulp.tiles[124] = {
    id = 124,
    fps = 1,
    name = "eyeball sleep",
    type = 1,
    btype = -1,
    solid = false,
    frames = {356,357,358,359,356,357,358,359,354,354,354,356,356,354,354, }
  }
__pulp.tiles[125] = {
    id = 125,
    fps = 1,
    name = "intWall-texture 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {362, }
  }
__pulp.tiles[126] = {
    id = 126,
    fps = 1,
    name = "intwall-R 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {363, }
  }
__pulp.tiles[127] = {
    id = 127,
    fps = 1,
    name = "cactus 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {364, }
  }
__pulp.tiles[128] = {
    id = 128,
    fps = 1,
    name = "intwall-top-R 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {366, }
  }
__pulp.tiles[129] = {
    id = 129,
    fps = 1,
    name = "open door",
    type = 0,
    btype = -1,
    solid = true,
    frames = {365, }
  }
__pulp.tiles[130] = {
    id = 130,
    fps = 1,
    name = "intwall-R 7",
    type = 0,
    btype = -1,
    solid = true,
    frames = {363, }
  }
__pulp.tiles[131] = {
    id = 131,
    fps = 1,
    name = "intwall-L 10",
    type = 0,
    btype = -1,
    solid = false,
    frames = {94, }
  }
__pulp.tiles[132] = {
    id = 132,
    fps = 1,
    name = "grass 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {367, }
  }
__pulp.tiles[133] = {
    id = 133,
    fps = 1,
    name = "pathR-out 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {368, }
  }
__pulp.tiles[134] = {
    id = 134,
    fps = 1,
    name = "pathL-in 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {369, }
  }
__pulp.tiles[135] = {
    id = 135,
    fps = 0,
    name = "cactusArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,1,1,1,1,1,370,371,372,373,1,1,402,403,404,405,406,1,407,408,409,410,411,1,412,614,615,616,617,618,619,620,621,622,623,624,1,625,626,627,1,628,1,629,2,630,1,1, }
  }
__pulp.tiles[136] = {
    id = 136,
    fps = 1,
    name = "tile 136",
    type = 0,
    btype = -1,
    solid = true,
    frames = {374, }
  }
__pulp.tiles[137] = {
    id = 137,
    fps = 1,
    name = "tile 137",
    type = 0,
    btype = -1,
    solid = true,
    frames = {375, }
  }
__pulp.tiles[138] = {
    id = 138,
    fps = 1,
    name = "tile 138",
    type = 0,
    btype = -1,
    solid = true,
    frames = {376, }
  }
__pulp.tiles[139] = {
    id = 139,
    fps = 1,
    name = "intwallBot 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {377, }
  }
__pulp.tiles[140] = {
    id = 140,
    fps = 1,
    name = "signpost-Studios 3",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n Rooftop Terrace",    frames = {123, }
  }
__pulp.tiles[141] = {
    id = 141,
    fps = 1,
    name = "velvet rope-R 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {378, }
  }
__pulp.tiles[142] = {
    id = 142,
    fps = 1,
    name = "tile 142",
    type = 0,
    btype = -1,
    solid = false,
    frames = {379, }
  }
__pulp.tiles[143] = {
    id = 143,
    fps = 1,
    name = "guard rail",
    type = 0,
    btype = -1,
    solid = true,
    frames = {380, }
  }
__pulp.tiles[144] = {
    id = 144,
    fps = 1,
    name = "locker top",
    type = 0,
    btype = -1,
    solid = false,
    frames = {386, }
  }
__pulp.tiles[145] = {
    id = 145,
    fps = 1,
    name = "toilet",
    type = 2,
    btype = 0,
    solid = true,
    says = "FLUUUSHHHH!",    frames = {382, }
  }
__pulp.tiles[146] = {
    id = 146,
    fps = 1,
    name = "shower",
    type = 0,
    btype = -1,
    solid = false,
    frames = {383,381,385, }
  }
__pulp.tiles[147] = {
    id = 147,
    fps = 1,
    name = "drain",
    type = 0,
    btype = -1,
    solid = false,
    frames = {384, }
  }
__pulp.tiles[148] = {
    id = 148,
    fps = 1,
    name = "back arrow",
    type = 0,
    btype = -1,
    solid = false,
    frames = {146, }
  }
__pulp.tiles[149] = {
    id = 149,
    fps = 3,
    name = "bleh-eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Bleh!'\n\nLedbetter, 2022\n@LDBR_art\nOur childhood toys resonate with our older selves like sense memories, ripples of time recurring in our lives, fondness for a period of life free of the growing pressures of Today. This Flexiface Finger Puppet was a treasured time for the artist. \nA remembered passion bought at a faire and lost along the way.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[150] = {
    id = 150,
    fps = 1,
    name = "signpost-overview3",
    type = 2,
    btype = 0,
    solid = true,
    says = "ART7 - created by\n    Ledbetter \n    @LDBR_art\nIn service to the community. Please enjoy exploring the grounds and look forward to future showings! \n--Inspired by Scratching Post Studio's Gameboy Camera Gallery on itch.io, and the Gameboy Camera community.",    frames = {148, }
  }
__pulp.tiles[151] = {
    id = 151,
    fps = 1,
    name = "locker top 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {387, }
  }
__pulp.tiles[152] = {
    id = 152,
    fps = 1,
    name = "locker top 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {388, }
  }
__pulp.tiles[153] = {
    id = 153,
    fps = 1,
    name = "rr stall door",
    type = 0,
    btype = -1,
    solid = false,
    frames = {389, }
  }
__pulp.tiles[154] = {
    id = 154,
    fps = 1,
    name = "intwall-R 9",
    type = 0,
    btype = -1,
    solid = true,
    frames = {390, }
  }
__pulp.tiles[155] = {
    id = 155,
    fps = 1,
    name = "rr stall",
    type = 0,
    btype = -1,
    solid = true,
    frames = {391, }
  }
__pulp.tiles[156] = {
    id = 156,
    fps = 1,
    name = "intwall-L 11",
    type = 0,
    btype = -1,
    solid = true,
    frames = {392, }
  }
__pulp.tiles[157] = {
    id = 157,
    fps = 1,
    name = "intwall-L 12",
    type = 0,
    btype = -1,
    solid = true,
    frames = {393, }
  }
__pulp.tiles[158] = {
    id = 158,
    fps = 1,
    name = "intWall-texture 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {394, }
  }
__pulp.tiles[159] = {
    id = 159,
    fps = 1,
    name = "intwall-R 11",
    type = 0,
    btype = -1,
    solid = true,
    frames = {395, }
  }
__pulp.tiles[160] = {
    id = 160,
    fps = 1,
    name = "intwall-R 12",
    type = 0,
    btype = -1,
    solid = true,
    frames = {93, }
  }
__pulp.tiles[161] = {
    id = 161,
    fps = 1,
    name = "grass 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {396, }
  }
__pulp.tiles[162] = {
    id = 162,
    fps = 1,
    name = "patron3-handi",
    type = 2,
    btype = 0,
    solid = true,
    says = "I know I'm not supposed to be in here.. but I HAD to go!",    frames = {397,398, }
  }
__pulp.tiles[163] = {
    id = 163,
    fps = 2,
    name = "patron4-stall",
    type = 2,
    btype = 0,
    solid = true,
    says = "ummmm.. \n\nPrivacy PLEASE!",    frames = {399,399,399,399,399,399,400, }
  }
__pulp.tiles[164] = {
    id = 164,
    fps = 1,
    name = "intwall-L 13",
    type = 0,
    btype = -1,
    solid = true,
    frames = {392, }
  }
__pulp.tiles[165] = {
    id = 165,
    fps = 1,
    name = "intWall-texture 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {394, }
  }
__pulp.tiles[166] = {
    id = 166,
    fps = 1,
    name = "intwall-L 14",
    type = 0,
    btype = -1,
    solid = true,
    frames = {393, }
  }
__pulp.tiles[167] = {
    id = 167,
    fps = 1,
    name = "velvet rope-Center 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {413, }
  }
__pulp.tiles[168] = {
    id = 168,
    fps = 0,
    name = "wendyPoolArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {414,415,416,417,418,419,420,421,422,423,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,280,447,1,1,448,449,450,451,452,453,454,455,456,457,458,459,460,1,461,462,463,464,465,466,467,468,1,469,470,471,472,473,474,475,333,1,1,476,477,478,479,1,480,481,482,483,484,485,1,1,1,1,486,487,488,489,490,1,1,491,492,493,494,469,495,1,496,1,493,497,498,499,500,501,187,502,503,504,505,506,507,508,1,1,469,509,510,511,512,513,514,1,515,419,419,516,517,1,518,519,1,520,521,522,1,1,523,1,524,525,526, }
  }
__pulp.tiles[169] = {
    id = 169,
    fps = 0,
    name = "overallcbArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,527,528,529,530,531,532,301,533,534,535,536,537,538,539,540,541,542,1,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,363,581, }
  }
__pulp.tiles[170] = {
    id = 170,
    fps = 3,
    name = "overall-eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Overall Cowboys' \nLedbetter, 2022\n@LDBR_art\nNate and the Actor Who Plays Nate in the Movie. Back to back and better than ever.\n",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[171] = {
    id = 171,
    fps = 0,
    name = "samPlayArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,660,666,667,668,669,670,671,672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,705,706,707,708,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,692,726,727,728,729,730,731,732,733,734,735,736,737,738,739,740,741,742,743,744,745,746, }
  }
__pulp.tiles[172] = {
    id = 172,
    fps = 3,
    name = "samPlay eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Tile Showroom of Ski Play' \n\nSamPlay, 2022\nSki play made by SamPlay is an arcade game for Playdate made with Pulp. Try it on itch.io!",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[173] = {
    id = 173,
    fps = 1,
    name = "water",
    type = 0,
    btype = -1,
    solid = false,
    frames = {747, }
  }
__pulp.tiles[174] = {
    id = 174,
    fps = 1,
    name = "poolTile",
    type = 0,
    btype = -1,
    solid = false,
    frames = {748, }
  }
__pulp.tiles[175] = {
    id = 175,
    fps = 1,
    name = "poolTile 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {749, }
  }
__pulp.tiles[176] = {
    id = 176,
    fps = 1,
    name = "poolTile 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {750, }
  }
__pulp.tiles[177] = {
    id = 177,
    fps = 1,
    name = "poolTile corner",
    type = 0,
    btype = -1,
    solid = false,
    frames = {751, }
  }
__pulp.tiles[178] = {
    id = 178,
    fps = 3,
    name = "dblCrow-eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Harwin Crow' \n\nLedbetter, 2022\n@LDBR_art\nHarwin Crows on the streets, double exposed, still reposed, combing the lots and spots for your Crumbs and Castaways.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[179] = {
    id = 179,
    fps = 1,
    name = "poolTile corner",
    type = 0,
    btype = -1,
    solid = false,
    frames = {752, }
  }
__pulp.tiles[180] = {
    id = 180,
    fps = 1,
    name = "poolTile corner 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {753, }
  }
__pulp.tiles[181] = {
    id = 181,
    fps = 1,
    name = "poolTile corner 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {754, }
  }
__pulp.tiles[182] = {
    id = 182,
    fps = 1,
    name = "poolTile corner 4",
    type = 0,
    btype = -1,
    solid = false,
    frames = {755, }
  }
__pulp.tiles[183] = {
    id = 183,
    fps = 1,
    name = "water ladder",
    type = 0,
    btype = -1,
    solid = false,
    frames = {756, }
  }
__pulp.tiles[184] = {
    id = 184,
    fps = 0,
    name = "sweetSkeleArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,757,1,1,1,758,759,760,761,762,763,764,765,766,1,1,1,1,767,768,515,1,469,769,770,771,772,773,774,775,776,1,1,1,1,1,1,777,778,779,780,781,782,783,784,785,1,1,1,1,1,1,1,1,1,786,787,788,789,790,791,792,793,1,1,1,1,1,1,1,1,794,795,796,797,798,799,419,1,1,1,1,1,1,1,1,1,800,801,802,803,804,805,806,807,1,1,1,1,493,808,809,810,811,812,813,814,815,816,817,1,1,1,1,1,818,1,1,1,819,820,821,822,823,824,825,826,1,1,1,1,827,828,829,1,830,1,831,832,833,834,277,835,1, }
  }
__pulp.tiles[185] = {
    id = 185,
    fps = 3,
    name = "sweet eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Sweet Skeleton' \n\nLedbetter, 2020\n@LDBR_art\nModel: Robyn H. showing her sweet side and her Bone Structure.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[186] = {
    id = 186,
    fps = 1,
    name = "tile 186",
    type = 2,
    btype = 0,
    solid = true,
    says = " \n Sculpture here",    frames = {836, }
  }
__pulp.tiles[187] = {
    id = 187,
    fps = 3,
    name = "anomalyItem",
    type = 3,
    btype = 1,
    solid = false,
    frames = {360,960,961,962, }
  }
__pulp.tiles[188] = {
    id = 188,
    fps = 1,
    name = "plinth",
    type = 0,
    btype = -1,
    solid = true,
    frames = {361, }
  }
__pulp.tiles[189] = {
    id = 189,
    fps = 1,
    name = "plinth 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {837, }
  }
__pulp.tiles[190] = {
    id = 190,
    fps = 1,
    name = "plinth 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {838, }
  }
__pulp.tiles[191] = {
    id = 191,
    fps = 1,
    name = "plinth 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {839, }
  }
__pulp.tiles[192] = {
    id = 192,
    fps = 1,
    name = "plinth 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {840, }
  }
__pulp.tiles[193] = {
    id = 193,
    fps = 1,
    name = "plinth 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {841, }
  }
__pulp.tiles[194] = {
    id = 194,
    fps = 1,
    name = "plinth 7",
    type = 0,
    btype = -1,
    solid = true,
    frames = {842, }
  }
__pulp.tiles[195] = {
    id = 195,
    fps = 1,
    name = "plinth 8",
    type = 0,
    btype = -1,
    solid = true,
    frames = {843, }
  }
__pulp.tiles[196] = {
    id = 196,
    fps = 1,
    name = "plinth 9",
    type = 0,
    btype = -1,
    solid = true,
    frames = {844, }
  }
__pulp.tiles[197] = {
    id = 197,
    fps = 1,
    name = "plinth 10",
    type = 0,
    btype = -1,
    solid = true,
    frames = {845, }
  }
__pulp.tiles[198] = {
    id = 198,
    fps = 0,
    name = "hiwayArt",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,493,846,847,1,1,1,1,848,1,1,1,1,1,1,1,849,850,851,852,853,1,854,855,856,857,858,859,860,861,862,863,864,865,866,867,868,869,870,871,872,873,874,2,2,2,875,2,876,877,878,879,880,881,882,883,884,885,2,2,2,886,887,888,889,890,2,2,891,1,892,893,1,469,894,895,890,896,897,898,2,2,2,899,900,1,1,901,902,1,1, }
  }
__pulp.tiles[199] = {
    id = 199,
    fps = 3,
    name = "portal eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'1234' \n\nLedbetter, 2022\n@LDBR_art\nWe are the electrons of \nthe universe transversing realities along galactic synapses. Every choice, every moment is a portal to a varied future. \nAs we travel linearity, we map to the universes' experience of itself. Reality isn't Simulation but Observation. We are not God, but Of God.\nKnowing this, we choose our next steps though they may not be recognizable to our waking brain. \n'1234' is a Moment in time AND a portal into chosen reality.\n",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[200] = {
    id = 200,
    fps = 2,
    name = "amorphous1",
    type = 0,
    btype = -1,
    solid = false,
    frames = {903,910,911, }
  }
__pulp.tiles[201] = {
    id = 201,
    fps = 2,
    name = "amorphous2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {904,909,912, }
  }
__pulp.tiles[202] = {
    id = 202,
    fps = 2,
    name = "amorphous3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {905,908,913, }
  }
__pulp.tiles[203] = {
    id = 203,
    fps = 2,
    name = "amorphous4",
    type = 0,
    btype = -1,
    solid = false,
    frames = {906,907,914, }
  }
__pulp.tiles[204] = {
    id = 204,
    fps = 2,
    name = "portal 1",
    type = 0,
    btype = -1,
    solid = false,
    frames = {915,916,917,925,937,501,934,918, }
  }
__pulp.tiles[205] = {
    id = 205,
    fps = 2,
    name = "portal 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {919,920,921,924,936,922,933,923, }
  }
__pulp.tiles[206] = {
    id = 206,
    fps = 2,
    name = "portal 4",
    type = 0,
    btype = -1,
    solid = false,
    frames = {926,927,928,929,935,930,932,931, }
  }
__pulp.tiles[207] = {
    id = 207,
    fps = 2,
    name = "portal 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {938,939,940,941,942,943,944,945, }
  }
__pulp.tiles[208] = {
    id = 208,
    fps = 1,
    name = "intwall-R 13",
    type = 0,
    btype = -1,
    solid = true,
    frames = {946, }
  }
__pulp.tiles[209] = {
    id = 209,
    fps = 1,
    name = "grass 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {947, }
  }
__pulp.tiles[210] = {
    id = 210,
    fps = 3,
    name = "wendypool-eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Wendy in the\n    Water' \nLedbetter, 2021\n@LDBR_art\nModel: Wendy S. enjoying an enticing afternoon in the summer sun.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[211] = {
    id = 211,
    fps = 3,
    name = "cactus-eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Safety is an Illusion' \n\nWindsor, 2019",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[212] = {
    id = 212,
    fps = 0,
    name = "blehArt",
    type = 2,
    btype = 0,
    solid = true,
    frames = {2,237,238,239,2,2,237,240,1,241,242,2,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,2,2,260,261,262,263,2,2,264,265,266,267,2,2,2,2,2,2,2, }
  }
__pulp.tiles[213] = {
    id = 213,
    fps = 1,
    name = "intwall-R 14",
    type = 0,
    btype = -1,
    solid = true,
    frames = {948, }
  }
__pulp.tiles[214] = {
    id = 214,
    fps = 1,
    name = "mop",
    type = 0,
    btype = -1,
    solid = true,
    frames = {949, }
  }
__pulp.tiles[215] = {
    id = 215,
    fps = 1,
    name = "intwall-R broom",
    type = 0,
    btype = -1,
    solid = true,
    frames = {950, }
  }
__pulp.tiles[216] = {
    id = 216,
    fps = 1,
    name = "mop 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {951, }
  }
__pulp.tiles[217] = {
    id = 217,
    fps = 3,
    name = "bouncerCarl",
    type = 2,
    btype = 0,
    solid = true,
    says = "Nope. VIP.",    frames = {952,952,952,952,952,952,952,952,953,954,953, }
  }
__pulp.tiles[218] = {
    id = 218,
    fps = 1,
    name = "velvet rope-Center 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {955, }
  }
__pulp.tiles[219] = {
    id = 219,
    fps = 1,
    name = "lounger",
    type = 0,
    btype = -1,
    solid = true,
    frames = {956, }
  }
__pulp.tiles[220] = {
    id = 220,
    fps = 1,
    name = "tile 220",
    type = 0,
    btype = -1,
    solid = false,
    frames = {957, }
  }
__pulp.tiles[221] = {
    id = 221,
    fps = 1,
    name = "lounger 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {958, }
  }
__pulp.tiles[222] = {
    id = 222,
    fps = 1,
    name = "rr stall locked",
    type = 2,
    btype = 0,
    solid = true,
    frames = {959, }
  }
__pulp.tiles[223] = {
    id = 223,
    fps = 1,
    name = "cactus 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {963, }
  }
__pulp.tiles[224] = {
    id = 224,
    fps = 1,
    name = "treetop 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {964, }
  }
__pulp.tiles[225] = {
    id = 225,
    fps = 1,
    name = "treetop 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {965, }
  }
__pulp.tiles[226] = {
    id = 226,
    fps = 0,
    name = "tile 226",
    type = 2,
    btype = 0,
    solid = true,
    frames = {966,967,968,280,758,969,970,1,971,767,767,972,973,272,974,975,976,977,1,978,979,980,981,982,983,984,985,986,978,987,988,989,990,991,992,993,994,995,986,996,997,998,999,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,473,1,331,1027,1028,1029,1030,1031,1026,996,1,1032,977,1033,1034,1035,1036,1037,1038,556,1039,1038,1040,1041,1042,1043,1044,767,1038,1045, }
  }
__pulp.tiles[227] = {
    id = 227,
    fps = 3,
    name = "texas eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'TEXAS Thataway' \n\nLedbetter, 2022\n@LDBR_art\nThis way towards the land of the Bigger.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[228] = {
    id = 228,
    fps = 1,
    name = "signpost-vip",
    type = 2,
    btype = 0,
    solid = true,
    says = "      V.I.P.\n\n POOLSIDE LOUNGE",    frames = {1046, }
  }
__pulp.tiles[229] = {
    id = 229,
    fps = 1,
    name = "grass walk",
    type = 0,
    btype = -1,
    solid = false,
    frames = {18, }
  }
__pulp.tiles[230] = {
    id = 230,
    fps = 1,
    name = "sign welcome",
    type = 2,
    btype = 0,
    solid = true,
    says = "   Welcome to      ART ART ART ART \n   ART ART ART",    frames = {123, }
  }
__pulp.tiles[231] = {
    id = 231,
    fps = 1,
    name = "signpost-main",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n  To Main Hall",    frames = {123, }
  }
__pulp.tiles[232] = {
    id = 232,
    fps = 1,
    name = "signpost-east hall",
    type = 2,
    btype = 0,
    solid = true,
    says = "\nTo Northeast Hall",    frames = {1046, }
  }
__pulp.tiles[233] = {
    id = 233,
    fps = 1,
    name = "signpost-north hall",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n  To North Hall",    frames = {123, }
  }
__pulp.tiles[234] = {
    id = 234,
    fps = 1,
    name = "signpost-west hall",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n  To West Hall",    frames = {1047, }
  }
__pulp.tiles[235] = {
    id = 235,
    fps = 1,
    name = "signpost-east hall 2",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n   To East Hall",    frames = {1046, }
  }
__pulp.tiles[236] = {
    id = 236,
    fps = 1,
    name = "signpost-NE hall",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n Northeast Hall",    frames = {1046, }
  }
__pulp.tiles[237] = {
    id = 237,
    fps = 1,
    name = "signpost-NW hall",
    type = 2,
    btype = 0,
    solid = true,
    says = "\nTo Northwest Hall",    frames = {1047, }
  }
__pulp.tiles[238] = {
    id = 238,
    fps = 1,
    name = "signpost-Studios 4",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n To Forest Path",    frames = {1047, }
  }
__pulp.tiles[239] = {
    id = 239,
    fps = 1,
    name = "signpost-ext NW hall",
    type = 2,
    btype = 0,
    solid = true,
    says = "\nTo Northwest Hall",    frames = {1046, }
  }
__pulp.tiles[240] = {
    id = 240,
    fps = 1,
    name = "patron3 jud",
    type = 2,
    btype = 0,
    solid = true,
    says = "Where there is aesthetic, there is opinion, there is message, but More than message.\nThere is Aura, there is Intent.",    frames = {1069,1069,1069,1069,1069,1048, }
  }
__pulp.tiles[241] = {
    id = 241,
    fps = 1,
    name = "signpost-vip 3",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n   Not for you",    frames = {1047, }
  }
__pulp.tiles[242] = {
    id = 242,
    fps = 1,
    name = "beach",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1049, }
  }
__pulp.tiles[243] = {
    id = 243,
    fps = 1,
    name = "beach 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1050, }
  }
__pulp.tiles[244] = {
    id = 244,
    fps = 1,
    name = "beach 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1051, }
  }
__pulp.tiles[245] = {
    id = 245,
    fps = 1,
    name = "beach 4",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1052, }
  }
__pulp.tiles[246] = {
    id = 246,
    fps = 1,
    name = "beach 5",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1053, }
  }
__pulp.tiles[247] = {
    id = 247,
    fps = 1,
    name = "grass 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1054, }
  }
__pulp.tiles[248] = {
    id = 248,
    fps = 1,
    name = "grass 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1055, }
  }
__pulp.tiles[249] = {
    id = 249,
    fps = 1,
    name = "grass 7",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1056, }
  }
__pulp.tiles[250] = {
    id = 250,
    fps = 1,
    name = "grass 8",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1057, }
  }
__pulp.tiles[251] = {
    id = 251,
    fps = 1,
    name = "treeCanopy",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1058, }
  }
__pulp.tiles[252] = {
    id = 252,
    fps = 1,
    name = "treeCanopy 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1059, }
  }
__pulp.tiles[253] = {
    id = 253,
    fps = 1,
    name = "treeCanopy 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1060, }
  }
__pulp.tiles[254] = {
    id = 254,
    fps = 1,
    name = "treeCanopy 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1061, }
  }
__pulp.tiles[255] = {
    id = 255,
    fps = 1,
    name = "treeCanopy 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1062, }
  }
__pulp.tiles[256] = {
    id = 256,
    fps = 1,
    name = "treeCanopy 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1063, }
  }
__pulp.tiles[257] = {
    id = 257,
    fps = 1,
    name = "treeCanopy 7",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1064, }
  }
__pulp.tiles[258] = {
    id = 258,
    fps = 1,
    name = "treeCanopy 8",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1065, }
  }
__pulp.tiles[259] = {
    id = 259,
    fps = 1,
    name = "treeCanopy 9",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1066, }
  }
__pulp.tiles[260] = {
    id = 260,
    fps = 1,
    name = "treeCanopy 10",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1067, }
  }
__pulp.tiles[261] = {
    id = 261,
    fps = 1,
    name = "treeCanopy 11",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1068, }
  }
__pulp.tiles[262] = {
    id = 262,
    fps = 1,
    name = "patron4 howard",
    type = 2,
    btype = 0,
    solid = true,
    says = "Art Is its Medium but also the Generative force.",    frames = {1075,1074,1075,1075,1073, }
  }
__pulp.tiles[263] = {
    id = 263,
    fps = 2,
    name = "canopyWalk",
    type = 1,
    btype = -1,
    solid = false,
    frames = {1070,1071, }
  }
__pulp.tiles[264] = {
    id = 264,
    fps = 1,
    name = "mazeWalk",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1072, }
  }
__pulp.tiles[265] = {
    id = 265,
    fps = 1,
    name = "patron5 lydia",
    type = 2,
    btype = 0,
    solid = true,
    says = "Art is creation.. \neven from destruction.",    frames = {1077,1076,1076,1076,1076, }
  }
__pulp.tiles[266] = {
    id = 266,
    fps = 3,
    name = "patron6 jenny",
    type = 2,
    btype = 0,
    solid = true,
    says = "Art is struggle!",    frames = {1078,1078,1078,1079,1079,1080,1080,1079, }
  }
__pulp.tiles[267] = {
    id = 267,
    fps = 4,
    name = "artist4 rogier",
    type = 2,
    btype = 0,
    solid = true,
    says = "This is how I Preach!",    frames = {1088,1087,1088,1087, }
  }
__pulp.tiles[268] = {
    id = 268,
    fps = 2,
    name = "patron7 jules",
    type = 2,
    btype = 0,
    solid = true,
    says = "Art is extra-\n  traditional\n \n   communication.",    frames = {1098,1097,1094,1095,1096,1097,1098,1099,1099, }
  }
__pulp.tiles[269] = {
    id = 269,
    fps = 3,
    name = "artist4 isaac",
    type = 2,
    btype = 0,
    solid = true,
    says = "I'm Trying to Show you \nwhat I SEE!",    frames = {1100,1100,1100,1100,1100,1100,1101,1100,1100,1101,1100,1100, }
  }
__pulp.tiles[270] = {
    id = 270,
    fps = 4,
    name = "artist2 wagner",
    type = 2,
    btype = 0,
    solid = true,
    says = "I can only speak\nin Symphonies!",    frames = {1106,1106,1106,1106,1106,1102,1103,1104,1105,1104, }
  }
__pulp.tiles[271] = {
    id = 271,
    fps = 2,
    name = "artist1 hugo",
    type = 2,
    btype = 0,
    solid = true,
    says = "There is no gatekeeping to ART - only to Community and \nto Market.",    frames = {1111,1111,1111,1109,1107,1109,1109, }
  }
__pulp.tiles[272] = {
    id = 272,
    fps = 2,
    name = "artist3 sylvie",
    type = 2,
    btype = 0,
    solid = true,
    says = "Art's utility is in its existence,\nits value in emotion.",    frames = {1112,1112,1110,1110,1110,1110,1110,1108,1108,1108, }
  }
__pulp.tiles[273] = {
    id = 273,
    fps = 2,
    name = "artist5 carol",
    type = 2,
    btype = 0,
    solid = true,
    says = "You are communicating what you have seen or what you endeavor to see. \n\nNo matter others' reality.",    frames = {1090,1090,1090,1090,1090,1090,1089, }
  }
__pulp.tiles[274] = {
    id = 274,
    fps = 1,
    name = "manhole",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1091, }
  }
__pulp.tiles[275] = {
    id = 275,
    fps = 0,
    name = "tile 275",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1092,1093,1113,1114,1115,1116,1117,1118,1119,1120,1121,1122,1123,1124,1125,1126,1127,1128,1129,1130,1131,1132,1133,1134,1135,1136,1137,1138,1139,1140,1141,1142,1143,1144,1145,1146,1147,1148,1149,1150,1151,1152,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1164,1165,1166,1167,1168,1169,1170,1171,1172,1173,1174,1175,1176,1177,1178,1179,1180,1181,1182,1183,1184,1185,1186,1187,1188,1189,1190,1191,1192,1193,1194,1195,1196,1197,1198,1199,1200,1201,1202,1203,1204,1205,1206,1207,1208,1209,1210, }
  }
__pulp.tiles[276] = {
    id = 276,
    fps = 3,
    name = "orkn eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'The Death of the Jade Rabbit'\n\nOrkn, 2022\nIn Chinese folk-lore it is said a Jade Rabbit lives on the Moon.\nThe Jade Rabbit is an example of pareidolia, the tendency to see meaning in random patterns.\n\nIn this piece, smaller scale dithering evokes a larger pattern of random noise. This leads the eye to resolve not order, but disorder.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[277] = {
    id = 277,
    fps = 0,
    name = "dancers1 cLean",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,1,800,1211,1212,1213,1,1,1,1,1,1,493,1214,1215,1216,1217,1,1,1,1,1,1218,1219,1220,1221,1222,515,1,1,1,1,1,469,1223,1224,1225,1226,187,1,1,1,1,1,236,1227,1228,1229,1230,1,1,1,1,1,1231,1232,1233,1234,1235,1,1,1,1,1236,267,1237,1238,1239,1240,1,1,1,1241,1242,1243,1244,1245,1246,1247,1,1,1248,1249,1250,1251,1252,1253,1254,1,1,1,1255,1256,1257,1258,1,1259,1260,1,1, }
  }
__pulp.tiles[278] = {
    id = 278,
    fps = 0,
    name = "dancers2 chestPress",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,1,1,1261,1262,1,1263,1264,1,1,1,1,1,1265,1266,1267,1268,1269,1,1,1,1,1,1270,1271,1272,1273,1274,1,1,1,1,1275,1276,1277,1278,2,1279,1,1,1,1,1280,1281,1282,1283,2,1284,1,1,1,1,1285,1286,1287,1288,1289,1,1,1,1,1,1290,900,1291,1292,1293,1,1,1,1,1,1294,1,1295,1296,1,1,1,1,1,1,1,1,1,1297,1298,1,1,1,1,1,1,1,1299,1300,1301,1,1,1, }
  }
__pulp.tiles[279] = {
    id = 279,
    fps = 0,
    name = "dancers3 dirtyDance",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,1,1,1,1,1,1,1,1,1,1,1302,1303,1304,1,1,1,1,1,1,1305,1306,1307,1308,1309,1,1,1,1,1,1,1,1310,1311,1312,1313,1314,1315,1316,187,1,1,1,1317,1318,1319,1320,1321,1322,1323,1,1,1,1324,1325,1326,1,1,1,1,1,1,1,469,1327,1328,1,1,1,1,1,1,1,1,1329,1330,1,1,1,1,1,1,1,493,1331,1332,1,1,1,1,1,1,1,1333,1334,1335,1,1,1,1, }
  }
__pulp.tiles[280] = {
    id = 280,
    fps = 0,
    name = "dancers4 finish",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1336,1337,1,1,1,1,1,1,1,1,1,1338,1339,1,1,1,1340,1341,1,1,1,1342,1343,1344,1345,1346,1347,1348,187,1,1,1,1349,1350,2,1351,1352,1353,1354,1,1,1,1355,1356,2,1357,1358,1359,1360,1,1,1,1361,1362,2,1363,1364,1365,1,1,1,1,1366,1367,1368,1369,1370,1371,1,1,1,1,1372,2,1373,1374,1375,1376,1,1,1,1,1377,1378,1,1,1379,1380,1381,1,1,1,1382,1383,1,1,1,1384,1385,1386, }
  }
__pulp.tiles[281] = {
    id = 281,
    fps = 0,
    name = "dancers5 invSplit",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1387,1388,1389,1,1,1,1,1,1,1390,1391,900,1,1,1,1,1,1,1392,1393,1394,1395,1396,1,1,1397,1398,1399,2,1400,1401,1402,333,1403,1404,1405,1406,1407,1408,1409,1410,1411,1,1,1,1,1,1,1412,900,1413,1414,1415,1,1,1,1,1,1416,1,1417,1418,1419,1,1,1,1,1,1420,1421,1,1,1,1,1,1,1,1,1,1,1,1,1, }
  }
__pulp.tiles[282] = {
    id = 282,
    fps = 0,
    name = "dancers6 tango",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,1,1,1,1,1,1422,187,1,1,1,1,1,1,1,1423,1424,1425,1426,1427,1,1,1,1,1,1,1428,1429,1430,406,1,1,1,1,1,1431,1432,1433,2,1434,1,1,1,1,1,1435,1436,1437,2,1438,1,1,1,1,1,180,1439,1440,2,1441,1,1,1,1,493,1442,1443,1444,1445,1419,1,1,1397,1446,1447,1448,1449,1450,1451,1,1,1452,1453,1454,1455,1456,1457,1458,1459,1460,1,1461,1,1,1462,1463,1464,1465,1466,1467, }
  }
__pulp.tiles[283] = {
    id = 283,
    fps = 0,
    name = "danceres7 splitCounter",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1,1,1,1,1,1,1,1,1,1,1468,1469,187,1,1,1,1,1,1,1,1,1470,1,1,1,1,1471,1,1472,1,1,1,1,1,1473,1474,1475,1476,1477,1478,1,1,1479,1480,1481,1,1,1,1,1,1482,1483,1484,1485,1486,1487,1488,1489,1490,1491,1492,1,1,1,1,1,1,1,1,1493,237,406,1,1,1494,1495,1496,1,1,1,1,1,1,1,1,1497,1498,1499,1,1,1500,1501,900,1,1,1,1,1,1,1,1,1502,1503,1504,1,1,1505,1247,1,1,1,1,1,1,1,1,1,277,1506,1507,1,1,1508,1,1,1,1,1,1,1,1,1,1,1,1509,1510,1,1,1511,1,1,1,1,1, }
  }
__pulp.tiles[284] = {
    id = 284,
    fps = 3,
    name = "dancers eye 1",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Wren Wild', 1of7\n\nLedbetter, 2019\n@LDBR_art\nSince 2014, Ledbetter has been dancing in and around Austin with his partner Misty under the duo name Wren Wild.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[285] = {
    id = 285,
    fps = 3,
    name = "dancers eye 2",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Wren Wild', 2of7\n\nLedbetter, 2019\n@LDBR_art\nEschewing normal choreography, they developed a system of signals to improvise lifts and tricks within the flow of live musical performances.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[286] = {
    id = 286,
    fps = 3,
    name = "dancers eye 3",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Wren Wild', 3of7\n\nLedbetter, 2019\n@LDBR_art\nIn this series, we see a variety of lifts captured from dance videos and practices that would be performed 'On the Fly' in the wild.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[287] = {
    id = 287,
    fps = 3,
    name = "dancers eye 4",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Wren Wild', 4of7\n\nLedbetter, 2019\n@LDBR_art\nThey adopted the name Aerial Dance Fusion to describe their style.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[288] = {
    id = 288,
    fps = 3,
    name = "dancers eye 5",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Wren Wild', 5of7\n\nLedbetter, 2019\n@LDBR_art\nAerial Dance Fusion focuses \non connection, fluidity and musicality while leaving space for lifts and tricks.",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[289] = {
    id = 289,
    fps = 3,
    name = "dancers eye 6",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Wren Wild', 6of7\n\nLedbetter, 2019\n@LDBR_art\nMisty compares the flow of the dance to moving one's body through water. ",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[290] = {
    id = 290,
    fps = 3,
    name = "dancers eye 7",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Wren Wild', 7of7\n\nLedbetter, 2019\n@LDBR_art\nConnection to one's partner through rhythm, breath, touch\nand sight -  connection to \nthe music and \nthe energy of \nthe performers and the audience - this is the basis of dance. ",    frames = {131,131,131,131,147,147, }
  }
__pulp.tiles[291] = {
    id = 291,
    fps = 1,
    name = "notYet",
    type = 2,
    btype = 0,
    solid = true,
    says = "\n   Coming Soon",    frames = {1512, }
  }
__pulp.tiles[292] = {
    id = 292,
    fps = 0,
    name = "onlyNow art",
    type = 2,
    btype = 0,
    solid = true,
    frames = {1513,1514,1515,1516,1517,1518,1519,1520,1521,1527,1519,1522,1523,1524,1525,1526,1523,1528,1529,1530,1531,1532,1533,1531,1513,1514,1515,1516,1534,1514,1535,1536,1537,1538,1539,1540,1554,1555,1556,1541,1557,1558,1559,1542,1560,1561,1562,1543,1563,1564,1565,1544,1566,1567,1568,1545,1569,1570,1571,1572,1546,1573,1574,1575,1547,1576,1577,1578,1548,1579,1580,1581,1549,1550,1582,1583,1584,1551,1585,1586,1587,1552,1588,1589,1590,1553,1591,1592,1593,1594,1595,1596,1597,1598,1599,1600,1601,1602,1603,1604, }
  }
__pulp.tiles[293] = {
    id = 293,
    fps = 3,
    name = "onlyNow eye",
    type = 2,
    btype = 0,
    solid = true,
    says = "'Only Now'\n\nLedbetter, 2022\n@LDBR_art\n'Only Now' is the first piece of artist-assisted generated works hosted by ART7. The piece you see exists only for you and only in this moment. \nWhen you leave and return to the piece, it will be a new work and you will never see it repeated. \n\nThe artwork is based on 100 interconnected frames that will form a new tapestry every time this art is accessed allowing for up to 1x10e200 pieces or functionally infinite art.",    frames = {1605,131,131,131,147,147, }
  }
__pulp.tiles[294] = {
    id = 294,
    fps = 0,
    name = "grid",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1606, }
  }
__pulp.tiles[295] = {
    id = 295,
    fps = 0,
    name = "grid 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1607, }
  }
__pulp.tiles[296] = {
    id = 296,
    fps = 0,
    name = "grid 3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1608, }
  }
__pulp.tiles[297] = {
    id = 297,
    fps = 0,
    name = "grid 4",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1609, }
  }
__pulp.tiles[298] = {
    id = 298,
    fps = 0,
    name = "grid 5",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1610, }
  }
__pulp.tiles[299] = {
    id = 299,
    fps = 0,
    name = "grid 6",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1611, }
  }
__pulp.tiles[300] = {
    id = 300,
    fps = 0,
    name = "grid 7",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1612, }
  }
__pulp.tiles[301] = {
    id = 301,
    fps = 0,
    name = "grid 8",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1613, }
  }
__pulp.tiles[302] = {
    id = 302,
    fps = 1,
    name = "waves1",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1081,1082,1083,1084,1085,1086, }
  }
__pulp.tiles[303] = {
    id = 303,
    fps = 1,
    name = "shore1",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1614, }
  }
__pulp.tiles[304] = {
    id = 304,
    fps = 1,
    name = "shore2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1615, }
  }
__pulp.tiles[305] = {
    id = 305,
    fps = 1,
    name = "shore3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1616, }
  }
__pulp.tiles[306] = {
    id = 306,
    fps = 1,
    name = "shore4",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1617,1619,1620,1621, }
  }
__pulp.tiles[307] = {
    id = 307,
    fps = 1,
    name = "shore5",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1618, }
  }
__pulp.tiles[308] = {
    id = 308,
    fps = 1,
    name = "waves2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1084,1085,1086,1081,1082,1083, }
  }
__pulp.tiles[309] = {
    id = 309,
    fps = 1,
    name = "shore6",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1622, }
  }
__pulp.tiles[310] = {
    id = 310,
    fps = 1,
    name = "guard rail 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1623, }
  }
__pulp.tiles[311] = {
    id = 311,
    fps = 1,
    name = "dblDoor-top 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1624, }
  }
__pulp.tiles[312] = {
    id = 312,
    fps = 1,
    name = "archL-bot 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1625, }
  }
__pulp.tiles[313] = {
    id = 313,
    fps = 1,
    name = "archR-bot 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1626, }
  }
__pulp.tiles[314] = {
    id = 314,
    fps = 1,
    name = "extwall 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {37, }
  }
__pulp.tiles[315] = {
    id = 315,
    fps = 2,
    name = "sewer1",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1639,1627, }
  }
__pulp.tiles[316] = {
    id = 316,
    fps = 2,
    name = "sewer2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1640, }
  }
__pulp.tiles[317] = {
    id = 317,
    fps = 2,
    name = "sewer3",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1629,1632, }
  }
__pulp.tiles[318] = {
    id = 318,
    fps = 2,
    name = "sewer4",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1630,1631, }
  }
__pulp.tiles[319] = {
    id = 319,
    fps = 2,
    name = "extwall 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1634,1637,1633, }
  }
__pulp.tiles[320] = {
    id = 320,
    fps = 2,
    name = "extwall 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1635,1638,1636, }
  }
__pulp.tiles[321] = {
    id = 321,
    fps = 1,
    name = "archR 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1641, }
  }
__pulp.tiles[322] = {
    id = 322,
    fps = 1,
    name = "lake",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1642,1643,1644, }
  }
__pulp.tiles[323] = {
    id = 323,
    fps = 1,
    name = "shore7",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1645, }
  }
__pulp.tiles[324] = {
    id = 324,
    fps = 2,
    name = "sewer5",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1628,1640, }
  }
__pulp.tiles[325] = {
    id = 325,
    fps = 1,
    name = "intwall-L 15",
    type = 0,
    btype = -1,
    solid = true,
    frames = {1646, }
  }
__pulp.tiles[326] = {
    id = 326,
    fps = 1,
    name = "movin",
    type = 2,
    btype = 1,
    solid = true,
    frames = {1647, }
  }
__pulp.tiles[327] = {
    id = 327,
    fps = 1,
    name = "back arrow 2",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1648, }
  }
__pulp.tiles[328] = {
    id = 328,
    fps = 1,
    name = "signpost-underConstruction",
    type = 2,
    btype = 0,
    solid = true,
    says = "Currently Under Construction. Come back for the full release!",    frames = {1046, }
  }
__pulp.tiles[329] = {
    id = 329,
    fps = 1,
    name = "tile 329",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1649, }
  }
__pulp.tiles[330] = {
    id = 330,
    fps = 1,
    name = "tile 330",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1650, }
  }
__pulp.tiles[331] = {
    id = 331,
    fps = 1,
    name = "tile 331",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1651, }
  }
__pulp.tiles[332] = {
    id = 332,
    fps = 1,
    name = "tile 332",
    type = 0,
    btype = -1,
    solid = false,
    frames = {1652, }
  }

__pulp.rooms = {}
__pulp.rooms[0] = {
  id = 0,
  name = "ExtEntrance",
  song = -1,
  tiles = {
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,  38,  33,  33,  33,  33,  33,  33,  33,  39,   0,   0,   0,   0,   0,   0, 255, 258, 256,
       0,   0, 255, 256,  31,  29,  29,  37,  42,  43,  44,  42,  43,  44,  42,  36,  29,  29,  29,  30,   0, 255, 259,  18, 258,
     255, 258, 257, 256,  27,  20,  20,  37,  43,  44,  42,  43,  44,  42,  43,  36,  20,  20,  20,  28, 255, 255,  18, 224, 256,
     256, 251, 256, 253,  27,  20,  20,  37,  44,  42,  43,  44,  42,  43,  44,  36,  20,  20,  20,  28, 254, 251, 224, 258, 224,
      18, 251, 252, 256,  27,  20,  20,  41,  35,  35,  35,  35,  35,  35,  35,  40,  20,  20,  20,  28, 259,  18, 255, 251, 256,
     224, 252,  18, 260,  27,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  28, 259, 225,  18, 225, 261,
     252, 258, 224, 260,  27,  32,  32,  20,  20,  20,  32,  34,  32,  20,  32,  32,  20,  32,  32,  28, 259, 251, 256, 251, 253,
     254, 251, 251, 253,  27,  32,  32,  23,  22,  24,  32,  32,  32,  20,  32,  32,  20,  32, 112,  28, 259,  18, 251, 256, 224,
     225, 224, 224,  19,  27,  20,  20,  26,  21,  25,  20,  20,  20,  20,  20,  20,  20,  20,  20,  28,  19, 251, 225, 225,  19,
     225,  19,  16,  16,  16,  16, 223,  90,  92,  91,  16,  17,  16,  16,  16,  16,  16,  16,  16,  16,  17,  19,  19,  16,  16,
      16,  16,  16,  16,  17,  16,  16,  11,   0,  14,  16,  16,  16,  17,  16,  16, 223,  16,  16,  16,  16,  16,  16, 223,  16,
     110, 111, 110, 110, 110, 223, 110, 109,   0,  13, 223,  16,  16,  16,  16,  16,  16,  16,  17,  16,  16,  16,  16,  16,  16,
      16,  16,  16,  16,  17,  16,  16, 134, 132, 133,  16,  16,  16,  16,  16,  17,  16,  16,  16,  16,  17,  16,  16,  16,  16, },
  exits = {
    {
      x = 8,
      y = 10,
      tx = 4,
      ty = 12,
      room = 2,
    nil},
    {
      x = 0,
      y = 13,
      tx = 17,
      ty = 14,
      room = 11,
    nil},
  nil},
}
__pulp.rooms[1] = {
  id = 1,
  name = "Title Card",
  song = -1,
  tiles = {
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1, 329, 330, 331, 332,   1,   1,   1,   1,  32,  32,  32,   1,   1,   1,   1,  32,  32,  32,  32,  32,  32,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,  32,   1,  32,   1,  32,  32,   1,   1,  32,  32,  32,  32,  32,  32,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,  32,  32,   1,  32,   1,   1,  32,  32,   1,   1,   1,  32,  32,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,  32,  32,  32,   1,  32,   1,   1,  32,  32,   1,   1,   1,  32,  32,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,  32,   1,  32,   1,  32,  32,  32,  32,   1,   1,   1,   1,  86,  32,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,  32,   1,   1,  32,   1,  32,   1,  32,  87,   1,   1,   1,   1,  32,  32,   1,   1,   1,   1,   1,
       1,   1,   1,   1,  32,  32,  32,  32, 149,   1,  32,   1,   1,  32,  32,   1,   1,   1,  32,  32,   1,   1,   1,   1,   1,
       1,   1,   1,  32,   1,   1,   1,   1,  32,   1,  32,   1,   1,   1,  32,  32,   1,   1,  32,  34,   1,   1, 113,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,  32,   1,  32,   1,   1,   1,   1,  32,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, },
  exits = {
  nil},
}
__pulp.rooms[2] = {
  id = 2,
  name = "galleryFoyer",
  song = -1,
  tiles = {
      54,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,
      47,  66,  66,  72,  71,  66,  66,  72,  68,  68,  68,  71,  66,  66,  72,  71,  66,  66,  72,  71,  66,  66,  66,  66,  46,
      47,  66,  66,  74,  69,  75,  66,  74,  67,  67,  67,  69,  75,  66,  74,  69,  75,  66,  74,  69,  75,  66,  79,  80,  46,
      60,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  18,  82,  81,  61,
      78,   0, 268,   0, 106,   0,   0,   0,   0,   0, 106,   0,   0,   0,   0, 106,   0,   0,   0, 106,   0,  76,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      78,   0,   0,   0,   0,   0,  65,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  64,   0,   0, 231,  90,  92,  91,  77,
      78,  17,   0,   0,   0,   0,  56,  72,  68,  68,  68,  71,  66,  72,  68,  71,  66,  57,   0,   0,   0,   0,   0,   0,  77,
      78,  76,   0,   0,   0,   0,  56,  73,  83,  85,  84,  70,  66,  73,  84,  70,  66,  57,   0,   0,   0,   0,   0,   0,  77,
      78,   0,   0,   0,   0,  18,  56,  74,  67,  67,  67,  69,  75,  74,  67,  69,  75,  57,  18,   0,   0,   0,   0,   0,  77,
      78,  93,   0,   0,   0,  76,  63,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  62,  76,   0,   0,   0,   0,  17,  77,
      78,  89,  88,   0,   0,   0,   0,   0,   0,   0, 106,   0,   0,   0, 106,   0,   0,   0,   0,   0,   0,   0,   0,  76,  77,
      78, 230,   0,   0,   0,   0, 230,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      49,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
      52,  20,  20,  23,  22,  24,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  53, },
  exits = {
    {
      x = 23,
      y = 3,
      tx = 23,
      ty = 12,
      room = 3,
    nil},
    {
      x = 22,
      y = 3,
      tx = 22,
      ty = 12,
      room = 3,
    nil},
    {
      x = 4,
      y = 13,
      tx = 8,
      ty = 11,
      room = 0,
    nil},
    {
      x = 14,
      y = 10,
      tx = 18,
      ty = 13,
      room = 48,
    nil},
    {
      x = 10,
      y = 10,
      tx = 21,
      ty = 13,
      room = 29,
    nil},
    {
      x = 19,
      y = 3,
      tx = 17,
      ty = 12,
      room = 17,
    nil},
    {
      x = 15,
      y = 3,
      tx = 17,
      ty = 12,
      room = 15,
    nil},
    {
      x = 10,
      y = 3,
      tx = 21,
      ty = 13,
      room = 24,
    nil},
    {
      x = 4,
      y = 3,
      tx = 18,
      ty = 13,
      room = 18,
    nil},
  nil},
}
__pulp.rooms[3] = {
  id = 3,
  name = "galleryMain",
  song = -1,
  tiles = {
      54,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,
      47,  66,  66,  66,  72,  71,  66,  72,  68,  68,  71,  66,  66,  66,  66,  72,  71,  66,  72,  71,  66,  66,  66,  66,  46,
      47,  79,  80,  66,  74,  69,  75,  74,  67,  67,  69,  75,  79,  80,  66,  74,  69,  75,  74,  69,  75,  66,  79,  80,  46,
      60,  82,  81,  58,  18,  58,  58,  58,  58,  58,  58,  58,  82,  81,  18,  58,  58,  58,  58,  58,  18,  58,  82,  81,  61,
      78,   0,   0, 234,  76, 106,   0,   0,   0,   0, 106, 233,   0,   0,  76,   0, 106,   0,   0, 106,  76, 235,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0, 269,   0,   0,   0,   0,   0,   0,   0,   0,  65,  45,  45,  45,  64,   0,  77,
      78,   0,   0, 273,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  56,  72,  68,  71,  57,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 186,   0,   0,   0,   0,   0,   0,  56,  73,  85,  70,  57,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  56,  74,  67,  69,  96,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  63,  58,  58,  58,  62,   0,  77,
      78,   0,   0,   0,   0, 267,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 106,   0,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      49,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
      95,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  79,  80,  94, },
  exits = {
    {
      x = 23,
      y = 3,
      tx = 8,
      ty = 12,
      room = 6,
    nil},
    {
      x = 22,
      y = 3,
      tx = 7,
      ty = 12,
      room = 6,
    nil},
    {
      x = 1,
      y = 3,
      tx = 18,
      ty = 12,
      room = 4,
    nil},
    {
      x = 2,
      y = 3,
      tx = 19,
      ty = 12,
      room = 4,
    nil},
    {
      x = 22,
      y = 13,
      tx = 22,
      ty = 4,
      room = 2,
    nil},
    {
      x = 23,
      y = 13,
      tx = 23,
      ty = 4,
      room = 2,
    nil},
    {
      x = 12,
      y = 3,
      tx = 12,
      ty = 12,
      room = 5,
    nil},
    {
      x = 13,
      y = 3,
      tx = 13,
      ty = 12,
      room = 5,
    nil},
    {
      x = 16,
      y = 3,
      tx = 18,
      ty = 13,
      room = 32,
    nil},
    {
      x = 19,
      y = 3,
      tx = 18,
      ty = 13,
      room = 26,
    nil},
    {
      x = 20,
      y = 10,
      tx = 18,
      ty = 13,
      room = 39,
    nil},
    {
      x = 10,
      y = 3,
      tx = 12,
      ty = 14,
      room = 9,
    nil},
    {
      x = 5,
      y = 3,
      tx = 17,
      ty = 12,
      room = 16,
    nil},
  nil},
}
__pulp.rooms[4] = {
  id = 4,
  name = "galleryW",
  song = -1,
  tiles = {
      54,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,
      47,  72,  71,  66,  66,  66,  72,  68,  68,  71,  66,  72,  68,  68,  71,  66,  72,  71,  66,  72,  68,  68,  71,  66,  46,
      47,  74,  69,  75,  79,  80,  74,  67,  67,  69,  75,  74,  67,  67,  69,  75,  74,  69,  75,  74,  67,  67,  69,  75,  46,
      60,  58,  58,  58,  82,  81,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  61,
      78,   0, 291,   0, 328, 328, 237,   0, 291,   0,   0,   0,   0, 291,   0,   0,   0, 291,   0,   0,   0, 291,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0, 265,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 105,
      78,  17,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  65,  45,  45,  45,  64,   0,   0,   0,   0, 233,  77,
     325,  45,  45,  45,  45,  45,  45,  64,   0,   0,   0,   0,   0,   0,  56,  72,  68,  71,  57,   0,   0,   0,   0,   0,  77,
      47,  72,  68,  68,  68,  68,  71,  57,   0,   0,   0,   0,   0,   0,  56,  73,  83,  70,  57,   0,   0, 186,   0,   0,  77,
      47,  73,  84,  85,  84,  85,  70,  57,   0,   0, 186,   0,   0,   0,  56,  74,  67,  69,  96,   0,   0,   0,   0,   0,  77,
      47,  74,  67,  67,  67,  67,  69,  96,  18,   0,   0,   0,   0,   0,  63,  58,  58,  58,  62,   0,   0,   0,   0,   0,  77,
      60,  58,  58,  58,  58,  58,  58,  62,  76,   0,   0,   0,   0,   0,   0,   0, 291,   0,   0,   0,   0,   0,   0,   0,  77,
      78,   0,   0,   0, 291,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      49,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
      95,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  79,  80,  66,  66,  66,  66,  94, },
  exits = {
    {
      x = 18,
      y = 13,
      tx = 1,
      ty = 4,
      room = 3,
    nil},
    {
      x = 19,
      y = 13,
      tx = 2,
      ty = 4,
      room = 3,
    nil},
    {
      x = 4,
      y = 3,
      tx = 18,
      ty = 13,
      room = 13,
    nil},
    {
      x = 5,
      y = 3,
      tx = 19,
      ty = 13,
      room = 13,
    nil},
    {
      x = 24,
      y = 5,
      tx = 1,
      ty = 5,
      room = 5,
    nil},
  nil},
}
__pulp.rooms[5] = {
  id = 5,
  name = "galleryN",
  song = -1,
  tiles = {
      54,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,
      47,  72,  68,  68,  71,  66,  72,  71,  66,  72,  68,  68,  68,  68,  71,  66,  72,  68,  68,  71,  66,  72,  71,  66,  46,
      47,  74,  67,  67,  69,  75,  74,  69,  75,  74,  67,  67,  67,  67,  69,  75,  74,  67,  67,  69,  75,  74,  69,  75,  46,
      60,  58,  58,  58,  58,  58,  58,  58,  18,  58,  58,  58,  58,  58,  58,  17,  58,  58,  58,  58,  58,  58,  58,  58,  61,
      78,   0,   0, 291,   0,   0,   0, 291,  76,   0,   0,   0, 291,   0,   0,  76,   0,   0, 291,   0,   0,   0, 291,   0,  77,
     107,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 105,
      78, 234,   0,   0,   0,  87,   0,   0,   0,   0,  65,  45,  45,  45,  45,  64,   0,   0,   0,   0,   0,   0,   0, 235,  77,
      78,   0,   0,  65,  45,  45,  45,  64,   0,   0,  56,  72,  68,  68,  71,  57,   0,  65,  45,  45,  45,  64,   0,   0,  77,
      78,   0,   0,  56,  72,  68,  71,  57,   0,   0,  56,  73,  85,  83,  70,  57,   0,  56,  72,  68,  71,  57,   0,   0,  77,
      78,   0,   0,  56,  73,  84,  70,  57,   0,   0,  56,  74,  67,  67,  69,  96,   0,  56,  73,  83,  70,  57,   0,   0,  77,
      78,   0,   0,  56,  74,  67,  69,  96,   0,   0,  63,  58,  58,  58,  58,  62,   0,  56,  74,  67,  69,  96,   0,   0,  77,
      78,   0,   0,  63,  58,  58,  58,  62,   0,   0,   0,   0,   0, 291,   0,   0,   0,  63,  58,  58,  58,  62,   0,   0,  77,
      78,   0,   0,   0,   0, 291,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 291,   0,   0,   0,  77,
      49,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
      95,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  79,  80,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  94, },
  exits = {
    {
      x = 12,
      y = 13,
      tx = 12,
      ty = 4,
      room = 3,
    nil},
    {
      x = 13,
      y = 13,
      tx = 13,
      ty = 4,
      room = 3,
    nil},
    {
      x = 0,
      y = 5,
      tx = 23,
      ty = 5,
      room = 4,
    nil},
    {
      x = 24,
      y = 5,
      tx = 1,
      ty = 5,
      room = 6,
    nil},
  nil},
}
__pulp.rooms[6] = {
  id = 6,
  name = "galleryE",
  song = -1,
  tiles = {
      54,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,
      47,  72,  71,  66,  72,  71,  66,  66,  66,  66,  72,  68,  68,  68,  68,  71,  66,  72,  68,  68,  68,  68,  71,  66,  46,
      47,  74,  69,  75,  74,  69,  75,  79,  80,  66,  74,  67,  67,  67,  67,  69,  75,  74,  67,  67,  67,  67,  69,  75,  46,
      60,  58,  58,  58,  58,  58,  58,  82,  81,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  61,
      78,   0, 291,   0,   0, 291, 232, 328, 328,   0,   0,   0,   0,   0,   0, 291,   0,   0,   0,   0,   0,   0, 291,   0,  77,
     107,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      78, 233,   0,   0,   0,   0,   0,   0,   0,  65,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  64,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,  56,  72,  68,  68,  71,  66,  72,  71,  66,  72,  68,  71,  57,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,  56,  73,  83,  84,  70,  66,  73,  70,  66,  73,  83,  70,  57,   0,   0,  77,
      78,   0,   0,   0, 186,   0,   0,   0,  17,  56,  74,  67,  67,  69,  75,  74,  69,  75,  74,  67,  69,  96,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,  76,  63,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  62,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 291,   0,   0, 291,   0, 266,   0, 291,   0,   0,   0,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      49,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
      95,  66,  66,  66,  66,  66,  66,  79,  80,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  94, },
  exits = {
    {
      x = 7,
      y = 13,
      tx = 22,
      ty = 4,
      room = 3,
    nil},
    {
      x = 8,
      y = 13,
      tx = 23,
      ty = 4,
      room = 3,
    nil},
    {
      x = 7,
      y = 3,
      tx = 7,
      ty = 12,
      room = 12,
    nil},
    {
      x = 8,
      y = 3,
      tx = 8,
      ty = 12,
      room = 12,
    nil},
    {
      x = 0,
      y = 5,
      tx = 23,
      ty = 5,
      room = 5,
    nil},
  nil},
}
__pulp.rooms[7] = {
  id = 7,
  name = "studioHallway",
  song = -1,
  tiles = {
      45,  45,  45,  51,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45, 126,   0,   0,   0,   0,  77,
      66,  66,  66,  46,  66,  72,  68,  68,  71,  66,  72,  68,  71,  66,  72,  68,  68,  71,  66, 126,   0,   0,   0,   0,  77,
      66,  66,  66,  46,  66,  74,  67,  67,  69,  75,  74,  67,  69,  75,  74,  67,  67,  69,  75, 126,   0,   0,   0,   0,  77,
      58,  58,  58,  61,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58, 126,   0,   0,   0,   0,  77,
       0,   0,   0, 105,   0,   0,   0, 291,   0,   0,   0,   0, 291,   0,   0,   0, 291,   0,   0,   0,   0,   0,   0,   0,  77,
       0,   0, 104,  77,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
       0,   0,   0,  77,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
       0,   0,   0,  77,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
       0,   0,   0,  77,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
       0,   0,   0,  77,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,
       0,   0,   0,  77,  20,  20,  20,  20, 127,  20,  20,  20, 127,  20,  20, 127,  20, 127,  20,  20,  20,  20, 127,  20,  20,
       0,   0,   0,  77,  17,  16, 223,  16,  16,  16,  17,  16,  16, 223,  16,  16,  17,  16,  16, 223,  16,  17,  16, 223,  17,
       0,   0,   0,  77,  16,  16,  16,  17,  16,  17,  16,  16,  17,  16,  16,  16,  16,  16,  16,  16,  17,  16,  16,  16,  16,
      59,  59,  59,  50,  16,  17,  16, 223,  16,  16,  17,  16,  16,  16,  16,  17,  16, 223,  16,  16,  16,  17,  16,  16,  17,
      66,  66,  66,  94,  16,  16,  16,  16,  16,  17,  16,  16,  16, 223,  16,  16,  17,  16,  16,  17,  16,  16,  16,  16,  16, },
  exits = {
    {
      x = 20,
      y = 0,
      tx = 20,
      ty = 6,
      room = 20,
    nil},
    {
      x = 21,
      y = 0,
      tx = 21,
      ty = 6,
      room = 20,
    nil},
    {
      x = 22,
      y = 0,
      tx = 22,
      ty = 6,
      room = 20,
    nil},
    {
      x = 23,
      y = 0,
      tx = 23,
      ty = 6,
      room = 20,
    nil},
    {
      x = 3,
      y = 4,
      tx = 23,
      ty = 4,
      room = 12,
    nil},
    {
      x = 2,
      y = 4,
      tx = 4,
      ty = 4,
      room = 7,
    nil},
  nil},
}
__pulp.rooms[8] = {
  id = 8,
  name = "art 6x8",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37,   1,   1,   1,   1,   1,   1,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37,   1,   1,   1,   1,   1,   1,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37,   1,   1,   1,   1,   1,   1,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37,   1,   1,   1,   1,   1,   1,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37,   1,   1,   1,   1,   1,   1,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37,   1,   1,   1,   1,   1,   1,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37,   1,   1,   1,   1,   1,   1,  36,  66,  97,  99,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37,   1,   1,   1,   1,   1,   1,  36,  66,  98, 100,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  40,  66, 211, 327,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
  nil},
}
__pulp.rooms[9] = {
  id = 9,
  name = "art triptych samPlay",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  38,  33,  33,  33,  33,  33,  39,  66,  38,  33,  33,  33,  33,  33,  39,  66,  38,  33,  33,  33,  33,  33,  39,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,  37, 171, 171, 171, 171, 171,  36,  66,
      66,  41,  35,  35,  35,  35,  35,  40,  66,  41,  35,  35,  35,  35,  35,  40,  66,  41,  35,  35,  35,  35,  35,  40,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66, 101, 102,  66,  66, 327, 187, 114, 172, 101, 102,  66,  66,  66,  66,  66,  66, 101, 102,  66, },
  exits = {
    {
      x = 10,
      y = 14,
      tx = 10,
      ty = 4,
      room = 3,
    nil},
  nil},
}
__pulp.rooms[10] = {
  id = 10,
  name = "art 16x9",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  97,  99,  66,  66,
      66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  98, 100,  66,  66,
      66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 117, 327,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
  nil},
}
__pulp.rooms[11] = {
  id = 11,
  name = "extOverview",
  song = -1,
  tiles = {
     173, 173, 173, 173, 246,  16,   1,   1,  16,  16,  16,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,
     173, 173, 173, 244, 245,  16,   1,   1,  16,  18,  18,  18,  18,   1,   1,   1,  18,  18,  18,  18,   1,   1,  18,  18,  18,
     242, 242, 242, 243,  18,  18,  18,   1,  18,  18,  18,  18,   1,   1,  18,   1,   1,  18,  18,   1,   1,   1,  18,  18,  18,
      18,  18,  18,  18,  18,  18,  18,   1,   1,   1,  18,  18,   1,  18,  18,   1,   1,   1,  18,   1,  16,  20,  20,  20,  20,
      18,  18,  18,  18,  18,  18,  18,  18,  18,   1,   1,   1,   1,  18,  18,   1,   0,   1,   1,   1,   1,  20,  20,  20,  20,
      18,   1,   1,   1,   1,   1,  18,  18,  18,  18,  18,  18,  18,  18,  18,   1,   1,   1,  16,  16,  16,  20,  20,  20,  20,
      18,   1,   1,  18,  18,   1,   1,  18,  18,  18,  18,  18,  18,  18,   1,   1,  16,  16,  16,  20,  20,  20,  20,  20,  20,
      18,  18,  18,  18,  18,  18,   1,   1,   1,   1,   1,  18,  18,   1,   1,   1,  16,   1,   1,  20,  20,  20,  20,  20,  20,
      18, 248, 249,  18,  18,  18,  18,  18,  18,  18,   1,   1,   1,   1,  16,   1,   1,   1,  18,  20,  20,  20,  20,  20,  20,
     247, 250, 250, 247, 249,  18,  18,  18,  18,  18,  18,  18,  16,  16,  16,  16,  18,  18,  18,  20,  20,  20,  20,  20,  20,
      16,  16,  16,  16,  16, 249,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  20,  20,  20,  20,  20,  20,
      16,  16,  16,  16,  16, 250, 247, 247, 247, 249,  18,  18,  18,  18,  18,  18,  18,  18,  18,  20,  20,  20,  20,  20,  20,
      16,  16,  16,  16, 150,   0,   0,   0,   0, 250, 247, 247, 247, 247, 247, 247, 247, 247, 247, 250,  16,  16,  16,  16,  16,
      16,  16,  16,  16,  16,  16,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  16,  16,  16,  16,  16,  16,  16,
      16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,   0,   0,  16,  16,  16,  16,  16,  16, },
  exits = {
    {
      x = 18,
      y = 14,
      tx = 0,
      ty = 13,
      room = 0,
    nil},
  nil},
}
__pulp.rooms[12] = {
  id = 12,
  name = "galleryNE",
  song = -1,
  tiles = {
      54,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,
      47,  72,  71,  66,  72,  71,  66,  72,  71,  66,  72,  71,  66,  72,  71,  66,  72,  71,  66,  72,  68,  71,  66,  66,  46,
      47,  74,  69,  75,  74,  69,  75,  74,  69,  75,  74,  69,  75,  74,  69,  75,  74,  69,  75,  74,  67,  69,  75,  66,  46,
      60,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  61,
      78,   0, 106,   0,   0, 106,   0,   0, 106,   0,   0, 106,   0,   0, 106,   0,   0, 106,   0,   0,   0, 106,   0,   0, 105,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 104,  77,
      78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  65,  45,  45,  45,  45,  45,  45,  64,   0,   0,  77,
      78,   0,  65,  45,  45,  45,  45,  45,  45,  45,  45,  64,   0,   0,  56,  72,  68,  68,  68,  68,  71,  57,   0,   0,  77,
      78,   0,  56,  72,  71,  66,  72,  71,  66,  72,  71,  57,   0,   0,  56,  73,  84,  83,  83,  85,  70,  57,   0,   0,  77,
      78,   0,  56,  73,  70,  66,  73,  70,  66,  73,  70,  57,   0,   0,  56,  74,  67,  67,  67,  67,  69,  96,   0,   0,  77,
      78,   0,  56,  74,  69,  75,  74,  69,  75,  74,  69,  96,   0,   0,  63,  58,  58,  58,  58,  58,  58,  62,   0,   0,  77,
      78,   0,  63,  58,  58,  58,  58,  58,  58,  58,  58,  62,   0,   0,   0,   0,   0,   0, 291, 240,   0,   0,   0,  17,  77,
      78,   0,   0,   0, 291,   0,   0, 291,   0,   0, 291,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  76,  77,
      49,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
      95,  66,  66,  66,  66,  66,  66,  79,  80,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  94, },
  exits = {
    {
      x = 7,
      y = 13,
      tx = 7,
      ty = 4,
      room = 6,
    nil},
    {
      x = 8,
      y = 13,
      tx = 8,
      ty = 4,
      room = 6,
    nil},
    {
      x = 24,
      y = 4,
      tx = 4,
      ty = 4,
      room = 7,
    nil},
    {
      x = 2,
      y = 3,
      tx = 18,
      ty = 13,
      room = 41,
    nil},
    {
      x = 5,
      y = 3,
      tx = 18,
      ty = 13,
      room = 42,
    nil},
    {
      x = 8,
      y = 3,
      tx = 18,
      ty = 13,
      room = 43,
    nil},
    {
      x = 11,
      y = 3,
      tx = 18,
      ty = 13,
      room = 44,
    nil},
    {
      x = 14,
      y = 3,
      tx = 18,
      ty = 13,
      room = 45,
    nil},
    {
      x = 17,
      y = 3,
      tx = 18,
      ty = 13,
      room = 46,
    nil},
    {
      x = 21,
      y = 3,
      tx = 21,
      ty = 13,
      room = 47,
    nil},
  nil},
}
__pulp.rooms[13] = {
  id = 13,
  name = "galleryNW",
  song = -1,
  tiles = {
      54,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,
      47,  72,  68,  68,  71,  66,  72,  68,  71,  66,  72,  71,  66,  72,  68,  71,  66,  72,  68,  68,  68,  68,  71,  66,  46,
      47,  74,  67,  67,  69,  75,  74,  67,  69,  75,  74,  69,  75,  74,  67,  69,  75,  74,  67,  67,  67,  67,  69,  75,  46,
      60,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  17,  61,
     107,   0,   0, 291,   0,   0,   0,   0, 291,   0,   0, 291,   0,   0,   0, 291,   0,   0,   0,   0, 291,   0,   0,  76,  77,
      78, 238,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      78,   0,   0,   0,   0,   0,  65,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  64,   0,   0,   0,   0,   0,   0,  77,
      78,   0,   0,   0,   0,   0,  56,  72,  68,  68,  71,  66,  72,  71,  66,  72,  71,  57,   0,   0,   0,   0,   0,   0,  77,
      78,   0,   0, 262,   0,   0,  56,  73,  85,  84,  70,  66,  73,  70,  66,  73,  70,  57,   0,   0,   0,   0,   0,   0,  77,
      78,   0,   0,   0,   0,   0,  56,  74,  67,  67,  69,  75,  74,  69,  75,  74,  69,  96,   0,   0,   0, 186,   0,   0,  77,
      78,   0,   0,   0,   0,   0,  63,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  62,   0,   0,   0,   0,   0,   0,  77,
      78,  17,   0,   0,   0,   0,   0,   0,   0, 291,   0,   0,   0, 291,   0,   0, 291,   0,   0,   0,   0,   0,   0,   0,  77,
      78,  76,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      49,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
      95,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  79,  80,  66,  66,  66,  66,  94, },
  exits = {
    {
      x = 18,
      y = 13,
      tx = 4,
      ty = 4,
      room = 4,
    nil},
    {
      x = 19,
      y = 13,
      tx = 5,
      ty = 4,
      room = 4,
    nil},
    {
      x = 0,
      y = 4,
      tx = 17,
      ty = 14,
      room = 34,
    nil},
  nil},
}
__pulp.rooms[14] = {
  id = 14,
  name = "art 6x8 bleh",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 212, 212, 212, 212, 212, 212,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 212, 212, 212, 212, 212, 212,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 212, 212, 212, 212, 212, 212,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 212, 212, 212, 212, 212, 212,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 212, 212, 212, 212, 212, 212,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 212, 212, 212, 212, 212, 212,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 212, 212, 212, 212, 212, 212,  36,  66,  97,  99,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 212, 212, 212, 212, 212, 212,  36,  66,  98, 100,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  40,  66, 149, 327,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 18,
      y = 11,
      tx = 15,
      ty = 11,
      room = 3,
    nil},
  nil},
}
__pulp.rooms[15] = {
  id = 15,
  name = "art 6x8 dblcrow",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 115, 115, 115, 115, 115, 115,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 115, 115, 115, 115, 115, 115,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 115, 115, 115, 115, 115, 115,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 115, 115, 115, 115, 115, 115,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 115, 115, 115, 115, 115, 115,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 115, 115, 115, 115, 115, 115,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 115, 115, 115, 115, 115, 115,  36,  66,  97,  99,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 115, 115, 115, 115, 115, 115,  36,  66,  98, 100,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  40,  66, 178, 327,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 18,
      y = 11,
      tx = 15,
      ty = 4,
      room = 2,
    nil},
  nil},
}
__pulp.rooms[16] = {
  id = 16,
  name = "art 6x8 Doog",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 116, 116, 116, 116, 116, 116,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 116, 116, 116, 116, 116, 116,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 116, 116, 116, 116, 116, 116,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 116, 116, 116, 116, 116, 116,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 116, 116, 116, 116, 116, 116,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 116, 116, 116, 116, 116, 116,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 116, 116, 116, 116, 116, 116,  36,  66,  97,  99,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 116, 116, 116, 116, 116, 116,  36,  66,  98, 100,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  40,  66, 122, 327,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 18,
      y = 11,
      tx = 5,
      ty = 4,
      room = 3,
    nil},
  nil},
}
__pulp.rooms[17] = {
  id = 17,
  name = "art 6x8 cactus",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 135, 135, 135, 135, 135, 135,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 135, 135, 135, 135, 135, 135,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 135, 135, 135, 135, 135, 135,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 135, 135, 135, 135, 135, 135,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 135, 135, 135, 135, 135, 135,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 135, 135, 135, 135, 135, 135,  36,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 135, 135, 135, 135, 135, 135,  36,  66,  97,  99,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  37, 135, 135, 135, 135, 135, 135,  36,  66,  98, 100,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  40,  66, 211, 327,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 18,
      y = 11,
      tx = 19,
      ty = 4,
      room = 2,
    nil},
  nil},
}
__pulp.rooms[18] = {
  id = 18,
  name = "art 10x10 no photo",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 118, 118, 118, 118, 118, 118, 118, 118, 118, 118,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 119, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 4,
      ty = 4,
      room = 2,
    nil},
  nil},
}
__pulp.rooms[19] = {
  id = 19,
  name = "art 10x10",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 117, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
  nil},
}
__pulp.rooms[20] = {
  id = 20,
  name = "studioHallway 2",
  song = -1,
  tiles = {
       0,   0,   0,  77,  66,  66,  74,  69,  75,  66,  74,  69,  75,  66,  74,  67,  69,  75,  46, 126,   0,   0,   0,   0, 128,
       0,   0,   0,  77,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  61, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,   0,   0,   0, 291,   0,   0,   0, 291,   0,   0,   0,   0, 291,   0,  77, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 271,  88,  89,  77, 126,   0,   0,   0,   0,  77,
       0,   0,   0, 105,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,   0,   0,   0,   0, 269,   0,   0,   0,   0,   0,   0,   0,   0,   0, 105, 130,   0,   0,   0,   0,  77,
       0,   0,   0,  77,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77, 126,   0,   0,   0,   0,  77,
      45,  45,  45,  51,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45, 126,   0,   0,   0,   0,  77,
      66,  66,  66,  46,  66,  72,  68,  68,  71,  66,  72,  68,  71,  66,  72,  68,  68,  71,  66, 126,   0,   0,   0,   0,  77,
      75,  66,  66,  46,  66,  74,  67,  67,  69,  75,  74,  67,  69,  75,  74,  67,  67,  69,  75, 126,   0,   0,   0,   0,  77,
      58,  58,  58,  61,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58, 126,   0,   0,   0,   0,  77,
       0,   0,   0, 105,   0,   0,   0, 291,   0,   0,   0,   0, 291,   0,   0,   0, 291,   0,   0,   0,   0,   0,   0,   0,  77,
       0,   0, 104,  77,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
       0,   0,   0,  77,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  50,
       0,   0,   0,  77,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20, },
  exits = {
    {
      x = 4,
      y = 11,
      tx = 23,
      ty = 4,
      room = 12,
    nil},
    {
      x = 2,
      y = 0,
      tx = 2,
      ty = 7,
      room = 21,
    nil},
    {
      x = 1,
      y = 0,
      tx = 1,
      ty = 7,
      room = 21,
    nil},
    {
      x = 0,
      y = 0,
      tx = 0,
      ty = 7,
      room = 21,
    nil},
    {
      x = 20,
      y = 0,
      tx = 20,
      ty = 7,
      room = 21,
    nil},
    {
      x = 21,
      y = 0,
      tx = 21,
      ty = 7,
      room = 21,
    nil},
    {
      x = 22,
      y = 0,
      tx = 22,
      ty = 7,
      room = 21,
    nil},
    {
      x = 23,
      y = 0,
      tx = 23,
      ty = 7,
      room = 21,
    nil},
    {
      x = 19,
      y = 5,
      tx = 17,
      ty = 5,
      room = 20,
    nil},
    {
      x = 4,
      y = 4,
      tx = 2,
      ty = 4,
      room = 20,
    nil},
    {
      x = 3,
      y = 4,
      tx = 5,
      ty = 4,
      room = 20,
    nil},
    {
      x = 18,
      y = 5,
      tx = 20,
      ty = 5,
      room = 20,
    nil},
    {
      x = 3,
      y = 11,
      tx = 5,
      ty = 11,
      room = 20,
    nil},
    {
      x = 0,
      y = 1,
      tx = 20,
      ty = 8,
      room = 22,
    nil},
    {
      x = 0,
      y = 2,
      tx = 20,
      ty = 9,
      room = 22,
    nil},
    {
      x = 0,
      y = 3,
      tx = 20,
      ty = 10,
      room = 22,
    nil},
    {
      x = 0,
      y = 4,
      tx = 20,
      ty = 11,
      room = 22,
    nil},
    {
      x = 0,
      y = 6,
      tx = 20,
      ty = 13,
      room = 22,
    nil},
    {
      x = 0,
      y = 5,
      tx = 20,
      ty = 12,
      room = 22,
    nil},
  nil},
}
__pulp.rooms[21] = {
  id = 21,
  name = "studioHallway 3",
  song = -1,
  tiles = {
      45,  45,  45,  51,  58,  58,  58,  58,  58,  58,  58,  61,  58,  58,  58,  58,  58,  58,  61, 126,   0,   0,   0,   0,  77,
      72,  71,  66,  46,   0,   0,   0,   0,   0,   0,   0,  77,   0, 270,   0,   0,   0,   0,  77, 126,   0,   0,   0,   0,  77,
      74,  69,  75,  46,   0, 273,   0,   0,   0,   0,   0,  77,   0,   0,   0,   0,   0,   0, 105, 130,   0,   0,   0,   0,  77,
      58,  58,  58,  61,   0,   0,   0,   0,   0,   0,   0, 105,   0,   0,   0,   0, 272,   0,  77, 126,   0,   0,   0,   0,  77,
       0, 291,   0, 105,   0,   0,   0,   0,   0, 267,   0,  77,   0,   0,   0,   0,   0,   0,  77, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,  66,  66,  72,  71,  66,  66,  72,  71,  66,  66,  72,  68,  71,  66,  46, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,  66,  66,  74,  69,  75,  66,  74,  69,  75,  66,  74,  67,  69,  75,  46, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  61, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,   0,   0,   0, 291,   0,   0,   0, 291,   0,   0,   0,   0, 291,   0,  77, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 271,  88,  89,  77, 126,   0,   0,   0,   0,  77,
       0,   0,   0, 105,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77, 126,   0,   0,   0,   0,  77,
       0,   0,   0,  77,   0,   0,   0,   0, 269,   0,   0,   0,   0,   0,   0,   0,   0,   0, 105, 130,   0,   0,   0,   0,  77,
       0,   0,   0,  77,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77, 126,   0,   0,   0,   0,  77,
      45,  45,  45,  51,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45, 126,   0,   0,   0,   0,  77, },
  exits = {
    {
      x = 0,
      y = 9,
      tx = 20,
      ty = 7,
      edge = 3,
      room = 22,
    nil},
    {
      x = 19,
      y = 2,
      tx = 17,
      ty = 2,
      room = 21,
    nil},
    {
      x = 12,
      y = 3,
      tx = 10,
      ty = 3,
      room = 21,
    nil},
    {
      x = 4,
      y = 4,
      tx = 2,
      ty = 4,
      room = 21,
    nil},
    {
      x = 4,
      y = 11,
      tx = 2,
      ty = 11,
      room = 21,
    nil},
    {
      x = 19,
      y = 12,
      tx = 17,
      ty = 12,
      room = 21,
    nil},
    {
      x = 20,
      y = 0,
      tx = 20,
      ty = 14,
      room = 23,
    nil},
    {
      x = 21,
      y = 0,
      tx = 21,
      ty = 14,
      room = 23,
    nil},
    {
      x = 22,
      y = 0,
      tx = 22,
      ty = 14,
      room = 23,
    nil},
    {
      x = 23,
      y = 0,
      tx = 23,
      ty = 14,
      room = 23,
    nil},
    {
      x = 3,
      y = 4,
      tx = 5,
      ty = 4,
      room = 21,
    nil},
    {
      x = 3,
      y = 11,
      tx = 5,
      ty = 11,
      room = 21,
    nil},
    {
      x = 11,
      y = 3,
      tx = 13,
      ty = 3,
      room = 21,
    nil},
    {
      x = 18,
      y = 2,
      tx = 20,
      ty = 2,
      room = 21,
    nil},
    {
      x = 18,
      y = 12,
      tx = 20,
      ty = 12,
      room = 21,
    nil},
    {
      x = 20,
      y = 14,
      tx = 20,
      ty = 7,
      room = 20,
    nil},
    {
      x = 21,
      y = 14,
      tx = 21,
      ty = 7,
      room = 20,
    nil},
    {
      x = 22,
      y = 14,
      tx = 22,
      ty = 7,
      room = 20,
    nil},
    {
      x = 23,
      y = 14,
      tx = 23,
      ty = 7,
      room = 20,
    nil},
    {
      x = 20,
      y = 0,
      tx = 19,
      ty = 14,
      edge = 0,
      room = 23,
    nil},
  nil},
}
__pulp.rooms[22] = {
  id = 22,
  name = "studioRear",
  song = -1,
  tiles = {
     224, 224, 224, 224, 224, 224, 224,  19, 229, 138, 139,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,  58,
      19,  19,  19,  19,  19,  19, 224, 229, 229, 137,  47,  72,  71,  66,  72,  71,  66,  72,  71,  66,  72,  71,  66,  46,   0,
     229, 229, 229,  19, 224,  19,  19, 229,   0, 136,  47,  74,  69,  75,  74,  69,  75,  74,  69,  75,  74,  69,  75,  46,   0,
       0, 229, 229, 229,  19, 229,  19, 229,   0, 140,  60,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  61,   0,
       0, 229, 229, 229, 229, 229, 229, 229,   0,   0,  78,   0, 291,   0,   0, 291,   0,   0, 291,   0,   0, 291,   0, 105,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0, 129, 131,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,  45,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,  66,
       0, 229, 229, 229, 229, 229, 229, 229,   0,   0,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,  66,
       0, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,  58,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,   0,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,   0,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 105,   0,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,   0,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 274,  78,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,   0,
      45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  51,  45, },
  exits = {
    {
      x = 20,
      y = 7,
      tx = 0,
      ty = 9,
      edge = 1,
      room = 21,
    nil},
    {
      x = 10,
      y = 5,
      tx = 8,
      ty = 5,
      room = 22,
    nil},
    {
      x = 23,
      y = 4,
      tx = 4,
      ty = 4,
      room = 21,
    nil},
    {
      x = 23,
      y = 11,
      tx = 4,
      ty = 11,
      room = 21,
    nil},
    {
      x = 9,
      y = 5,
      tx = 11,
      ty = 5,
      room = 22,
    nil},
    {
      x = 9,
      y = 2,
      tx = 1,
      ty = 10,
      room = 25,
    nil},
    {
      x = 8,
      y = 0,
      tx = 22,
      ty = 13,
      room = 38,
    nil},
    {
      x = 3,
      y = 4,
      tx = 17,
      ty = 4,
      room = 33,
    nil},
    {
      x = 3,
      y = 5,
      tx = 17,
      ty = 5,
      room = 33,
    nil},
    {
      x = 3,
      y = 6,
      tx = 17,
      ty = 6,
      room = 33,
    nil},
    {
      x = 3,
      y = 7,
      tx = 17,
      ty = 7,
      room = 33,
    nil},
    {
      x = 3,
      y = 8,
      tx = 17,
      ty = 8,
      room = 33,
    nil},
    {
      x = 3,
      y = 9,
      tx = 17,
      ty = 9,
      room = 33,
    nil},
    {
      x = 3,
      y = 10,
      tx = 17,
      ty = 10,
      room = 33,
    nil},
    {
      x = 3,
      y = 11,
      tx = 17,
      ty = 11,
      room = 33,
    nil},
    {
      x = 3,
      y = 12,
      tx = 17,
      ty = 12,
      room = 33,
    nil},
    {
      x = 3,
      y = 13,
      tx = 17,
      ty = 13,
      room = 33,
    nil},
    {
      x = 9,
      y = 13,
      tx = 13,
      ty = 8,
      room = 40,
    nil},
  nil},
}
__pulp.rooms[23] = {
  id = 23,
  name = "studioRestroom",
  song = -1,
  tiles = {
     161,  66,  66,  66, 158,  66,  66, 158,  66, 158,  66, 158,  66, 158,  66,  66,  46, 165,  66,  66, 161,  66, 200, 201,  46,
     161, 156, 156, 156, 154, 145, 162, 154, 145, 154, 145, 154, 145, 157, 156, 156, 159, 166, 156, 156, 209, 156, 203, 202, 159,
     161, 146,   0,   0, 130,   0,   0, 130,   0, 163,   0, 130,   0, 130,   0,   0,  77, 130,   0,   0,  77, 146,   0,   0, 215,
     161,   0, 274,   0, 155, 155, 153, 155, 153, 155, 153, 155, 153, 130,   0,   0,  77, 130, 186,   0,  77, 216, 214,   0,  77,
     161, 146,   0,   0, 130,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77, 130,   0,   0, 213, 155, 155, 222, 208,
     161,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 105, 130,   0,   0,   0,   0,   0,   0,  77,
     161,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77, 130,   0,   0,   0,   0,   0,   0,  77,
     161,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45, 130,   0,   0,   0,   0,   0,   0,  77,
     161,  66,  66,  66,  72,  71,  66,  72,  68,  71,  66,  72,  68,  68,  71,  66,  66, 130,   0,   0,   0, 186,   0,   0,  77,
     161,  66,  66,  66,  74,  69,  75,  74,  67,  69,  75,  74,  67,  67,  69,  75,  66, 130,   0,   0,   0,   0,   0,   0,  77,
     161,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58,  58, 130,   0,   0,   0,   0,   0,   0,  77,
     161,   0,   0,   0,   0, 291,   0,   0,   0, 291,   0,   0,   0,   0, 291,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
     161,   0, 186,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
     161,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  77,
      45,  45,  45,  51,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45, 126,   0,   0,   0,   0,  77, },
  exits = {
    {
      x = 19,
      y = 14,
      tx = 20,
      ty = 0,
      edge = 2,
      room = 21,
    nil},
    {
      x = 17,
      y = 5,
      tx = 15,
      ty = 5,
      room = 23,
    nil},
    {
      x = 16,
      y = 5,
      tx = 18,
      ty = 5,
      room = 23,
    nil},
    {
      x = 22,
      y = 1,
      tx = 21,
      ty = 13,
      room = 31,
    nil},
    {
      x = 23,
      y = 1,
      tx = 21,
      ty = 13,
      room = 31,
    nil},
    {
      x = 2,
      y = 3,
      tx = 19,
      ty = 7,
      room = 40,
    nil},
  nil},
}
__pulp.rooms[24] = {
  id = 24,
  name = "art 16x9 Wendy Pool",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  97,  99,  66,  66,
      66,  66,  37, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168, 168,  36,  66,  98, 100,  66,  66,
      66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 210, 327,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 22,
      y = 12,
      tx = 10,
      ty = 4,
      room = 2,
    nil},
  nil},
}
__pulp.rooms[25] = {
  id = 25,
  name = "roofTerrace",
  song = -1,
  tiles = {
     255, 257, 256, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310,
     252, 254,  18, 130,   0,   0,   0,   0,   0,   0,   0, 181, 174, 174, 174, 174, 174, 174, 174, 174, 174, 174, 180,   0,   0,
     259, 255, 252, 130,   0,   0,   0,   0,   0,   0,   0, 175, 173, 173, 173, 173, 173, 173, 173, 173, 173, 173, 177, 219,   0,
     259, 257, 257, 130,   0,   0,   0,   0,   0,   0, 221, 175, 173, 173, 173, 173, 173, 173, 173, 173, 173, 173, 177,   0,   0,
      18, 254,  16, 130,   0,   0,   0, 186,   0,   0,   0, 175, 173, 173, 173, 173, 173, 173, 173, 173, 173, 173, 177, 219,   0,
     255, 252, 254, 130,   0,   0,   0,   0,   0,   0, 221, 175, 173, 173, 173, 173, 173, 173, 173, 173, 173, 173, 177,   0,   0,
     252, 255,  16, 130,   0,   0,   0,   0,   0,   0,   0, 175, 173, 173, 173, 173, 173, 173, 173, 173, 183, 173, 177, 219,   0,
     252, 254, 252, 130,   0,   0,   0,   0,   0,   0,   0, 182, 176, 176, 176, 176, 176, 176, 176, 176, 176, 176, 179,   0,   0,
     251, 251, 251, 130,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
     310, 310, 310, 218,  91, 217,  90,  92, 141,  92, 141,  92, 141,  92, 141,  92, 141,  92, 141,  92, 141,  92, 141, 167,  91,
     138,   0,   0,   0, 228,   0, 241,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
     130,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
     130,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
     142, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143, 143,
      20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20, },
  exits = {
    {
      x = 0,
      y = 10,
      tx = 8,
      ty = 2,
      room = 22,
    nil},
    {
      x = 20,
      y = 6,
      tx = 19,
      ty = 12,
      room = 28,
    nil},
  nil},
}
__pulp.rooms[26] = {
  id = 26,
  name = "art 10x10 overall cowboys",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 169, 169, 169, 169, 169, 169, 169, 169, 169, 169,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 170, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 19,
      ty = 4,
      room = 3,
    nil},
  nil},
}
__pulp.rooms[27] = {
  id = 27,
  name = "art triptych",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  38,  33,  33,  33,  33,  33,  39,  66,  38,  33,  33,  33,  33,  33,  39,  66,  38,  33,  33,  33,  33,  33,  39,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,  37, 120, 120, 120, 120, 120,  36,  66,
      66,  41,  35,  35,  35,  35,  35,  40,  66,  41,  35,  35,  35,  35,  35,  40,  66,  41,  35,  35,  35,  35,  35,  40,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66, 101, 102,  66,  66, 327, 187, 114, 117, 101, 102,  66,  66,  66,  66,  66,  66, 101, 102,  66, },
  exits = {
    {
      x = 10,
      y = 14,
      tx = 10,
      ty = 4,
      room = 2,
    nil},
  nil},
}
__pulp.rooms[28] = {
  id = 28,
  name = "roofPoolview-",
  song = -1,
  tiles = {
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, },
  exits = {
  nil},
}
__pulp.rooms[29] = {
  id = 29,
  name = "art 16x9 skelesweet",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  97,  99,  66,  66,
      66,  66,  37, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184,  36,  66,  98, 100,  66,  66,
      66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 185, 327,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 22,
      y = 12,
      tx = 10,
      ty = 11,
      room = 2,
    nil},
  nil},
}
__pulp.rooms[30] = {
  id = 30,
  name = "art sculpt-",
  song = -1,
  tiles = {
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 196, 188, 188, 190,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 192,  97,  99, 197,
       0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 192,  98, 100, 197,
       0,   0,   0,   0,   0, 189, 194, 194, 194, 194, 194, 194, 194, 194, 194, 194, 194, 193,   0,   0,   0, 192, 117, 327, 197,
       0,   0,   0,   0,   0, 195, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 191,   0,   0,   0, 192, 114, 114, 197, },
  exits = {
  nil},
}
__pulp.rooms[31] = {
  id = 31,
  name = "art 16x9 portal",
  song = -1,
  tiles = {
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114,
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114,
     114, 114,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39, 114, 114, 114, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114,  97,  99, 114, 114,
     114, 114,  37, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198,  36, 114,  98, 100, 114, 114,
     114, 114,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40, 114, 199, 327, 114, 114,
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 187, 114, 114, 114, 114, 114, 114, 114, 114,
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, },
  exits = {
    {
      x = 22,
      y = 12,
      tx = 22,
      ty = 2,
      room = 23,
    nil},
    {
      x = 13,
      y = 7,
      fin = [[Every moment is a choice is a portal to your next future! 
We are grateful you visited us here at ART7]],
    nil},
    {
      x = 12,
      y = 7,
      fin = [[Every moment is a choice is a portal to your next future! 
We are grateful you visited us here at ART7]],
    nil},
    {
      x = 12,
      y = 6,
      fin = [[Every moment is a choice is a portal to your next future! 
We are grateful you visited us here at ART7]],
    nil},
    {
      x = 13,
      y = 6,
      fin = [[Every moment is a choice is a portal to your next future! 
We are grateful you visited us here at ART7]],
    nil},
  nil},
}
__pulp.rooms[32] = {
  id = 32,
  name = "art 10x10 TEXAS",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 227, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 16,
      ty = 4,
      room = 3,
    nil},
  nil},
}
__pulp.rooms[33] = {
  id = 33,
  name = "fountain",
  song = -1,
  tiles = {
     224, 224, 225, 224, 224, 224, 225, 229,   0,   0, 229,  19, 224, 224, 224, 224, 224, 224, 224, 224, 224,  19, 229, 138, 139,
      19, 225,  19,  19,  19,  19,  19, 229,   0,   0, 229, 229,  19,  19,  19,  19,  19,  19,  19,  19, 225, 229, 229, 137,  47,
     224,  19,  19, 229, 229, 229, 229, 229,   0,   0, 229, 229, 229, 229, 229, 229, 229,  19, 224,  19,  19, 229,   0, 136,  47,
      19,  19, 229, 229, 229,   0,   0,   0,   0,   0,   0,   0,   0,   0, 229, 229, 229, 229,  19, 229,  19, 229,   0, 140,  60,
      19, 229, 229, 229,   0,   0,   0,   1,   1,   1,   1,   1,   0,   0,   0, 229, 229, 229, 229, 229, 229, 229,   0,   0,  78,
     229, 229,   0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 129, 131,
     229,   0,   0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  78,
       0,   0, 229, 229,   0,   0,   0,   1,   1,   1,   1,   1,   0,   0,   0, 229, 229, 229, 229, 229, 229, 229,   0,   0,  78,
       0, 229, 229, 229, 229,   0,   0,   0,   0,   0,   0,   0,   0,   0, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,
     229, 229, 229, 229, 229, 229,   0,   0,   0,   0,   0,   0,   0, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229,  78,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 274,  78,
      45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45, },
  exits = {
    {
      x = 24,
      y = 5,
      tx = 8,
      ty = 5,
      room = 22,
    nil},
    {
      x = 23,
      y = 5,
      tx = 11,
      ty = 5,
      room = 22,
    nil},
    {
      x = 23,
      y = 2,
      tx = 1,
      ty = 10,
      room = 25,
    nil},
    {
      x = 0,
      y = 5,
      tx = 19,
      ty = 1,
      room = 34,
    nil},
    {
      x = 0,
      y = 6,
      tx = 19,
      ty = 2,
      room = 34,
    nil},
    {
      x = 0,
      y = 7,
      tx = 19,
      ty = 3,
      room = 34,
    nil},
    {
      x = 0,
      y = 8,
      tx = 19,
      ty = 4,
      room = 34,
    nil},
    {
      x = 0,
      y = 9,
      tx = 19,
      ty = 5,
      room = 34,
    nil},
    {
      x = 0,
      y = 11,
      tx = 19,
      ty = 7,
      room = 34,
    nil},
    {
      x = 0,
      y = 10,
      tx = 19,
      ty = 6,
      room = 34,
    nil},
    {
      x = 0,
      y = 12,
      tx = 19,
      ty = 8,
      room = 34,
    nil},
    {
      x = 0,
      y = 13,
      tx = 19,
      ty = 9,
      room = 34,
    nil},
    {
      x = 7,
      y = 0,
      tx = 7,
      ty = 12,
      room = 38,
    nil},
    {
      x = 8,
      y = 0,
      tx = 8,
      ty = 12,
      room = 38,
    nil},
    {
      x = 9,
      y = 0,
      tx = 9,
      ty = 12,
      room = 38,
    nil},
    {
      x = 10,
      y = 0,
      tx = 10,
      ty = 12,
      room = 38,
    nil},
    {
      x = 22,
      y = 0,
      tx = 22,
      ty = 12,
      room = 38,
    nil},
    {
      x = 23,
      y = 13,
      tx = 13,
      ty = 8,
      room = 40,
    nil},
  nil},
}
__pulp.rooms[34] = {
  id = 34,
  name = "forestPath",
  song = -1,
  tiles = {
     254, 251, 254, 251,  18, 255, 251, 251,  18,  19, 257,  19, 251, 257,  18, 257,  18, 253, 253,  19, 229, 229, 229,   0,   0,
      18, 251,  19, 254, 225, 254, 251,  19, 224, 257,  18, 251, 251, 251, 224, 257, 224, 224,  19, 229, 229,   0,   0,   0,   0,
     224, 256, 252,  19, 224, 255,  19,  18,  19, 251, 225, 251, 251, 257, 251, 252, 253, 229, 229, 229,   0,   0,   0,   0,   0,
     254, 253, 264, 264, 264,  19,  19, 225, 251,  19, 251,  18, 254, 251,  19, 252,  19, 229, 229,   0,   0, 229, 229,   0,   0,
     264, 264, 264, 264, 264, 229,  19, 254, 251, 251, 257, 224, 254, 251, 251,  19, 229, 229,   0,   0, 229, 229, 229, 229,   0,
     264, 264, 264,   0,   0, 229, 229,  19,  19, 254, 224, 251,  19,  19,  19, 229, 229,   0,   0, 229, 229, 229, 229, 229, 229,
     257, 256, 264, 229,   0,   0, 229, 229, 229,  19,  19,  19,  19, 229, 229, 229,   0,   0, 229, 229, 229, 229, 229, 229, 229,
     258, 256, 264, 264, 229,   0,   0, 229, 229, 229, 229, 229, 229, 229, 229,   0,   0, 229, 229, 229, 229, 229, 229, 229, 229,
     254, 256, 264, 264, 264, 229,   0,   0, 229, 229, 229, 229, 229, 229,   0,   0, 229, 229, 229, 229, 229, 229, 229, 229, 229,
     261,  18, 256, 229, 229, 229, 229,   0,   0,   0, 229, 229, 229,   0,   0,   0, 229, 229, 229, 229, 229, 229, 229, 229, 229,
     254,  19,  18, 256, 229, 229, 229, 229, 229,   0,   0, 229,   0,   0,   0,   0,   0, 229,  54,  45,  45,  45,  45,  45,  45,
     261, 254, 224, 258, 256, 229, 229, 229, 229, 229,   0,   0,   0, 229, 229, 229,   0,   0,  47,  72,  68,  68,  71,  66,  72,
      18, 261,  18,  19, 257, 258, 258, 229, 229, 229, 229, 229, 229, 229, 229, 229,   0,   0,  47,  74,  67,  67,  69,  75,  74,
     224, 257, 225, 252, 257, 257,  18, 258, 255, 258, 258, 258, 256, 229, 229, 229,   0, 239,  60,  58,  58,  58,  58,  58,  58,
     252, 252, 252, 254, 254, 254, 251, 257, 252, 255, 254, 257, 255, 257, 256, 229,   0,   0, 107,   0,   0,   0,   0,   0,   0, },
  exits = {
    {
      x = 18,
      y = 14,
      tx = 1,
      ty = 4,
      room = 13,
    nil},
    {
      x = 24,
      y = 0,
      tx = 5,
      ty = 4,
      room = 33,
    nil},
    {
      x = 24,
      y = 1,
      tx = 5,
      ty = 5,
      room = 33,
    nil},
    {
      x = 24,
      y = 5,
      tx = 5,
      ty = 9,
      room = 33,
    nil},
    {
      x = 24,
      y = 2,
      tx = 5,
      ty = 6,
      room = 33,
    nil},
    {
      x = 24,
      y = 3,
      tx = 5,
      ty = 7,
      room = 33,
    nil},
    {
      x = 24,
      y = 4,
      tx = 5,
      ty = 8,
      room = 33,
    nil},
    {
      x = 24,
      y = 6,
      tx = 5,
      ty = 10,
      room = 33,
    nil},
    {
      x = 24,
      y = 7,
      tx = 5,
      ty = 11,
      room = 33,
    nil},
    {
      x = 24,
      y = 8,
      tx = 5,
      ty = 12,
      room = 33,
    nil},
    {
      x = 24,
      y = 9,
      tx = 5,
      ty = 13,
      room = 33,
    nil},
    {
      x = 1,
      y = 4,
      tx = 24,
      ty = 4,
      room = 35,
    nil},
    {
      x = 1,
      y = 5,
      tx = 24,
      ty = 5,
      room = 35,
    nil},
  nil},
}
__pulp.rooms[35] = {
  id = 35,
  name = "forestMaze",
  song = -1,
  tiles = {
     256,  18, 253, 261, 256, 253, 261, 256, 257, 256, 254, 256,  18, 253, 256,  19, 256, 255,  18, 255, 257,  18, 256, 254, 251,
     256, 224, 256, 260,  18, 254, 257, 254, 256,  18, 255, 256, 224, 256, 261, 256, 261, 253, 224, 256, 256, 224, 256, 256, 251,
     253, 187, 256, 256, 224, 256, 252, 254, 256, 224, 256, 256, 264, 264, 264, 264, 264, 264, 264, 256, 261, 187, 256, 254, 256,
     256, 264, 252, 256, 264, 264, 264, 264, 264, 264, 256, 224, 264, 255,  18, 256, 254, 252, 264, 256, 256, 264, 255, 256, 256,
     253, 264,  19, 251, 264, 255, 257, 256, 260, 264, 255, 256, 264, 254, 224, 256, 258, 256, 264, 254, 253, 264, 264, 264, 264,
     261, 264, 256, 256, 264, 254, 254, 253, 256, 264, 254, 261, 264, 255, 264, 264, 264, 256, 264, 259, 260, 264, 264, 264, 264,
     260, 264, 255, 253, 264, 255, 256, 256, 253, 264, 259, 256, 264, 259, 264, 259, 264, 254, 264, 255, 253, 264, 256, 252, 256,
     261, 264, 264, 264, 264, 259, 187, 264, 224, 264, 224, 256, 264, 254, 264, 259, 264, 256, 264, 259, 253, 264, 255, 261, 256,
     254, 256, 255, 256, 264, 255, 260, 264, 254, 264, 255, 256, 264, 254, 264, 252, 264, 259, 264, 255, 258, 264, 256, 224, 256,
     264, 254, 251, 259, 264, 254, 256, 264, 264, 264, 254, 251, 264, 255, 264, 259, 264, 264, 264, 256, 260, 264, 261, 261, 255,
     264, 264, 264, 264, 264, 258, 256, 252, 261, 264, 264, 264, 264, 254, 264, 256,  18, 253,  18, 253, 256, 264, 255, 254, 255,
     257,  18, 256, 257,  18, 256, 254, 256, 256,  18, 255, 257,  18, 256, 264, 264, 264, 264, 264, 264, 264, 264, 256, 261, 252,
     255,  19, 255, 253, 224, 256, 255, 256, 254, 224, 254, 256, 255, 256,  18, 253, 256, 255, 255, 256, 253,  18, 255, 261, 261,
     225, 252, 257, 224, 252, 254, 254, 260, 254, 255, 252, 252, 252, 256, 224, 254, 252,  19, 254, 252, 254, 224, 261, 258, 257,
     224,  19, 224, 257, 224, 225,  19, 254, 254, 252,  19, 224, 225, 225, 256,  19, 254, 252, 252,  19, 225, 252, 224, 252, 252, },
  exits = {
    {
      x = 24,
      y = 4,
      tx = 2,
      ty = 4,
      room = 34,
    nil},
    {
      x = 24,
      y = 5,
      tx = 2,
      ty = 5,
      room = 34,
    nil},
    {
      x = 0,
      y = 10,
      tx = 24,
      ty = 10,
      room = 36,
    nil},
  nil},
}
__pulp.rooms[36] = {
  id = 36,
  name = "forestClearing-",
  song = -1,
  tiles = {
     261, 256, 261, 260, 261, 224, 224, 224, 224, 251, 224, 251, 251, 224, 224, 224, 224, 259, 259, 259, 259, 224, 261, 224, 256,
     261, 260, 251, 224, 224, 253, 264, 264, 264, 224, 264, 224, 224, 264, 264, 264, 264, 224, 224, 224, 254, 254, 259, 256, 256,
     256, 257, 224, 224, 251, 224, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 224, 224, 259, 224, 253,
     259, 260, 264, 264, 224, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 224, 259, 256,
     260, 224, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 224, 224, 253,
     224, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 224, 261,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 259, 260,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 259, 261,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 254, 254,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 255, 257,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 259, 256,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264,   0,   0, 254, 261,
     264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264, 264,   0, 274, 225, 224, },
  exits = {
    {
      x = 24,
      y = 10,
      tx = 0,
      ty = 10,
      room = 35,
    nil},
    {
      x = 24,
      y = 9,
      tx = 0,
      ty = 10,
      room = 35,
    nil},
    {
      x = 22,
      y = 14,
      tx = 0,
      ty = 7,
      room = 40,
    nil},
  nil},
}
__pulp.rooms[37] = {
  id = 37,
  name = "rearShed-",
  song = -1,
  tiles = {
     309, 309,  18, 257, 259, 257, 257, 259, 259, 257, 257, 254,  18, 255, 256, 257, 256, 254,  18, 257, 254,  18, 254, 256, 256,
     309, 187, 254, 257, 257,  18, 257, 224, 225, 224, 224, 261, 252, 254,  18, 256, 261, 256, 252, 254, 254, 254, 257, 254, 261,
     309, 309, 224, 259, 257, 259, 261, 225, 225, 229, 224, 224,  19, 224,  19, 225, 225, 225, 224, 256, 256, 254, 257, 254, 261,
     309, 309, 259, 257, 224, 224, 224, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 224, 254, 257, 254, 254, 256,
     309, 309, 258, 224, 224, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 224, 253, 257, 257,  18,
     309, 258, 261, 224, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 224, 224, 253, 261, 253,
     258, 224,  19, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 259,  18,  19,
     260, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 254, 256, 256,
     224, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 224,  19, 257,
     224, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 255, 224,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 255, 255,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 255, 252,  18,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 255, 252, 225, 252,
     229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 229, 274, 229, 229, 229, 225, 225, 257, 224,
     138, 139,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45,  45, },
  exits = {
    {
      x = 0,
      y = 13,
      tx = 23,
      ty = 12,
      room = 38,
    nil},
    {
      x = 0,
      y = 12,
      tx = 23,
      ty = 11,
      room = 38,
    nil},
    {
      x = 0,
      y = 11,
      tx = 23,
      ty = 10,
      room = 38,
    nil},
    {
      x = 0,
      y = 10,
      tx = 23,
      ty = 9,
      room = 38,
    nil},
    {
      x = 17,
      y = 13,
      tx = 20,
      ty = 6,
      room = 40,
    nil},
  nil},
}
__pulp.rooms[38] = {
  id = 38,
  name = "lakePath-",
  song = -1,
  tiles = {
     322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 308, 322, 322, 308, 304, 309, 187,
     322, 322, 322, 322, 322, 308, 322, 322, 322, 322, 322, 322, 322, 322, 322, 302, 322, 322, 322, 322, 322, 302, 304, 309, 309,
     322, 322, 322, 322, 322, 322, 322, 322, 322, 302, 322, 322, 322, 322, 322, 322, 322, 308, 322, 322, 308, 307, 305, 309, 309,
     322, 322, 322, 322, 308, 322, 322, 322, 322, 322, 322, 322, 308, 322, 322, 322, 322, 322, 322, 322, 302, 304, 309, 309, 309,
     322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 302, 322, 322, 322, 308, 306, 305, 309, 309, 258,
     322, 322, 322, 322, 322, 322, 322, 322, 322, 308, 322, 322, 322, 302, 322, 322, 322, 322, 302, 306, 305, 309, 309, 258, 224,
     322, 308, 322, 322, 322, 322, 302, 322, 322, 322, 322, 322, 322, 322, 322, 322, 308, 302, 306, 305, 309, 309, 255, 260, 229,
     322, 322, 322, 302, 322, 322, 322, 302, 322, 322, 322, 302, 322, 322, 308, 308, 302, 306, 305, 309, 309, 255, 258, 224, 229,
     322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 322, 302, 307, 303, 309, 309, 309, 309, 309, 259, 224, 224, 229,
     302, 308, 302, 302, 308, 302, 302, 302, 308, 302, 302, 302, 302, 306, 309, 309, 309, 309, 309, 309, 258, 224, 260, 229, 229,
     303, 303, 303, 303, 303, 303, 303, 303, 303, 303, 303, 303, 303, 305, 309, 309, 309, 309, 187, 258, 224,  18, 224, 229, 229,
     187, 309, 309, 309, 309, 309, 309, 309, 309, 309, 309, 309, 309, 309, 258, 257, 255, 258, 258, 224, 251, 224, 224, 229, 229,
     258, 258, 258, 258, 258, 258,  18, 229,   0,   0, 229,  18, 258, 258, 224,  18, 224, 251, 224, 251, 224, 224, 229, 229, 229,
     254, 224, 254,  18, 253, 224, 256, 229,   0,   0, 229,  19, 224, 251, 224, 251, 224, 224, 251, 224, 224,  19, 229, 138, 139,
      19, 225,  19,  19,  19,  19,  19, 229,   0,   0, 229, 229,  19,  19,  19,  19,  19,  19,  19,  19, 225, 229, 229, 137,  47, },
  exits = {
    {
      x = 7,
      y = 14,
      tx = 7,
      ty = 1,
      room = 33,
    nil},
    {
      x = 8,
      y = 14,
      tx = 8,
      ty = 1,
      room = 33,
    nil},
    {
      x = 9,
      y = 14,
      tx = 9,
      ty = 1,
      room = 33,
    nil},
    {
      x = 10,
      y = 14,
      tx = 10,
      ty = 1,
      room = 33,
    nil},
    {
      x = 24,
      y = 9,
      tx = 1,
      ty = 10,
      room = 37,
    nil},
    {
      x = 24,
      y = 10,
      tx = 1,
      ty = 11,
      room = 37,
    nil},
    {
      x = 24,
      y = 11,
      tx = 1,
      ty = 12,
      room = 37,
    nil},
    {
      x = 24,
      y = 12,
      tx = 1,
      ty = 13,
      room = 37,
    nil},
    {
      x = 22,
      y = 13,
      tx = 22,
      ty = 0,
      room = 33,
    nil},
  nil},
}
__pulp.rooms[39] = {
  id = 39,
  name = "art 10x10 orkn",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 275, 275, 275, 275, 275, 275, 275, 275, 275, 275,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 276, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 20,
      ty = 11,
      room = 3,
    nil},
  nil},
}
__pulp.rooms[40] = {
  id = 40,
  name = "theUnderground",
  song = -1,
  tiles = {
     138,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20, 138,  20,  20,  20,  20,  20, 138, 138,  20,  20,  20,  20,
     138,  20,  20,  20,  20,  20, 315, 316,  20,  20,  20,  20,  20, 138,  20,  20,  20,  20,  20, 138, 138,  20,  20,  20,  20,
     138,  20,  20,  20,  20,  20, 318, 317,  20,  20,  20,  20,  20, 138,  20,  20,  20,  20,  20, 138, 138,  20,  20,  20,  20,
     138,  20,  20,  20,  20,  20, 319, 320,  20,  20,  20,  20,  20, 138,  20,  20,  20,  20,  20, 138, 138,  20,  20,  20,  20,
     138,  20,  20,  23, 311, 311, 321, 320,  20,  23, 311, 311, 321, 138,  20,  23, 311, 311, 321, 138, 138,  23, 311, 311, 321,
     138,  20,  20, 312, 114, 114, 313,  20,  20, 312, 114, 114, 313, 138,  20, 312, 114, 114, 313, 138, 136, 312, 114, 114, 313,
     136, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 138, 114, 114, 114, 114, 114, 136, 114, 114, 114, 114, 114,
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 136, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114,
     114,   1,   1,   1,   1, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114,
     114,   1,   1,   1,   1, 114, 114, 114, 114, 114, 114, 114, 114, 114,  29,  29,  29,  29,  29,  29,  29,  29,  29,  29,  29,
     114, 114, 114, 114, 114, 114, 114,  29,  29,  29,  29,  29,  29, 314,  20,  20,  20,  20,  20, 315, 324,  20,  20,  20,  20,
      29,  29,  29,  29,  29,  29, 314,  20,  20,  20,  20,  20,  20,  53,  20,  20,  20,  20,  20, 318, 317,  20,  20,  20,  20,
      20,  20,  20,  20,  20,  20,  53,  20,  20,  20,  20,  20,  20,  53, 308, 302, 308, 308, 308, 302, 302, 302, 302, 308, 302,
      20,  20,  20,  20,  20,  20,  53, 308, 302, 308, 308, 308, 302, 302, 308, 308, 308, 302, 308, 302, 308, 302, 308, 302, 302,
     308, 302, 308, 308, 308, 302, 302, 302, 302, 302, 308, 308, 308, 308, 308, 302, 308, 308, 308, 308, 302, 302, 308, 302, 302, },
  exits = {
    {
      x = 0,
      y = 6,
      tx = 22,
      ty = 13,
      room = 36,
    nil},
    {
      x = 13,
      y = 7,
      tx = 23,
      ty = 12,
      room = 33,
    nil},
    {
      x = 19,
      y = 6,
      tx = 2,
      ty = 3,
      room = 23,
    nil},
    {
      x = 4,
      y = 5,
      tx = -1,
      ty = -1,
      room = -1,
    nil},
    {
      x = 5,
      y = 5,
      tx = -1,
      ty = -1,
      room = -1,
    nil},
    {
      x = 10,
      y = 5,
      tx = -1,
      ty = -1,
      room = -1,
    nil},
    {
      x = 11,
      y = 5,
      tx = -1,
      ty = -1,
      room = -1,
    nil},
    {
      x = 17,
      y = 5,
      tx = -1,
      ty = -1,
      room = -1,
    nil},
    {
      x = 16,
      y = 5,
      tx = -1,
      ty = -1,
      room = -1,
    nil},
    {
      x = 22,
      y = 5,
      tx = -1,
      ty = -1,
      room = -1,
    nil},
    {
      x = 23,
      y = 5,
      tx = -1,
      ty = -1,
      room = -1,
    nil},
    {
      x = 20,
      y = 5,
      tx = 17,
      ty = 12,
      room = 37,
    nil},
  nil},
}
__pulp.rooms[41] = {
  id = 41,
  name = "art 10x10 Dancers1",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 277, 277, 277, 277, 277, 277, 277, 277, 277, 277,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 284, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 2,
      ty = 4,
      room = 12,
    nil},
  nil},
}
__pulp.rooms[42] = {
  id = 42,
  name = "art 10x10 Dancers2",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 285, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 5,
      ty = 4,
      room = 12,
    nil},
  nil},
}
__pulp.rooms[43] = {
  id = 43,
  name = "art 10x10 Dancers3",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 286, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 8,
      ty = 4,
      room = 12,
    nil},
  nil},
}
__pulp.rooms[44] = {
  id = 44,
  name = "art 10x10 Dancers4",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 280, 280, 280, 280, 280, 280, 280, 280, 280, 280,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 287, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 11,
      ty = 4,
      room = 12,
    nil},
  nil},
}
__pulp.rooms[45] = {
  id = 45,
  name = "art 10x10 Dancers5",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 281, 281, 281, 281, 281, 281, 281, 281, 281, 281,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 288, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 14,
      ty = 4,
      room = 12,
    nil},
  nil},
}
__pulp.rooms[46] = {
  id = 46,
  name = "art 10x10 Dancers6",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 282, 282, 282, 282, 282, 282, 282, 282, 282, 282,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 289, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 17,
      ty = 4,
      room = 12,
    nil},
  nil},
}
__pulp.rooms[47] = {
  id = 47,
  name = "art 16x10 dancers7",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  66,  66,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  97,  99,  66,  66,
      66,  66,  37, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283, 283,  36,  66,  98, 100,  66,  66,
      66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 290, 327,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 22,
      y = 12,
      tx = 21,
      ty = 4,
      room = 12,
    nil},
  nil},
}
__pulp.rooms[48] = {
  id = 48,
  name = "art 10x10 onlyNow",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37, 292, 292, 292, 292, 292, 292, 292, 292, 292, 292,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 293, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
    {
      x = 19,
      y = 12,
      tx = 14,
      ty = 11,
      room = 2,
    nil},
  nil},
}
__pulp.rooms[49] = {
  id = 49,
  name = "art 16x9 grid base",
  song = -1,
  tiles = {
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114,
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114,
     114, 114,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39, 114, 114, 114, 114, 114,
     114, 114,  37, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 295,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 295,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 295,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 295,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 295,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 295,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 295,  36, 114, 114, 114, 114, 114,
     114, 114,  37, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 298, 295,  36, 114,  97,  99, 114, 114,
     114, 114,  37, 301, 301, 301, 301, 301, 301, 301, 301, 301, 301, 301, 301, 301, 301, 301, 300,  36, 114,  98, 100, 114, 114,
     114, 114,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40, 114, 117, 327, 114, 114,
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 187, 114, 114,
     114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, },
  exits = {
  nil},
}
__pulp.rooms[50] = {
  id = 50,
  name = "art 10x10 randomGen",
  song = -1,
  tiles = {
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  38,  33,  33,  33,  33,  33,  33,  33,  33,  33,  33,  39,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  66,  66,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  97,  99,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  37,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  36,  66,  98, 100,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  41,  35,  35,  35,  35,  35,  35,  35,  35,  35,  35,  40,  66, 117, 327,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, 114, 187,  66,  66,  66,  66,  66,
      66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66, },
  exits = {
  nil},
}

__pulp.sounds = {}
__pulp.sounds[0] = {
  bpm = 120,
  name = "beep",
  type = 0,
  notes = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  ticks = 9,
  attack = 0.01,
}
__pulp.sounds[1] = {
  bpm = 120,
  name = "locked",
  type = 4,
  notes = {8, 4, 2, 0, 0, 0, 6, 4, 1, },
  ticks = 3,
}
__pulp.sounds[2] = {
  bpm = 120,
  name = "unlocked",
  type = 4,
  notes = {8, 4, 2, 0, 0, 0, 9, 4, 1, 8, 4, 2, 0, 0, 0, 6, 4, 1, },
  ticks = 6,
}
__pulp.sounds[3] = {
  bpm = 120,
  name = "stairs",
  type = 4,
  notes = {5, 4, 1, 0, 0, 0, 5, 4, 1, 0, 0, 0, 5, 4, 1, },
  ticks = 5,
}
__pulp.sounds[4] = {
  bpm = 120,
  name = "talking",
  type = 0,
  notes = {0, 0, 0, 7, 5, 1, 0, 0, 0, 9, 5, 1, 7, 5, 2, 0, 0, 0, 9, 5, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 5, 1, 10, 5, 1, 0, 0, 0, 8, 5, 1, 7, 5, 1, 6, 5, 1, 0, 0, 0, 7, 5, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 2, 0, 0, 0, 7, 5, 2, 0, 0, 0, 6, 5, 3, 0, 0, 0, 0, 0, 0, 8, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 5, 2, 0, 0, 0, 0, 0, 0, 10, 5, 1, 0, 0, 0, 8, 5, 2, 0, 0, 0, 6, 5, 2, 0, 0, 0, 0, 0, 0, 5, 5, 1, 4, 5, 1, 5, 5, 1, 4, 5, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  ticks = 54,
}
__pulp.sounds[5] = {
  bpm = 120,
  name = "anomaly",
  type = 0,
  notes = {0, 0, 0, 9, 6, 1, 6, 8, 1, 8, 7, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  ticks = 12,
}
__pulp.sounds[6] = {
  bpm = 120,
  name = "flush",
  type = 4,
  notes = {8, 2, 1, 6, 3, 2, 0, 0, 0, 10, 4, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
  ticks = 12,
}

__pulp.songs = {}
__pulp.songs[#__pulp.songs + 1] = {
  bpm = 120,
  id = 0,
  name = "theme",
  ticks = 7,
  notes = {
    {6, 4, 1, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, },
    {},
    {},
    {},
    {},
  },
  loopFrom = 0
,}
__pulp.songs[#__pulp.songs + 1] = {
  bpm = 120,
  id = 1,
  name = "walkabout",
  ticks = 64,
  notes = {
    {8, 4, 1, 0, 0, 0, 8, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 4, 1, 8, 4, 1, 8, 4, 1, 11, 4, 1, 8, 4, 1, 0, 0, 0, 8, 4, 1, 0, 0, 0, 8, 4, 1, 0, 0, 0, 6, 4, 1, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 6, 4, 1, 6, 4, 1, 9, 4, 1, 6, 4, 1, 0, 0, 0, 6, 4, 1, 0, 0, 0, 6, 4, 1, 0, 0, 0, 4, 4, 1, 0, 
0, 0, 4, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 1, 4, 4, 1, 4, 4, 1, 7, 4, 1, 4, 4, 1, 0, 0, 0, 4, 4, 1, 0, 0, 0, 4, 4, 1, 0, 0, 0, 8, 4, 1, 0, 0, 0, 8, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 4, 1, 8, 4, 1, 8, 4, 1, 11, 4, 1, 8, 4, 1, 0, 0, 0, 8, 4, 1, 0, 0, 0, 8, 4, 1, },
    {},
    {6, 4, 1, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 8, 4, 1, 5, 4, 1, 6, 4, 1, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 8, 4, 1, 5, 4, 1, 6, 4, 1, 0, 
0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 8, 4, 1, 5, 4, 1, 6, 4, 1, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 8, 4, 1, 5, 4, 1, },
    {},
    {0, 0, 0, 6, 4, 1, 5, 4, 1, 6, 4, 1, 0, 0, 0, 0, 0, 0, 7, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 4, 1, 0, 0, 0, 0, 0, 0, 9, 4, 1, 0, 0, 0, 0, 0, 0, 4, 4, 1, 3, 4, 1, 4, 4, 1, 0, 0, 0, 0, 0, 0, 5, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4, 1, 0, 0, 0, 0, 0, 0, 7, 4, 1, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 6, 4, 1, 5, 4, 1, 6, 4, 1, 0, 0, 0, 0, 0, 0, 7, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 4, 1, 0, 0, 0, 0, 0, 0, 9, 4, 1, 0, 0, 0, 0, 0, 0, 5, 4, 1, 4, 4, 1, 5, 4, 1, 0, 0, 0, 0, 0, 0, 6, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 1, 0, 0, 0, 0, 0, 0, 8, 4, 1, },
  },
  voices = {
    {},
    {},
    {
       volume = 0.5,
    },
    {},
    {
       volume = 0.5,
    },
  },
  loopFrom = 0
,}

----------------- game ----------------------------

__pulp:newScript("game")
__script[1] = __pulp:getScript("game")
__pulp:associateScript("game", "global", 0)

__pulp:getScript("game").load = function(__actor, event, __evname)
  __pulp.__fn_restore()
  if hasPlayed == 1 then
    __print("welcome back!")
  else
    __print("nice to meet you.")
  end
  hasPlayed = 1
  __pulp.__fn_store("hasPlayed")
end

__pulp:getScript("game").finish = function(__actor, event, __evname)
  __print("who are you again?")
  __pulp.__fn_toss()
end

----------------- player ----------------------------

__pulp:newScript("player")
__script[2] = __pulp:getScript("player")
__pulp:associateScript("player", "tile", 2)

__pulp:getScript("player").any = function(__actor, event, __evname)
  if maze == 0 then
    idle+=1
    if idle > 300 then
      __pulp.__fn_swap(__actor, "eyeball sleep")
    end
    maxIdle = 400
    if idle >= 400 then
      idle = maxIdle
    end
  end
end

__pulp:getScript("player").load = function(__actor, event, __evname)
  __pulp.__fn_swap(__actor, "eyeball D")
  __pulp.__fn_loop("walkabout")
end

__pulp:getScript("player").update = function(__actor, event, __evname)
  local __event_dy = event.dy or 0
  local __event_dx = event.dx or 0
  idle = 0
  if maze == 1 then
    __pulp.__fn_swap(__actor, "canopyWalk")
  elseif __event_dx == 1 then
    __pulp.__fn_swap(__actor, "eyeball R")
  elseif __event_dx == -1 then
    __pulp.__fn_swap(__actor, "eyeball L")
  elseif __event_dy == -1 then
    __pulp.__fn_swap(__actor, "eyeball U")
  elseif __event_dy == 1 then
    __pulp.__fn_swap(__actor, "eyeball D")
  end
end

----------------- computer ----------------------------

__pulp:newScript("computer")
__script[3] = __pulp:getScript("computer")
__pulp:associateScript("computer", "tile", 3)

__pulp:getScript("computer").interact = function(__actor, event, __evname)
  if disks == 0 then
    __pulp.__fn_say(nil, nil, nil, nil, __actor, event, __evname, nil, "You could play a game on this old computer if you had all of the floppies...")
  elseif disks == 1 then
    __pulp.__fn_say(nil, nil, nil, nil, __actor, event, __evname, nil, "You've found 1 floppy disk.")
  elseif disks == 4 then
    __pulp.__fn_say(nil, nil, nil, nil, __actor, event, __evname, function(__actor, event, evname)
        __pulp.__fn_fin("You whiled away the afternoon on the computer.\n\nThe End")
      end, "You've found all the floppy disks!")
  else
    __pulp.__fn_say(nil, nil, nil, nil, __actor, event, __evname, nil, "You've found " .. __tostring(disks) .. " floppy disks.")
  end
end

----------------- art 6x8 bleh ----------------------------

__pulp:newScript("art 6x8 bleh")
__script[4] = __pulp:getScript("art 6x8 bleh")
__pulp:associateScript("art 6x8 bleh", "room", 14)

__pulp:getScript("art 6x8 bleh").enter = function(__actor, event, __evname)
  x = 9
  y = 3
  f = 0
  while y <= 10 do
    while x <= 14 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 9
  end
end

----------------- art 6x8 cactus ----------------------------

__pulp:newScript("art 6x8 cactus")
__script[5] = __pulp:getScript("art 6x8 cactus")
__pulp:associateScript("art 6x8 cactus", "room", 17)

__pulp:getScript("art 6x8 cactus").enter = function(__actor, event, __evname)
  x = 9
  y = 3
  f = 0
  while y <= 10 do
    while x <= 14 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 9
  end
end

----------------- galleryFoyer ----------------------------

__pulp:newScript("galleryFoyer")
__script[6] = __pulp:getScript("galleryFoyer")
__pulp:associateScript("galleryFoyer", "room", 2)

----------------- art 6x8 dblcrow ----------------------------

__pulp:newScript("art 6x8 dblcrow")
__script[7] = __pulp:getScript("art 6x8 dblcrow")
__pulp:associateScript("art 6x8 dblcrow", "room", 15)

__pulp:getScript("art 6x8 dblcrow").enter = function(__actor, event, __evname)
  x = 9
  y = 3
  f = 0
  while y <= 10 do
    while x <= 14 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 9
  end
end

----------------- art 6x8 Doog ----------------------------

__pulp:newScript("art 6x8 Doog")
__script[8] = __pulp:getScript("art 6x8 Doog")
__pulp:associateScript("art 6x8 Doog", "room", 16)

__pulp:getScript("art 6x8 Doog").enter = function(__actor, event, __evname)
  x = 9
  y = 3
  f = 0
  while y <= 10 do
    while x <= 14 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 9
  end
end

----------------- art 6x8 ----------------------------

__pulp:newScript("art 6x8")
__script[9] = __pulp:getScript("art 6x8")
__pulp:associateScript("art 6x8", "room", 8)

__pulp:getScript("art 6x8").enter = function(__actor, event, __evname)
  x = 9
  y = 3
  f = 0
  while y <= 10 do
    while x <= 14 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 9
  end
end

----------------- art 16x9 ----------------------------

__pulp:newScript("art 16x9")
__script[10] = __pulp:getScript("art 16x9")
__pulp:associateScript("art 16x9", "room", 10)

__pulp:getScript("art 16x9").enter = function(__actor, event, __evname)
  x = 3
  y = 3
  f = 0
  while y <= 11 do
    while x <= 18 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 3
  end
end

----------------- art 10x10 no photo ----------------------------

__pulp:newScript("art 10x10 no photo")
__script[11] = __pulp:getScript("art 10x10 no photo")
__pulp:associateScript("art 10x10 no photo", "room", 18)

__pulp:getScript("art 10x10 no photo").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art 10x10 ----------------------------

__pulp:newScript("art 10x10")
__script[12] = __pulp:getScript("art 10x10")
__pulp:associateScript("art 10x10", "room", 19)

__pulp:getScript("art 10x10").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art triptych samPlay ----------------------------

__pulp:newScript("art triptych samPlay")
__script[13] = __pulp:getScript("art triptych samPlay")
__pulp:associateScript("art triptych samPlay", "room", 9)

__pulp:getScript("art triptych samPlay").enter = function(__actor, event, __evname)
  --art L
  x = 2
  y = 2
  f = 0
  while y <= 11 do
    while x <= 6 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 2
  end
  --art Center
  x = 10
  y = 2
  f = 50
  while y <= 11 do
    while x <= 14 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 10
  end
  --art R
  x = 18
  y = 2
  f = 100
  while y <= 11 do
    while x <= 22 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 18
  end
end

----------------- art 16x9 Wendy Pool ----------------------------

__pulp:newScript("art 16x9 Wendy Pool")
__script[14] = __pulp:getScript("art 16x9 Wendy Pool")
__pulp:associateScript("art 16x9 Wendy Pool", "room", 24)

__pulp:getScript("art 16x9 Wendy Pool").enter = function(__actor, event, __evname)
  x = 3
  y = 3
  f = 0
  while y <= 11 do
    while x <= 18 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 3
  end
end

----------------- art 10x10 overall cowboys ----------------------------

__pulp:newScript("art 10x10 overall cowboys")
__script[15] = __pulp:getScript("art 10x10 overall cowboys")
__pulp:associateScript("art 10x10 overall cowboys", "room", 26)

__pulp:getScript("art 10x10 overall cowboys").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art triptych ----------------------------

__pulp:newScript("art triptych")
__script[16] = __pulp:getScript("art triptych")
__pulp:associateScript("art triptych", "room", 27)

__pulp:getScript("art triptych").enter = function(__actor, event, __evname)
  --art L
  x = 2
  y = 2
  f = 0
  while y <= 11 do
    while x <= 6 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 2
  end
  --art Center
  x = 10
  y = 2
  f = 50
  while y <= 11 do
    while x <= 14 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 10
  end
  --art R
  x = 18
  y = 2
  f = 100
  while y <= 11 do
    while x <= 22 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 18
  end
end

----------------- art 16x9 skelesweet ----------------------------

__pulp:newScript("art 16x9 skelesweet")
__script[17] = __pulp:getScript("art 16x9 skelesweet")
__pulp:associateScript("art 16x9 skelesweet", "room", 29)

__pulp:getScript("art 16x9 skelesweet").enter = function(__actor, event, __evname)
  x = 3
  y = 3
  f = 0
  while y <= 11 do
    while x <= 18 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 3
  end
end

----------------- art sculpt- ----------------------------

__pulp:newScript("art sculpt-")
__script[18] = __pulp:getScript("art sculpt-")
__pulp:associateScript("art sculpt-", "room", 30)

__pulp:getScript("art sculpt-").enter = function(__actor, event, __evname)
  x = 9
  y = 3
  f = 0
  while y <= 10 do
    while x <= 14 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 9
  end
end

----------------- art 16x9 portal ----------------------------

__pulp:newScript("art 16x9 portal")
__script[19] = __pulp:getScript("art 16x9 portal")
__pulp:associateScript("art 16x9 portal", "room", 31)

__pulp:getScript("art 16x9 portal").enter = function(__actor, event, __evname)
  x = 3
  y = 3
  f = 0
  while y <= 11 do
    while x <= 18 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 3
  end
  do --[tell x,y to]
    local __actor = __roomtiles[6][12]
    if __actor and __actor.tile then
      __pulp.__fn_swap(__actor, "portal 1")
    end
  end

  do --[tell x,y to]
    local __actor = __roomtiles[6][13]
    if __actor and __actor.tile then
      __pulp.__fn_swap(__actor, "portal 2")
    end
  end

  do --[tell x,y to]
    local __actor = __roomtiles[7][12]
    if __actor and __actor.tile then
      __pulp.__fn_swap(__actor, "portal 3")
    end
  end

  do --[tell x,y to]
    local __actor = __roomtiles[7][13]
    if __actor and __actor.tile then
      __pulp.__fn_swap(__actor, "portal 4")
    end
  end

end

----------------- studioRestroom ----------------------------

__pulp:newScript("studioRestroom")
__script[20] = __pulp:getScript("studioRestroom")
__pulp:associateScript("studioRestroom", "room", 23)

__pulp:getScript("studioRestroom").enter = function(__actor, event, __evname)
  if anomaly >= 3 then
    --^adjust to total # arts in game
    do --[tell x,y to]
      local __actor = __roomtiles[4][23]
      if __actor and __actor.tile then
        __pulp.__fn_swap(__actor, "rr stall door")
      end
    end

  end
end

----------------- anomalyItem ----------------------------

__pulp:newScript("anomalyItem")
__script[21] = __pulp:getScript("anomalyItem")
__pulp:associateScript("anomalyItem", "tile", 187)

__pulp:getScript("anomalyItem").collect = function(__actor, event, __evname)
  anomaly += 1
  __pulp.__fn_swap(__actor, "intWall-txtWalk")
  __pulp.__fn_sound("anomaly")
end

----------------- art 10x10 TEXAS ----------------------------

__pulp:newScript("art 10x10 TEXAS")
__script[22] = __pulp:getScript("art 10x10 TEXAS")
__pulp:associateScript("art 10x10 TEXAS", "room", 32)

__pulp:getScript("art 10x10 TEXAS").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- forestMaze ----------------------------

__pulp:newScript("forestMaze")
__script[23] = __pulp:getScript("forestMaze")
__pulp:associateScript("forestMaze", "room", 35)

__pulp:getScript("forestMaze").exit = function(__actor, event, __evname)
  maze = 0
end

__pulp:getScript("forestMaze").enter = function(__actor, event, __evname)
  maze = 1
end

----------------- forestClearing- ----------------------------

__pulp:newScript("forestClearing-")
__script[24] = __pulp:getScript("forestClearing-")
__pulp:associateScript("forestClearing-", "room", 36)

----------------- art 10x10 orkn ----------------------------

__pulp:newScript("art 10x10 orkn")
__script[25] = __pulp:getScript("art 10x10 orkn")
__pulp:associateScript("art 10x10 orkn", "room", 39)

__pulp:getScript("art 10x10 orkn").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art 10x10 Dancers1 ----------------------------

__pulp:newScript("art 10x10 Dancers1")
__script[26] = __pulp:getScript("art 10x10 Dancers1")
__pulp:associateScript("art 10x10 Dancers1", "room", 41)

__pulp:getScript("art 10x10 Dancers1").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art 10x10 Dancers2 ----------------------------

__pulp:newScript("art 10x10 Dancers2")
__script[27] = __pulp:getScript("art 10x10 Dancers2")
__pulp:associateScript("art 10x10 Dancers2", "room", 42)

__pulp:getScript("art 10x10 Dancers2").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art 10x10 Dancers3 ----------------------------

__pulp:newScript("art 10x10 Dancers3")
__script[28] = __pulp:getScript("art 10x10 Dancers3")
__pulp:associateScript("art 10x10 Dancers3", "room", 43)

__pulp:getScript("art 10x10 Dancers3").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art 10x10 Dancers4 ----------------------------

__pulp:newScript("art 10x10 Dancers4")
__script[29] = __pulp:getScript("art 10x10 Dancers4")
__pulp:associateScript("art 10x10 Dancers4", "room", 44)

__pulp:getScript("art 10x10 Dancers4").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art 10x10 Dancers5 ----------------------------

__pulp:newScript("art 10x10 Dancers5")
__script[30] = __pulp:getScript("art 10x10 Dancers5")
__pulp:associateScript("art 10x10 Dancers5", "room", 45)

__pulp:getScript("art 10x10 Dancers5").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art 10x10 Dancers6 ----------------------------

__pulp:newScript("art 10x10 Dancers6")
__script[31] = __pulp:getScript("art 10x10 Dancers6")
__pulp:associateScript("art 10x10 Dancers6", "room", 46)

__pulp:getScript("art 10x10 Dancers6").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = 0
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 6
  end
end

----------------- art 16x10 dancers7 ----------------------------

__pulp:newScript("art 16x10 dancers7")
__script[32] = __pulp:getScript("art 16x10 dancers7")
__pulp:associateScript("art 16x10 dancers7", "room", 47)

__pulp:getScript("art 16x10 dancers7").enter = function(__actor, event, __evname)
  x = 3
  y = 3
  f = 0
  while y <= 11 do
    while x <= 18 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 3
  end
end

----------------- art 10x10 onlyNow ----------------------------

__pulp:newScript("art 10x10 onlyNow")
__script[33] = __pulp:getScript("art 10x10 onlyNow")
__pulp:associateScript("art 10x10 onlyNow", "room", 48)

__pulp:getScript("art 10x10 onlyNow").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = __random(0, 99)
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f = __random(0, 99)
    end
    y+=1
    x = 6
  end
end

----------------- art 16x9 grid base ----------------------------

__pulp:newScript("art 16x9 grid base")
__script[34] = __pulp:getScript("art 16x9 grid base")
__pulp:associateScript("art 16x9 grid base", "room", 49)

__pulp:getScript("art 16x9 grid base").enter = function(__actor, event, __evname)
  x = 3
  y = 3
  f = 0
  while y <= 11 do
    while x <= 18 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f+=1
    end
    y+=1
    x = 3
  end
end

----------------- art 10x10 randomGen ----------------------------

__pulp:newScript("art 10x10 randomGen")
__script[35] = __pulp:getScript("art 10x10 randomGen")
__pulp:associateScript("art 10x10 randomGen", "room", 50)

__pulp:getScript("art 10x10 randomGen").enter = function(__actor, event, __evname)
  --row 1
  x = 6
  y = 2
  f = __random(0, 99)
  while y <= 11 do
    while x <= 15 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __actor.frame = f
        end
      end

      x+=1
      f = __random(0, 99)
    end
    y+=1
    x = 6
  end
end

----------------- movin ----------------------------

__pulp:newScript("movin")
__script[36] = __pulp:getScript("movin")
__pulp:associateScript("movin", "tile", 326)

__pulp:getScript("movin").any = function(__actor, event, __evname)
  if x == 13 then
    __pulp.__fn_tell(event, __evname, function(__actor, event, evname)
        __pulp.__fn_goto(3, 5)
      end, movin)
  end
  if x == 3 then
    __pulp.__fn_tell(event, __evname, function(__actor, event, evname)
        __pulp.__fn_goto(23, 8)
      end, movin)
  end
  if x == 23 then
    __pulp.__fn_tell(event, __evname, function(__actor, event, evname)
        __pulp.__fn_goto(2, 12)
      end, movin)
  end
  if x == 2 then
    __pulp.__fn_tell(event, __evname, function(__actor, event, evname)
        __pulp.__fn_goto(13, 12)
      end, movin)
  end
end

local __LOCVARSET = {
  ["x"] = function(__x) x = __x end,
  ["y"] = function(__y) y = __y end,
  ["f"] = function(__f) f = __f end,
  ["disks"] = function(__disks) disks = __disks end,
  ["idle"] = function(__idle) idle = __idle end,
  ["maze"] = function(__maze) maze = __maze end,
  ["movin"] = function(__movin) movin = __movin end,
  ["anomaly"] = function(__anomaly) anomaly = __anomaly end,
  ["hasPlayed"] = function(__hasPlayed) hasPlayed = __hasPlayed end,
  ["maxIdle"] = function(__maxIdle) maxIdle = __maxIdle end,
nil}
local __LOCVARGET = {
  ["x"] = function() return x end,
  ["y"] = function() return y end,
  ["f"] = function() return f end,
  ["disks"] = function() return disks end,
  ["idle"] = function() return idle end,
  ["maze"] = function() return maze end,
  ["movin"] = function() return movin end,
  ["anomaly"] = function() return anomaly end,
  ["hasPlayed"] = function() return hasPlayed end,
  ["maxIdle"] = function() return maxIdle end,
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
  x = 0
  y = 0
  f = 0
  disks = 0
  idle = 0
  maze = 0
  movin = 0
  anomaly = 0
  hasPlayed = 0
  maxIdle = 0
end

__pulp:load()
__pulp:start()

return art7