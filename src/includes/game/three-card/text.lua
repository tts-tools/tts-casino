---@type TablePositions
local THREE_CARD_POSITIONS = require('game.three-card.positions')

local TEXT_BASE = {
  Name = '3DText',
  Locked = true,

  Text = {
    Text = ' ',
    fontSize = 64,

    colorstate = {
      r = 1,
      g = 1,
      b = 1
    },
  },

  Transform = {
    rotX = 90,
    rotY = 180,
    rotZ = 0,
    scaleX = 0.8,
    scaleY = 0.8,
    scaleZ = 1
  },
}

---@return table<string, Object>
function loadText()
  local player_text = {} ---@type table<string, Object>

  for color, positions in pairs(THREE_CARD_POSITIONS.players) do
    local position = positions.cards[2]

    player_text[color] = spawnObjectData({
      data = TEXT_BASE,
      position = self.positionToWorld({ position[1], 1, position[3] + 3.15 })
    })

    player_text[color].addTag('game-object')
  end

  return player_text
end
