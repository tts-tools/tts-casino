require('saves')

---@type table<string, PlayerInstance>
SEATED_PLAYERS = {}

function onSave()

end

function onLoad()
  local players = Player.getPlayers()

  for _, player in ipairs(players) do
    if player.color ~= 'Grey' then
      SEATED_PLAYERS[player.color] = player
    end
  end
end

---@param player_color string
function onPlayerChangeColor(player_color)
  if player_color == 'Grey' then
    for color, player in pairs(SEATED_PLAYERS) do
      if not Player[color].seated then
        SEATED_PLAYERS[color] = nil

        savePlayer(player.steam_id)

        if color == 'Black' then
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
      SEATED_PLAYERS[player_color] = player

      if player_color ~= 'Black' and COLOR_DETAILS[player_color] then
        local zone = getObjectFromGUID(COLOR_DETAILS[player_color].scripting_zone)
        if not zone then return end

        loadSave(player, zone.getPosition())

        zone.addTag('steam-' .. Player[player_color].steam_id)
      end

      return
    end
  end
end
