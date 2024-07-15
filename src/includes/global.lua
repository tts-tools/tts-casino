require('saves')
require('utils.chips')

---@type table<string, ColorDetailLoaded>
POSITIONS = {}

---@type table<string, SeatedPlayer>
SEATED_PLAYERS = {}

---@type table<string, SeatedPlayer>
SEATED_PLAYERS_STEAM = {}

function onSave()

end

function onLoad()
  local players = Player.getPlayers()

  for _, player in ipairs(players) do
    if player.color ~= 'Grey' then
      local seated_player = {
        color = player.color,
        steam_id = player.steam_id,
        steam_name = player.steam_name
      }

      SEATED_PLAYERS[player.color] = seated_player
      SEATED_PLAYERS_STEAM[player.steam_id] = seated_player
    end
  end

  addHotkey('Payout', function (player_color, _, pointer_position, is_key_up)
    if not is_key_up then return end

    local game_guid = self.getVar('game')
    local game = getObjectFromGUID(game_guid)
    if not game then return end

    game.call('onPayout', {
      position = pointer_position,
      player_color = player_color,
    })
  end, true)

  for color, details in pairs(COLOR_DETAILS) do
    local board = getObjectFromGUID(details.board)
    local exchange_zone = getObjectFromGUID(details.exchange_zone)
    local scripting_zone = getObjectFromGUID(details.scripting_zone)

    POSITIONS[color] = {
      board = board,
      exchange_zone = exchange_zone,
      scripting_zone = scripting_zone,
    }

    if not board or not exchange_zone then break end

    board.UI.setAttribute('btn-trade-up', 'onClick', 'Global/tradeUpButtonClick(' .. color .. ')')
    board.UI.setAttribute('btn-trade-down', 'onClick', 'Global/tradeDownButtonClick(' .. color .. ')')
  end

  togglePlayerTotals()

  startLuaCoroutine(self, 'calculatePlayerChips')
end

function calculatePlayerChips()
  while true do
    for color, player in pairs(SEATED_PLAYERS) do
      local board = POSITIONS[color].board
      if board then
        local chips = getObjectsWithAllTags({ 'chip', 'steam:' .. player.steam_id })
        local chip_counts = calculateChipCounts(chips)

        local total = calculateChipsValue(chip_counts)
        if total then
          board.UI.setValue('total', 'Total: $' .. total)
        end
      end
    end

    wait(2)
  end

  return 1
end

function togglePlayerTotals()
  local seater_players = {} ---@type table<string, bool>
  for _, color in pairs(getSeatedPlayers()) do
    seater_players[color] = true
  end

  for color, details in pairs(POSITIONS) do
    if not details.board then return end

    if not seater_players[color] and details.board then
      details.board.UI.setAttribute('total', 'active', 'false')
      details.board.UI.setValue('total', 'Total: $0')
    elseif details.board then
      details.board.UI.setAttribute('total', 'active', 'true')
    end
  end
end

---@param player_color string
function onPlayerChangeColor(player_color)
  togglePlayerTotals()

  if player_color == 'Grey' then
    for color, player in pairs(SEATED_PLAYERS) do
      if not Player[color] or not Player[color].seated then
        SEATED_PLAYERS_STEAM[player.steam_id] = nil
        SEATED_PLAYERS[color] = nil

        savePlayer(player)

        if color == 'Black' or color == 'White' then
          return
        end

        local zone = getObjectFromGUID(COLOR_DETAILS[color].scripting_zone)
        if zone then
          zone.setTags({})
        end
      end
    end

    return
  end

  local players = Player.getPlayers()
  for _, player in ipairs(players) do
    if player.color == player_color then
      local seated_player = {
        color = player.color,
        steam_id = player.steam_id,
        steam_name = player.steam_name
      }

      SEATED_PLAYERS[player_color] = seated_player
      SEATED_PLAYERS_STEAM[player.steam_id] = seated_player

      if player_color ~= 'Black' and COLOR_DETAILS[player_color] then
        local zone = getObjectFromGUID(COLOR_DETAILS[player_color].scripting_zone)
        if not zone then return end

        loadSave(SEATED_PLAYERS[player_color], zone.getPosition())

        zone.addTag('steam:' .. Player[player_color].steam_id)
      end

      return
    end
  end
end

---@param container Object
---@param object Object
function onObjectLeaveContainer(container, object)
  if container.hasTag('chip') then
    object.addTag('chip')
  end
end

---@param player PlayerInstance
---@param color string
function tradeUpButtonClick(player, color)
  -- TODO
end

---@param player PlayerInstance
---@param color string
function tradeDownButtonClick(player, color)
  -- TODO
end
