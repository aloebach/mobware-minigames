a_sketchy_etcher = {}

local history_index = 0
local px = 0
local py = 0
local from = 0
local onto = 0
local has_e = 0
local has_n = 0
local has_s = 0
local has_w = 0
local hx = 0
local hy = 0
local suffix = 0
local x = 0
local y = 0
local dx = 0
local dy = 0
local history_max = 0
local history_steps = 0
local tx = 0
local ty = 0
local history_top = 0
local lx = 0
local ly = 0
local mv = 0
local tick = 0
local flash = 0
local history_bottom = 0
local tile = 0
local history0_from = 0
local history0_onto = 0
local history0_x = 0
local history0_y = 0
local history1_from = 0
local history1_onto = 0
local history1_x = 0
local history1_y = 0
local history2_from = 0
local history2_onto = 0
local history2_x = 0
local history2_y = 0
local history3_from = 0
local history3_onto = 0
local history3_x = 0
local history3_y = 0
local history4_from = 0
local history4_onto = 0
local history4_x = 0
local history4_y = 0
local history5_from = 0
local history5_onto = 0
local history5_x = 0
local history5_y = 0
local history6_from = 0
local history6_onto = 0
local history6_x = 0
local history6_y = 0
local history7_from = 0
local history7_onto = 0
local history7_x = 0
local history7_y = 0
local history8_from = 0
local history8_onto = 0
local history8_x = 0
local history8_y = 0
local history9_from = 0
local history9_onto = 0
local history9_x = 0
local history9_y = 0

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
  startx = 2,
  starty = 2,
  gamename = "A Sketchy Etcher",
  halfwidth = false,
  pipe_img = playdate.graphics.imagetable.new("extras/a_sketchy_etcher/pipe"),
  font_img = playdate.graphics.imagetable.new("extras/a_sketchy_etcher/font"),
  tile_img = playdate.graphics.imagetable.new("extras/a_sketchy_etcher/tiles")
}
local __pulp <const> = ___pulp
import "extras/a_sketchy_etcher/pulp"
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
    fps = 4,
    name = "player",
    type = 1,
    btype = 1,
    solid = false,
    frames = {3,1, }
  }
__pulp.tiles[3] = {
    id = 3,
    fps = 1,
    name = "sprite",
    type = 2,
    btype = 0,
    solid = true,
    says = "",    frames = {1, }
  }
__pulp.tiles[4] = {
    id = 4,
    fps = 1,
    name = "trail nsew",
    type = 3,
    btype = 1,
    solid = false,
    frames = {4, }
  }
__pulp.tiles[5] = {
    id = 5,
    fps = 1,
    name = "black 2",
    type = 0,
    btype = -1,
    solid = true,
    frames = {5, }
  }
__pulp.tiles[6] = {
    id = 6,
    fps = 1,
    name = "black 3",
    type = 0,
    btype = -1,
    solid = true,
    frames = {6, }
  }
__pulp.tiles[7] = {
    id = 7,
    fps = 1,
    name = "black 4",
    type = 0,
    btype = -1,
    solid = true,
    frames = {7, }
  }
__pulp.tiles[8] = {
    id = 8,
    fps = 1,
    name = "trail ns",
    type = 3,
    btype = 1,
    solid = false,
    frames = {8, }
  }
__pulp.tiles[9] = {
    id = 9,
    fps = 1,
    name = "trail ne",
    type = 3,
    btype = 1,
    solid = false,
    frames = {9, }
  }
__pulp.tiles[10] = {
    id = 10,
    fps = 1,
    name = "trail nw",
    type = 3,
    btype = 1,
    solid = false,
    frames = {10, }
  }
__pulp.tiles[11] = {
    id = 11,
    fps = 1,
    name = "trail sw",
    type = 3,
    btype = 1,
    solid = false,
    frames = {11, }
  }
__pulp.tiles[12] = {
    id = 12,
    fps = 1,
    name = "trail se",
    type = 3,
    btype = 1,
    solid = false,
    frames = {12, }
  }
__pulp.tiles[13] = {
    id = 13,
    fps = 1,
    name = "trail ew",
    type = 3,
    btype = 1,
    solid = false,
    frames = {13, }
  }
__pulp.tiles[14] = {
    id = 14,
    fps = 1,
    name = "trail",
    type = 3,
    btype = 1,
    solid = false,
    frames = {1, }
  }
__pulp.tiles[15] = {
    id = 15,
    fps = 1,
    name = "trail n",
    type = 3,
    btype = 1,
    solid = false,
    frames = {14, }
  }
__pulp.tiles[16] = {
    id = 16,
    fps = 1,
    name = "trail s",
    type = 3,
    btype = 1,
    solid = false,
    frames = {15, }
  }
__pulp.tiles[17] = {
    id = 17,
    fps = 1,
    name = "trail e",
    type = 3,
    btype = 1,
    solid = false,
    frames = {16, }
  }
__pulp.tiles[18] = {
    id = 18,
    fps = 1,
    name = "trail w",
    type = 3,
    btype = 1,
    solid = false,
    frames = {17, }
  }
__pulp.tiles[19] = {
    id = 19,
    fps = 1,
    name = "trail nse",
    type = 3,
    btype = 1,
    solid = false,
    frames = {18, }
  }
__pulp.tiles[20] = {
    id = 20,
    fps = 1,
    name = "trail nsw",
    type = 3,
    btype = 1,
    solid = false,
    frames = {19, }
  }
__pulp.tiles[21] = {
    id = 21,
    fps = 1,
    name = "trail new",
    type = 3,
    btype = 1,
    solid = false,
    frames = {20, }
  }
__pulp.tiles[22] = {
    id = 22,
    fps = 1,
    name = "trail sew",
    type = 3,
    btype = 1,
    solid = false,
    frames = {21, }
  }
__pulp.tiles[23] = {
    id = 23,
    fps = 1,
    name = "black 5",
    type = 0,
    btype = -1,
    solid = true,
    frames = {22, }
  }
__pulp.tiles[24] = {
    id = 24,
    fps = 1,
    name = "black 6",
    type = 0,
    btype = -1,
    solid = true,
    frames = {23, }
  }
__pulp.tiles[25] = {
    id = 25,
    fps = 1,
    name = "black 7",
    type = 0,
    btype = -1,
    solid = true,
    frames = {24, }
  }
__pulp.tiles[26] = {
    id = 26,
    fps = 1,
    name = "black 8",
    type = 0,
    btype = -1,
    solid = true,
    frames = {25, }
  }
__pulp.tiles[27] = {
    id = 27,
    fps = 1,
    name = "black 9",
    type = 0,
    btype = -1,
    solid = true,
    frames = {26, }
  }
__pulp.tiles[28] = {
    id = 28,
    fps = 1,
    name = "A",
    type = 0,
    btype = -1,
    solid = true,
    frames = {27, }
  }
__pulp.tiles[29] = {
    id = 29,
    fps = 1,
    name = "S",
    type = 0,
    btype = -1,
    solid = true,
    frames = {28, }
  }
__pulp.tiles[30] = {
    id = 30,
    fps = 1,
    name = "K",
    type = 0,
    btype = -1,
    solid = true,
    frames = {29, }
  }
__pulp.tiles[31] = {
    id = 31,
    fps = 1,
    name = "E",
    type = 0,
    btype = -1,
    solid = true,
    frames = {30, }
  }
__pulp.tiles[32] = {
    id = 32,
    fps = 1,
    name = "T",
    type = 0,
    btype = -1,
    solid = true,
    frames = {31, }
  }
__pulp.tiles[33] = {
    id = 33,
    fps = 1,
    name = "C",
    type = 0,
    btype = -1,
    solid = true,
    frames = {32, }
  }
__pulp.tiles[34] = {
    id = 34,
    fps = 1,
    name = "H",
    type = 0,
    btype = -1,
    solid = true,
    frames = {33, }
  }
__pulp.tiles[35] = {
    id = 35,
    fps = 1,
    name = "Y",
    type = 0,
    btype = -1,
    solid = true,
    frames = {34, }
  }
__pulp.tiles[36] = {
    id = 36,
    fps = 1,
    name = "knob nw",
    type = 0,
    btype = -1,
    solid = true,
    frames = {35, }
  }
__pulp.tiles[37] = {
    id = 37,
    fps = 1,
    name = "knob ne",
    type = 0,
    btype = -1,
    solid = true,
    frames = {36, }
  }
__pulp.tiles[38] = {
    id = 38,
    fps = 1,
    name = "knob se",
    type = 0,
    btype = -1,
    solid = true,
    frames = {37, }
  }
__pulp.tiles[39] = {
    id = 39,
    fps = 1,
    name = "knob sw",
    type = 0,
    btype = -1,
    solid = true,
    frames = {38, }
  }
__pulp.tiles[40] = {
    id = 40,
    fps = 1,
    name = "black 10",
    type = 0,
    btype = -1,
    solid = true,
    frames = {39, }
  }
__pulp.tiles[41] = {
    id = 41,
    fps = 1,
    name = "black 11",
    type = 0,
    btype = -1,
    solid = true,
    frames = {40, }
  }
__pulp.tiles[42] = {
    id = 42,
    fps = 1,
    name = "black 12",
    type = 0,
    btype = -1,
    solid = true,
    frames = {41, }
  }
__pulp.tiles[43] = {
    id = 43,
    fps = 1,
    name = "black 13",
    type = 0,
    btype = -1,
    solid = true,
    frames = {42, }
  }
__pulp.tiles[44] = {
    id = 44,
    fps = 1,
    name = "black 14",
    type = 0,
    btype = -1,
    solid = true,
    frames = {43, }
  }
__pulp.tiles[45] = {
    id = 45,
    fps = 1,
    name = "black 15",
    type = 0,
    btype = -1,
    solid = true,
    frames = {44, }
  }

__pulp.rooms = {}
__pulp.rooms[0] = {
  id = 0,
  name = "start",
  song = -1,
  tiles = {
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
       1,   1,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,   1,   1,
      36,  37,   1,   1,   1,   1,   1,   1,   1,   1,   1,  40,  41,  42,   1,   1,   1,   1,   1,   1,   1,   1,   1,  36,  37,
      39,  38,   1,   1,   1,   1,   1,   1,   1,   1,   1,  43,  44,  45,   1,   1,   1,   1,   1,   1,   1,   1,   1,  39,  38, },
  exits = {
  nil},
}
__pulp.rooms[1] = {
  id = 1,
  name = "card",
  song = -1,
  tiles = {
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,  28,   1,  29,  30,  31,  32,  33,  34,  35,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   0,   0,   1,   0,   0,   0,   1,   5,   0,   0,   1,   0,   1,   0,   1,   0,   0,   1,   0,   0,  23,   1,   1,
       1,   1,   0,   1,   1,   1,   0,   1,   1,   0,  24,   1,   1,   0,   1,   0,   1,   0,   1,   1,   0,  26,   0,   1,   1,
       1,   1,   0,   0,   1,   1,   0,   1,   1,   0,   1,   1,   1,   0,   0,   0,   1,   0,   0,   1,   0,   0,   7,   1,   1,
       1,   1,   0,   1,   1,   1,   0,   1,   1,   0,  25,   1,   1,   0,   1,   0,   1,   0,   1,   1,   0,  27,   0,   1,   1,
       1,   1,   0,   0,   1,   1,   0,   1,   1,   6,   0,   0,   1,   0,   1,   0,   1,   0,   0,   1,   0,   1,   0,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
       1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1, },
  exits = {
  nil},
}

__pulp.sounds = {}
__pulp.sounds[0] = {
  bpm = 120,
  name = "beep",
  type = 0,
  notes = {},
  ticks = 0,
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
  --config.inputRepeatDelay = 0.2
  --config.inputRepeatBetween = 0.2
  tick = 0
  flash = 1
end

__pulp:getScript("game").loop = function(__actor, event, __evname)
  tick += 1
  if tick > 5 then
    tick -= 5
    flash *= -1
  end
end

----------------- player ----------------------------

__pulp:newScript("player")
__script[2] = __pulp:getScript("player")
__pulp:associateScript("player", "tile", 2)

__pulp:getScript("player").draw = function(__actor, event, __evname)
  __pulp.__fn_hide()
  x = px
  x *= 8
  x += 2
  y = py
  y *= 8
  y += 2
  __setcolour(__fillcolours["white"]); __fillrect(x * __pix8scale, y * __pix8scale, 4 * __pix8scale, 4 * __pix8scale)
  if flash == 1 then
    x += 1
    y += 1
    __setcolour(__fillcolours["black"]); __fillrect(x * __pix8scale, y * __pix8scale, 2 * __pix8scale, 2 * __pix8scale)
  end
end

__pulp:getScript("player").push = function(__actor, event, __evname)
  history_steps += 1
  history_index += 1
  if history_steps > history_top then
    history_top += 1
    history_bottom += 1
  end
  if history_index == history_max then
    history_index -= history_max
  end
  hx = lx
  hy = ly
  if history_index == 0 then
    history0_x = hx
    history0_y = hy
    history0_from = from
    history0_onto = onto
  elseif history_index == 1 then
    history1_x = hx
    history1_y = hy
    history1_from = from
    history1_onto = onto
  elseif history_index == 2 then
    history2_x = hx
    history2_y = hy
    history2_from = from
    history2_onto = onto
  elseif history_index == 3 then
    history3_x = hx
    history3_y = hy
    history3_from = from
    history3_onto = onto
  elseif history_index == 4 then
    history4_x = hx
    history4_y = hy
    history4_from = from
    history4_onto = onto
  elseif history_index == 5 then
    history5_x = hx
    history5_y = hy
    history5_from = from
    history5_onto = onto
  elseif history_index == 6 then
    history6_x = hx
    history6_y = hy
    history6_from = from
    history6_onto = onto
  elseif history_index == 7 then
    history7_x = hx
    history7_y = hy
    history7_from = from
    history7_onto = onto
  elseif history_index == 8 then
    history8_x = hx
    history8_y = hy
    history8_from = from
    history8_onto = onto
  elseif history_index == 9 then
    history9_x = hx
    history9_y = hy
    history9_from = from
    history9_onto = onto
  end
end

__pulp:getScript("player").redo = function(__actor, event, __evname)
  local __self = __script[2] --[this script]
  --TODO: currently broken
  if history_steps <= history_top then
    history_steps += 1
    history_index += 1
    if history_index == history_max then
      history_index -= history_max
    end
    --log "redo i:{history_index} steps:{history_steps}"
    __self.step(__actor, event, "step") 
  end
end

__pulp:getScript("player").step = function(__actor, event, __evname)
  hx = px
  hy = py
  if history_index == 0 then
    px = history0_x
    py = history0_y
    from = history0_from
    onto = history0_onto
  elseif history_index == 1 then
    px = history1_x
    py = history1_y
    from = history1_from
    onto = history1_onto
  elseif history_index == 2 then
    px = history2_x
    py = history2_y
    from = history2_from
    onto = history2_onto
  elseif history_index == 3 then
    px = history3_x
    py = history3_y
    from = history3_from
    onto = history3_onto
  elseif history_index == 4 then
    px = history4_x
    py = history4_y
    from = history4_from
    onto = history4_onto
  elseif history_index == 5 then
    px = history5_x
    py = history5_y
    from = history5_from
    onto = history5_onto
  elseif history_index == 6 then
    px = history6_x
    py = history6_y
    from = history6_from
    onto = history6_onto
  elseif history_index == 7 then
    px = history7_x
    py = history7_y
    from = history7_from
    onto = history7_onto
  elseif history_index == 8 then
    px = history8_x
    py = history8_y
    from = history8_from
    onto = history8_onto
  elseif history_index == 9 then
    px = history9_x
    py = history9_y
    from = history9_from
    onto = history9_onto
  end
  do --[tell x,y to]
    local __actor = __roomtiles[hy][hx]
    if __actor and __actor.tile then
      __pulp.__fn_swap(__actor, __tostring(onto))
    end
  end

  do --[tell x,y to]
    local __actor = __roomtiles[py][px]
    if __actor and __actor.tile then
      __pulp.__fn_swap(__actor, __tostring(from))
    end
  end

end

__pulp:getScript("player").undo = function(__actor, event, __evname)
  local __self = __script[2] --[this script]
  if history_steps > history_bottom then
    --log "undo i:{history_index} steps:{history_steps}"
    __self.step(__actor, event, "step") 
    history_steps -= 1
    history_index -= 1
    if history_index < 0 then
      history_index += history_max
    end
  end
end

__pulp:getScript("player").clear = function(__actor, event, __evname)
  local __self = __script[2] --[this script]
  y = 2
  while y < 13 do
    x = 2
    while x < 23 do
      do --[tell x,y to]
        local __actor = __roomtiles[y][x]
        if __actor and __actor.tile then
          __pulp.__fn_swap(__actor, "trail")
        end
      end

      x += 1
    end
    y += 1
  end
  __self.reset(__actor, event, "reset") 
end

__pulp:getScript("player").enter = function(__actor, event, __evname)
  local __self = __script[2] --[this script]
  local __event_py = __pulp.player.y
  local __event_px = __pulp.player.x
  --turtle state
  px = __event_px
  py = __event_py
  dx = 0
  dy = 0
  __self.reset(__actor, event, "reset") 
end

__pulp:getScript("player").reset = function(__actor, event, __evname)
  history_max = 10
  history_bottom = 0
  history_top = history_max
  history_steps = 0
  --^total moves made
  history_index = 0
  --^index in the 10 slots
end

__pulp:getScript("player").cancel = function(__actor, event, __evname)
  local __self = __script[2] --[this script]
  __self.undo(__actor, event, "undo") 
end

__pulp:getScript("player").update = function(__actor, event, __evname)
  local __self = __script[2] --[this script]
  local __event_dy = event.dy or 0
  local __event_dx = event.dx or 0
  lx = px
  ly = py
  dx = __event_dx
  dy = __event_dy
  px += dx
  py += dy
  --clamp
  if px < 2 then
    px = 2
  elseif px > 22 then
    px = 22
  end
  if py < 2 then
    py = 2
  elseif py > 12 then
    py = 12
  end
  dx = px
  dy = py
  dx -= lx
  dy -= ly
  mv = 0
  if dx ~= 0 then
    mv += 1
  end
  if dy ~= 0 then
    mv += 1
  end
  --have we really moved?
  if mv > 0 then
    --update the previous tile
    tx = lx
    ty = ly
    from = __roomtiles[ty][tx].name
    onto = __roomtiles[py][px].name
    __self.push(__actor, event, "push") 
    __self.connect(__actor, event, "connect") 
    --update current tile
    tx = px
    ty = py
    --flip direction so we connect to
    --the direction we just came from
    --not the direction we're heading
    dx *= -1
    dy *= -1
    __self.connect(__actor, event, "connect") 
  end
end

__pulp:getScript("player").confirm = function(__actor, event, __evname)
  local __self = __script[2] -- [this script]
  --call "redo" // TODO: currently broken
  --__self.clear(__actor, event, "clear") 
end

__pulp:getScript("player").connect = function(__actor, event, __evname)
  do --[tell x,y to]
    local __actor = __roomtiles[ty][tx]
    if __actor and __actor.tile then
      ;(__actor.script.connections or __actor.script.any)(__actor, event, "connections") --[call ""connections""]
    end
  end

  if dy < 0 then
    has_n = 1
  elseif dy > 0 then
    has_s = 1
  end
  if dx < 0 then
    has_w = 1
  elseif dx > 0 then
    has_e = 1
  end
  suffix = " "
  if has_n == 1 then
    suffix = __tostring(suffix) .. "n"
  end
  if has_s == 1 then
    suffix = __tostring(suffix) .. "s"
  end
  if has_e == 1 then
    suffix = __tostring(suffix) .. "e"
  end
  if has_w == 1 then
    suffix = __tostring(suffix) .. "w"
  end
  if suffix == " " then
    tile = "trail"
  else
    tile = "trail" .. __tostring(suffix)
  end
  do --[tell x,y to]
    local __actor = __roomtiles[ty][tx]
    if __actor and __actor.tile then
      __pulp.__fn_swap(__actor, __tostring(tile))
    end
  end

end

----------------- trail nsew ----------------------------

__pulp:newScript("trail nsew")
__script[3] = __pulp:getScript("trail nsew")
__pulp:associateScript("trail nsew", "tile", 4)

__pulp:getScript("trail nsew").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail nsew").connections = function(__actor, event, __evname)
  has_n = 1
  has_s = 1
  has_e = 1
  has_w = 1
end

----------------- trail ns ----------------------------

__pulp:newScript("trail ns")
__script[4] = __pulp:getScript("trail ns")
__pulp:associateScript("trail ns", "tile", 8)

__pulp:getScript("trail ns").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail ns").connections = function(__actor, event, __evname)
  has_n = 1
  has_s = 1
  has_e = 0
  has_w = 0
end

----------------- trail ne ----------------------------

__pulp:newScript("trail ne")
__script[5] = __pulp:getScript("trail ne")
__pulp:associateScript("trail ne", "tile", 9)

__pulp:getScript("trail ne").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail ne").connections = function(__actor, event, __evname)
  has_n = 1
  has_s = 0
  has_e = 1
  has_w = 0
end

----------------- trail nw ----------------------------

__pulp:newScript("trail nw")
__script[6] = __pulp:getScript("trail nw")
__pulp:associateScript("trail nw", "tile", 10)

__pulp:getScript("trail nw").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail nw").connections = function(__actor, event, __evname)
  has_n = 1
  has_s = 0
  has_e = 0
  has_w = 1
end

----------------- trail sw ----------------------------

__pulp:newScript("trail sw")
__script[7] = __pulp:getScript("trail sw")
__pulp:associateScript("trail sw", "tile", 11)

__pulp:getScript("trail sw").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail sw").connections = function(__actor, event, __evname)
  has_n = 0
  has_s = 1
  has_e = 0
  has_w = 1
end

----------------- trail se ----------------------------

__pulp:newScript("trail se")
__script[8] = __pulp:getScript("trail se")
__pulp:associateScript("trail se", "tile", 12)

__pulp:getScript("trail se").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail se").connections = function(__actor, event, __evname)
  has_n = 0
  has_s = 1
  has_e = 1
  has_w = 0
end

----------------- trail ew ----------------------------

__pulp:newScript("trail ew")
__script[9] = __pulp:getScript("trail ew")
__pulp:associateScript("trail ew", "tile", 13)

__pulp:getScript("trail ew").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail ew").connections = function(__actor, event, __evname)
  has_n = 0
  has_s = 0
  has_e = 1
  has_w = 1
end

----------------- trail ----------------------------

__pulp:newScript("trail")
__script[10] = __pulp:getScript("trail")
__pulp:associateScript("trail", "tile", 14)

__pulp:getScript("trail").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail").connections = function(__actor, event, __evname)
  has_n = 0
  has_s = 0
  has_e = 0
  has_w = 0
end

----------------- trail n ----------------------------

__pulp:newScript("trail n")
__script[11] = __pulp:getScript("trail n")
__pulp:associateScript("trail n", "tile", 15)

__pulp:getScript("trail n").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail n").connections = function(__actor, event, __evname)
  has_n = 1
  has_s = 0
  has_e = 0
  has_w = 0
end

----------------- trail s ----------------------------

__pulp:newScript("trail s")
__script[12] = __pulp:getScript("trail s")
__pulp:associateScript("trail s", "tile", 16)

__pulp:getScript("trail s").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail s").connections = function(__actor, event, __evname)
  has_n = 0
  has_s = 1
  has_e = 0
  has_w = 0
end

----------------- trail e ----------------------------

__pulp:newScript("trail e")
__script[13] = __pulp:getScript("trail e")
__pulp:associateScript("trail e", "tile", 17)

__pulp:getScript("trail e").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail e").connections = function(__actor, event, __evname)
  has_n = 0
  has_s = 0
  has_e = 1
  has_w = 0
end

----------------- trail w ----------------------------

__pulp:newScript("trail w")
__script[14] = __pulp:getScript("trail w")
__pulp:associateScript("trail w", "tile", 18)

__pulp:getScript("trail w").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail w").connections = function(__actor, event, __evname)
  has_n = 0
  has_s = 0
  has_e = 0
  has_w = 1
end

----------------- trail nse ----------------------------

__pulp:newScript("trail nse")
__script[15] = __pulp:getScript("trail nse")
__pulp:associateScript("trail nse", "tile", 19)

__pulp:getScript("trail nse").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail nse").connections = function(__actor, event, __evname)
  has_n = 1
  has_s = 1
  has_e = 1
  has_w = 0
end

----------------- trail nsw ----------------------------

__pulp:newScript("trail nsw")
__script[16] = __pulp:getScript("trail nsw")
__pulp:associateScript("trail nsw", "tile", 20)

__pulp:getScript("trail nsw").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail nsw").connections = function(__actor, event, __evname)
  has_n = 1
  has_s = 1
  has_e = 0
  has_w = 1
end

----------------- trail new ----------------------------

__pulp:newScript("trail new")
__script[17] = __pulp:getScript("trail new")
__pulp:associateScript("trail new", "tile", 21)

__pulp:getScript("trail new").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail new").connections = function(__actor, event, __evname)
  has_n = 1
  has_s = 0
  has_e = 1
  has_w = 1
end

----------------- trail sew ----------------------------

__pulp:newScript("trail sew")
__script[18] = __pulp:getScript("trail sew")
__pulp:associateScript("trail sew", "tile", 22)

__pulp:getScript("trail sew").collect = function(__actor, event, __evname)
  --buh
end

__pulp:getScript("trail sew").connections = function(__actor, event, __evname)
  has_n = 0
  has_s = 1
  has_e = 1
  has_w = 1
end

local __LOCVARSET = {
  ["history_index"] = function(__history_index) history_index = __history_index end,
  ["px"] = function(__px) px = __px end,
  ["py"] = function(__py) py = __py end,
  ["from"] = function(__from) from = __from end,
  ["onto"] = function(__onto) onto = __onto end,
  ["has_e"] = function(__has_e) has_e = __has_e end,
  ["has_n"] = function(__has_n) has_n = __has_n end,
  ["has_s"] = function(__has_s) has_s = __has_s end,
  ["has_w"] = function(__has_w) has_w = __has_w end,
  ["hx"] = function(__hx) hx = __hx end,
  ["hy"] = function(__hy) hy = __hy end,
  ["suffix"] = function(__suffix) suffix = __suffix end,
  ["x"] = function(__x) x = __x end,
  ["y"] = function(__y) y = __y end,
  ["dx"] = function(__dx) dx = __dx end,
  ["dy"] = function(__dy) dy = __dy end,
  ["history_max"] = function(__history_max) history_max = __history_max end,
  ["history_steps"] = function(__history_steps) history_steps = __history_steps end,
  ["tx"] = function(__tx) tx = __tx end,
  ["ty"] = function(__ty) ty = __ty end,
  ["history_top"] = function(__history_top) history_top = __history_top end,
  ["lx"] = function(__lx) lx = __lx end,
  ["ly"] = function(__ly) ly = __ly end,
  ["mv"] = function(__mv) mv = __mv end,
  ["tick"] = function(__tick) tick = __tick end,
  ["flash"] = function(__flash) flash = __flash end,
  ["history_bottom"] = function(__history_bottom) history_bottom = __history_bottom end,
  ["tile"] = function(__tile) tile = __tile end,
  ["history0_from"] = function(__history0_from) history0_from = __history0_from end,
  ["history0_onto"] = function(__history0_onto) history0_onto = __history0_onto end,
  ["history0_x"] = function(__history0_x) history0_x = __history0_x end,
  ["history0_y"] = function(__history0_y) history0_y = __history0_y end,
  ["history1_from"] = function(__history1_from) history1_from = __history1_from end,
  ["history1_onto"] = function(__history1_onto) history1_onto = __history1_onto end,
  ["history1_x"] = function(__history1_x) history1_x = __history1_x end,
  ["history1_y"] = function(__history1_y) history1_y = __history1_y end,
  ["history2_from"] = function(__history2_from) history2_from = __history2_from end,
  ["history2_onto"] = function(__history2_onto) history2_onto = __history2_onto end,
  ["history2_x"] = function(__history2_x) history2_x = __history2_x end,
  ["history2_y"] = function(__history2_y) history2_y = __history2_y end,
  ["history3_from"] = function(__history3_from) history3_from = __history3_from end,
  ["history3_onto"] = function(__history3_onto) history3_onto = __history3_onto end,
  ["history3_x"] = function(__history3_x) history3_x = __history3_x end,
  ["history3_y"] = function(__history3_y) history3_y = __history3_y end,
  ["history4_from"] = function(__history4_from) history4_from = __history4_from end,
  ["history4_onto"] = function(__history4_onto) history4_onto = __history4_onto end,
  ["history4_x"] = function(__history4_x) history4_x = __history4_x end,
  ["history4_y"] = function(__history4_y) history4_y = __history4_y end,
  ["history5_from"] = function(__history5_from) history5_from = __history5_from end,
  ["history5_onto"] = function(__history5_onto) history5_onto = __history5_onto end,
  ["history5_x"] = function(__history5_x) history5_x = __history5_x end,
  ["history5_y"] = function(__history5_y) history5_y = __history5_y end,
  ["history6_from"] = function(__history6_from) history6_from = __history6_from end,
  ["history6_onto"] = function(__history6_onto) history6_onto = __history6_onto end,
  ["history6_x"] = function(__history6_x) history6_x = __history6_x end,
  ["history6_y"] = function(__history6_y) history6_y = __history6_y end,
  ["history7_from"] = function(__history7_from) history7_from = __history7_from end,
  ["history7_onto"] = function(__history7_onto) history7_onto = __history7_onto end,
  ["history7_x"] = function(__history7_x) history7_x = __history7_x end,
  ["history7_y"] = function(__history7_y) history7_y = __history7_y end,
  ["history8_from"] = function(__history8_from) history8_from = __history8_from end,
  ["history8_onto"] = function(__history8_onto) history8_onto = __history8_onto end,
  ["history8_x"] = function(__history8_x) history8_x = __history8_x end,
  ["history8_y"] = function(__history8_y) history8_y = __history8_y end,
  ["history9_from"] = function(__history9_from) history9_from = __history9_from end,
  ["history9_onto"] = function(__history9_onto) history9_onto = __history9_onto end,
  ["history9_x"] = function(__history9_x) history9_x = __history9_x end,
  ["history9_y"] = function(__history9_y) history9_y = __history9_y end,
nil}
local __LOCVARGET = {
  ["history_index"] = function() return history_index end,
  ["px"] = function() return px end,
  ["py"] = function() return py end,
  ["from"] = function() return from end,
  ["onto"] = function() return onto end,
  ["has_e"] = function() return has_e end,
  ["has_n"] = function() return has_n end,
  ["has_s"] = function() return has_s end,
  ["has_w"] = function() return has_w end,
  ["hx"] = function() return hx end,
  ["hy"] = function() return hy end,
  ["suffix"] = function() return suffix end,
  ["x"] = function() return x end,
  ["y"] = function() return y end,
  ["dx"] = function() return dx end,
  ["dy"] = function() return dy end,
  ["history_max"] = function() return history_max end,
  ["history_steps"] = function() return history_steps end,
  ["tx"] = function() return tx end,
  ["ty"] = function() return ty end,
  ["history_top"] = function() return history_top end,
  ["lx"] = function() return lx end,
  ["ly"] = function() return ly end,
  ["mv"] = function() return mv end,
  ["tick"] = function() return tick end,
  ["flash"] = function() return flash end,
  ["history_bottom"] = function() return history_bottom end,
  ["tile"] = function() return tile end,
  ["history0_from"] = function() return history0_from end,
  ["history0_onto"] = function() return history0_onto end,
  ["history0_x"] = function() return history0_x end,
  ["history0_y"] = function() return history0_y end,
  ["history1_from"] = function() return history1_from end,
  ["history1_onto"] = function() return history1_onto end,
  ["history1_x"] = function() return history1_x end,
  ["history1_y"] = function() return history1_y end,
  ["history2_from"] = function() return history2_from end,
  ["history2_onto"] = function() return history2_onto end,
  ["history2_x"] = function() return history2_x end,
  ["history2_y"] = function() return history2_y end,
  ["history3_from"] = function() return history3_from end,
  ["history3_onto"] = function() return history3_onto end,
  ["history3_x"] = function() return history3_x end,
  ["history3_y"] = function() return history3_y end,
  ["history4_from"] = function() return history4_from end,
  ["history4_onto"] = function() return history4_onto end,
  ["history4_x"] = function() return history4_x end,
  ["history4_y"] = function() return history4_y end,
  ["history5_from"] = function() return history5_from end,
  ["history5_onto"] = function() return history5_onto end,
  ["history5_x"] = function() return history5_x end,
  ["history5_y"] = function() return history5_y end,
  ["history6_from"] = function() return history6_from end,
  ["history6_onto"] = function() return history6_onto end,
  ["history6_x"] = function() return history6_x end,
  ["history6_y"] = function() return history6_y end,
  ["history7_from"] = function() return history7_from end,
  ["history7_onto"] = function() return history7_onto end,
  ["history7_x"] = function() return history7_x end,
  ["history7_y"] = function() return history7_y end,
  ["history8_from"] = function() return history8_from end,
  ["history8_onto"] = function() return history8_onto end,
  ["history8_x"] = function() return history8_x end,
  ["history8_y"] = function() return history8_y end,
  ["history9_from"] = function() return history9_from end,
  ["history9_onto"] = function() return history9_onto end,
  ["history9_x"] = function() return history9_x end,
  ["history9_y"] = function() return history9_y end,
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
  history_index = 0
  px = 0
  py = 0
  from = 0
  onto = 0
  has_e = 0
  has_n = 0
  has_s = 0
  has_w = 0
  hx = 0
  hy = 0
  suffix = 0
  x = 0
  y = 0
  dx = 0
  dy = 0
  history_max = 0
  history_steps = 0
  tx = 0
  ty = 0
  history_top = 0
  lx = 0
  ly = 0
  mv = 0
  tick = 0
  flash = 0
  history_bottom = 0
  tile = 0
  history0_from = 0
  history0_onto = 0
  history0_x = 0
  history0_y = 0
  history1_from = 0
  history1_onto = 0
  history1_x = 0
  history1_y = 0
  history2_from = 0
  history2_onto = 0
  history2_x = 0
  history2_y = 0
  history3_from = 0
  history3_onto = 0
  history3_x = 0
  history3_y = 0
  history4_from = 0
  history4_onto = 0
  history4_x = 0
  history4_y = 0
  history5_from = 0
  history5_onto = 0
  history5_x = 0
  history5_y = 0
  history6_from = 0
  history6_onto = 0
  history6_x = 0
  history6_y = 0
  history7_from = 0
  history7_onto = 0
  history7_x = 0
  history7_y = 0
  history8_from = 0
  history8_onto = 0
  history8_x = 0
  history8_y = 0
  history9_from = 0
  history9_onto = 0
  history9_x = 0
  history9_y = 0
end

__pulp:load()
__pulp:start()

return a_sketchy_etcher
