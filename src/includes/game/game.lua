require('utils.class')
require('utils.strings')

local base = self

class 'Game' {
  bet_zones = {},
  card_zones = {},
  game_states = {},
  previous_bets = {},
  hand_positions = {},

  hands = {},
  restart = false,
  game_state = 0,
  dealer_cards = {},
  player_cards = {},
  hands_playing = {},
  community_cards = {},

  constructor = function (self, positions, hand_ui)
    self.hand_ui = hand_ui
    self.positions = positions

    self:createGameObjects()
  end,

  start = function (self)
    local state_coroutine_name = string.random(10)
    self:createCoroutine(function ()
      while true do
        for state, state_fn in ipairs(self.game_states) do
          repeat
            if self.isDestroyed() then
              self:destroyGameObjects()
              return 1
            end

            coroutine.yield(0)

            if self.restart then
              self.restart = false;

              startLuaCoroutine(base, state_coroutine_name)

              return 1
            end
          until self.game_state == state

          state_fn(self)
        end
      end

      return 1
    end, state_coroutine_name)

    if not self.tick then return end

    self:createCoroutine(function ()
      while true do
        if self.isDestroyed() then
          return 1
        end

        coroutine.yield()

        if 1 == self:tick() then
          return 1
        end
      end

      return 1
    end)
  end,

  deal = function (self)

  end,

  cleanup = function (self)
    self.UI.setAttribute('deal_button', 'interactable', false)

    if self.deck then
      for _, card in ipairs(self.dealer_cards) do
        self.deck.putObject(card)
      end

      for _, cards in pairs(self.player_cards) do
        for _, card in ipairs(cards) do
          self.deck.putObject(card)
        end
      end

      for _, card in ipairs(self.community_cards) do
        self.deck.putObject(card)
      end

      wait(0.5)

      self.hands = {}
      self.dealer_cards = {}
      self.player_cards = {}
      self.community_cards = {}

      self.UI.setAttribute('deal_button', 'text', 'Deal')
      self.UI.setAttribute('deal_button', 'interactable', true)

      self.game_state = 0
    end
  end,

  findDeck = function (self, force)
    if self.deck and not force then
      return self.deck
    end

    local found = findObject('Deck', self.positionToWorld(self.positions.deck))
    if found then
      self.deck = found

      return self.deck
    end

    return nil
  end,

  updateBet = function (self, color, steam_id, chips, all_chips)
    local hand = self.hands[color]
    if not hand then return end

    local chip_values = {}
    for index, players in ipairs(chips) do
      chip_values[index] = {}

      for player, player_chips in pairs(players) do
        chip_values[index][player] = calculateChipValues(player_chips)
      end
    end

    hand.bet = {
      color = color,
      steam_id = steam_id,
      chip_values = chip_values,
    }

    if all_chips then
      hand.all_chips = all_chips
    end
  end,

  dealCardsTo = function (self, positions, flip, amount)
    local cards = {}
    local count = 0

    for _, position in ipairs(positions) do
      wait(0.1)

      local card = self.deck.takeObject({
        position = self.positionToWorld(position),
        rotation = flip and self.getRotation() or nil,
      })

      card.interactable = false

      table.insert(cards, card)

      if nil ~= amount then
        count = count + 1

        if count >= amount then
          break
        end
      end
    end

    wait(0.5)

    return cards
  end,

  createCoroutine = function (self, fn, fn_name)
    fn_name = fn_name or string.random(10)

    _G[fn_name] = fn
    startLuaCoroutine(base, fn_name)
  end,

  updateHandOwner = function (self, color, steam_id)
    if not steam_id then
      self.hands[color] = nil

      return nil
    end

    local seatedPlayers = Global.getVar('SEATED_PLAYERS_STEAM') ---@type table<string, SeatedPlayer>

    local seatedPlayer = seatedPlayers[steam_id]
    if not seatedPlayer then return nil end

    self.hands[color] = {
      player = seatedPlayer.color,
      steam_id = seatedPlayer.steam_id,
      position = self.hand_positions[color],
    }

    return self.hands[color]
  end,

  createGameObjects = function (self)
    if not self.positions then return end

    for color, position in pairs(self.positions.players) do
      self.bet_zones[color] = {}
      self.card_zones[color] = {}

      for index, bet_position in ipairs(position.bets) do
        self.bet_zones[color][index] = spawnObject({
          type = 'ScriptingTrigger',
          scale = { 0.5, 4, 0.5 },
          sound = false,
          position = self.positionToWorld({ bet_position[1], 200, bet_position[3] }),
        })

        self.bet_zones[color][index].setVar('type', 'bet')
        self.bet_zones[color][index].setVar('color', color)
        self.bet_zones[color][index].setVar('index', index)
        self.bet_zones[color][index].setTags({ 'chip', 'game-object' })
      end

      for index, card_position in ipairs(position.cards) do
        self.card_zones[color][index] = spawnObject({
          type = 'ScriptingTrigger',
          scale = { 0.5, 4, 0.5 },
          sound = false,
          position = self.positionToWorld({ card_position[1], 200, card_position[3] }),
        })

        self.card_zones[color][index].addTag('game-object')
        self.card_zones[color][index].setVar('type', 'bet')
        self.card_zones[color][index].setVar('color', color)
        self.card_zones[color][index].setVar('index', index)
      end

      local ui_obj
      if self.hand_ui then
        ui_obj = _G.spawnObject({
          type = 'BlockSquare',
          scale = { 1.1, 0.02, 1.1 },
          sound = false,
          rotation = self.getRotation(),
          position = self.positionToWorld(position.ui),
        })

        ui_obj.UI.setXml(self.hand_ui)
        ui_obj.addTag('game-object')
        ui_obj.setLock(true)
        ui_obj.setColorTint({ 0, 0, 0, 0 })
      end

      self.hand_positions[color] = {
        ui = ui_obj and ui_obj.UI or nil,
        color = color,
        loading = ui_obj and true or false,
        ui_object = ui_obj,
      }
    end

    local coroutine_name = string.random(10)
    self:createCoroutine(function ()
      local all_done = true

      repeat
        all_done = true

        wait(0.5)

        for _, hand_position in pairs(self.hand_positions) do
          if hand_position.ui and hand_position.loading then
            if hand_position.ui.loading then
              all_done = false
            else
              hand_position.loading = false

              if self.onHandUILoaded then
                self:onHandUILoaded(hand_position)
              end
            end
          end
        end
      until all_done

      return 1
    end, coroutine_name)
  end,

  destroyGameObjects = function (self)
    for _, object in ipairs(getObjectsWithTag('game-object')) do
      object.destruct()
    end
  end,

  onObjectEnterZone = function (self, zone)
    if zone.getVar('type') ~= 'bet' then return end

    local zone_color = zone.getVar('color')
    local chips, all_chips = findChips(self.bet_zones[zone_color])

    if self.hands[zone_color] then
      self:updateBet(zone_color, self.hands[zone_color].steam_id, chips, all_chips)
      return
    end

    for _, chip in pairs(chips) do
      local steam_id = next(chip)
      if steam_id then
        self:updateHandOwner(zone_color, steam_id)
        self:updateBet(zone_color, steam_id, chips, all_chips)
        break
      end
    end
  end,

  onObjectLeaveZone = function (self, zone)
    if zone.getVar('type') ~= 'bet' then return end

    local zone_color = zone.getVar('color')
    if not self.hands[zone_color] then return end

    local chips, all_chips = findChips(self.bet_zones[zone_color])

    local new_steam_id = nil
    local current_steam_id = self.hands[zone_color].steam_id

    for _, chip in pairs(chips) do
      local steam_id = next(chip)
      if steam_id == current_steam_id then
        self:updateBet(zone_color, current_steam_id, chips, all_chips)
        return
      end

      if not new_steam_id then
        new_steam_id = steam_id
      end
    end

    self:updateHandOwner(zone_color, new_steam_id)
    self:updateBet(zone_color, new_steam_id, chips, all_chips)
  end,
}
