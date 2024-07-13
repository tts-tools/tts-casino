require('saves')

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
end

---@param player_color string
function onPlayerChangeColor(player_color)
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
