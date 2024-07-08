---@diagnostic disable
require('chips')
require('game.game')
require('utils.misc')
require('game.three-card.text')

local HAND_UI = require('game.three-card.ui.hand')
local THREE_CARD_POSITIONS = require('game.three-card.positions')

---@type ThreeCard
local ThreeCard = {
  dealt_cards = {},
  valid_hands = {},
  dealer_cards = {},

  ---@param self ThreeCard
  constructor = function(self)
    self:clearGameObjects()
    self:createObjects(THREE_CARD_POSITIONS.players, HAND_UI)

    self:startGame()
  end,

  startGame = function(self)
    self.game_states = {
      self.dealCards,
      self.flipDealer,
      self.cleanup,
    }

    self.__super.startGame(self)

    self:createAuxLoop()
  end,


  dealCards = function(self)
    if not self:findDeck() then return nil end

    self.UI.setAttribute('deal_button', 'interactable', false)
    self.deck.randomize()


    for color in pairs(THREE_CARD_POSITIONS.players) do
      local valid, chips, player = self:isBetValid(color)

      if valid and chips and player then
        for _, chip in ipairs(chips[1]) do
          chip.locked = true
        end

        for _, chip in ipairs(chips[3]) do
          chip.locked = true
        end
      end
    end

    wait(0.5)

    for color, position in pairs(THREE_CARD_POSITIONS.players) do
      local valid, _, player = self:isBetValid(color)

      if valid and player then
        self.valid_hands[color] = {
          cards = self:dealCardsTo(position.cards, true),
          player = player,
          status = 'playing'
        }
      end
    end

    self.dealer_cards = self:dealCardsTo(THREE_CARD_POSITIONS.dealer.cards)

    self.UI.setAttribute('deal_button', 'text', 'Flip')
    self.UI.setAttribute('deal_button', 'interactable', true)
  end,

  flipDealer = function (self)
    self.UI.setAttribute('deal_button', 'interactable', false)

    for _, card in ipairs(self.dealer_cards) do
      card.flip()
    end

    for color, _ in pairs(self.valid_hands) do
      self:hideButton('center-' .. color)
    end

    self.UI.setAttribute('deal_button', 'text', 'Reset')
    self.UI.setAttribute('deal_button', 'interactable', true)
  end,

  cleanup = function(self)
    self.UI.setAttribute('deal_button', 'interactable', false)

    for _, card in ipairs(self.dealt_cards) do
      self.deck.putObject(card)
    end

    self.deck.randomize()

    self.state = 0
    self.dealt_cards = {}
    self.valid_hands = {}

    self.UI.setAttribute('deal_button', 'text', 'Deal')
    self.UI.setAttribute('deal_button', 'interactable', true)
  end,

  createAuxLoop = function(self)
    self:createCoroutine(function()
      while true do
        if self.isDestroyed() then
          return 1
        end

        wait(0.5)

        if self.state == 0 then
          self:updatePlayStatus()
        elseif self.state == 1 then
          self:updateBetStatus()
        end
      end

      return 1
    end)
  end,

  updateBetStatus = function(self)
    for color, hand in pairs(self.valid_hands) do
      -- local text = self.player_text[color]
      -- if not text then return end

      local chips = findChips(self.bet_zones, color)
      local has_pair = #chips[1] > 0
      local has_ante = #chips[3] > 0
      local has_play = #chips[4] > 0

      local hand_ui = self.hand_owners[color].hand_ui.UI

      if 'played' == hand.status 'folding' == hand.status then
        -- noop
      elseif (has_pair and not has_ante) or (has_ante and has_play) then
        if 'playing' ~= hand.status then
          hand.status = 'playing'

          if not hand_ui.loading then
            hand_ui.setValue('player-text', 'Playing')
            hand_ui.setAttribute('btn-left', 'active', false)
            hand_ui.setAttribute('btn-right', 'active', false)
          end
        end
      elseif 'thinking' ~= hand.status then
        hand.status = 'thinking'

        if not hand_ui.loading then
          hand_ui.setValue('player-text', 'Thinking')

          hand_ui.setAttribute('btn-left', 'text', 'Play')
          hand_ui.setAttribute('btn-left', 'visibility', hand.player.color)
          hand_ui.setAttribute('btn-left', 'active', true)

          hand_ui.setAttribute('btn-right', 'text', 'Fold')
          hand_ui.setAttribute('btn-right', 'visibility', hand.player.color)
          hand_ui.setAttribute('btn-right', 'active', true)
        end
      end
    end
  end,

  updatePlayStatus = function(self)
    for color in pairs(THREE_CARD_POSITIONS.players) do
      local hand = self.hand_owners[color]
      if not hand.hand_ui.UI.loading then
        local valid = self:isBetValid(color)

        hand.hand_ui.UI.setValue('player-text', valid and 'Playing' or '')
        hand.hand_ui.UI.setAttribute('player-text', 'active', valid)
      end
    end
  end,

  findDeck = function (self, force)
    if self.deck and not force then
      return self.deck
    end

    local found = findObject('Deck', self.positionToWorld(THREE_CARD_POSITIONS.deck))
    if found then
      self.deck = found

      return self.deck
    end

    return nil
  end,

  isBetValid = function(self, color)
    local player = self.hand_owners[color].player
    if not player then return false end

    local chips = findChips(self.bet_zones, color)
    return chips and #chips[1] > 0 or #chips[3] > 0, chips, player
  end,

  dealCardsTo = function (self, positions, flip)
    local cards = {}

    for _, position in ipairs(positions) do
      wait(0.1)

      local card = self.deck.takeObject({
        position = self.positionToWorld(position),
        rotation = flip and self.getRotation() or nil,
      })

      card.interactable = false

      table.insert(cards, card)
      table.insert(self.dealt_cards, card)
    end

    wait(0.5)

    return cards
  end,

  updateHandOwner = function(self, zone_color, object)
    local seatedPlayers = Global.getVar('SEATED_PLAYERS') ---@type table<string, PlayerInstance>

    for color, player in pairs(seatedPlayers) do
      if object.hasTag('steam-' .. player.steam_id) then
        self.hand_owners[zone_color].player = player
        --self.hand_owners[zone_color].indicator.setColorTint(color)
        return
      end
    end
  end,

  handUILoaded = function (self, color, hand_ui)
    hand_ui.UI.setAttribute('btn-left', 'onClick', self.__object.getGUID() .. '/' .. 'leftButtonClick(' .. color .. ')')
    hand_ui.UI.setAttribute('btn-right', 'onClick', self.__object.getGUID() .. '/' .. 'rightButtonClick(' .. color .. ')')
    hand_ui.UI.setAttribute('btn-center', 'onClick', self.__object.getGUID() .. '/' .. 'centerButtonClick(' .. color .. ')')
  end,

  leftButtonClick = function(self, player_color, color)
    local hand_owner = self.hand_owners[color]
    if not hand_owner.player or hand_owner.player.color ~= player_color then return end

    if self.state == 1 and self.valid_hands[player_color] then
      local hand = self.valid_hands[color]
      if 'playing' == hand.status or 'played' == hand.status then return end

      hand.status = 'played'

      if not hand_owner.hand_ui.UI.loading then
        hand_owner.hand_ui.UI.setValue('player-text', 'Playing')
        hand_owner.hand_ui.UI.setAttribute('btn-left', 'active', false)
        hand_owner.hand_ui.UI.setAttribute('btn-right', 'active', false)
      end
    end
  end,

  rightButtonClick = function(self, player_color, color)
    local hand_owner = self.hand_owners[color]
    if not hand_owner.player or hand_owner.player.color ~= player_color then return end

    if self.state == 1 and self.valid_hands[player_color] then
      local hand = self.valid_hands[color]
      if 'folding' == hand.status then return end

      hand.status = 'folding'

      if not hand_owner.hand_ui.UI.loading then
        hand_owner.hand_ui.UI.setValue('player-text', 'Folding')
        hand_owner.hand_ui.UI.setAttribute('btn-left', 'active', false)
        hand_owner.hand_ui.UI.setAttribute('btn-right', 'active', false)
      end

      for _, card in ipairs(hand.cards) do
        local rotation = self.getRotation():copy():add({ x = 0, y = 15, z = 0 })
        card.setRotationSmooth(rotation)
      end

      local chips = findChips(self.bet_zones, color, true)
      for bet_type, bet in ipairs(chips) do
        for _, chip in ipairs(bet) do
          if bet_type == 2 or bet_type == 3 then
            destroyObject(chip)
          else
            chip.locked = true
          end
        end
      end
    end
  end,

  centerButtonClick = function(self, player_color, color)
    print(string.format('Center button clicked by %s for %s', player_color, color))
  end,

  onObjectEnterZone = function(self, zone, object)
    if zone.getVar('type') ~= 'bet' then return end

    local zone_color = zone.getVar('color')
    if self.hand_owners[zone_color].player then return end

    local chip_count = 0
    for _, chips in pairs(findChips(self.bet_zones, zone_color)) do
      chip_count = chip_count + #chips
    end

    if chip_count > 1 then return end

    self:updateHandOwner(zone_color, object)
  end,

  onObjectLeaveZone = function(self, zone, object)
    if zone.getVar('type') ~= 'bet' then return end

    local zone_color = zone.getVar('color')
    if not self.hand_owners[zone_color].player then return end

    local chip_count = 0
    for _, chips in pairs(findChips(self.bet_zones, zone_color)) do
      chip_count = chip_count + #chips
    end

    if chip_count ~= 0 then return end

    self.hand_owners[zone_color].player = nil
    --self.hand_owners[zone_color].indicator.setColorTint({ 0, 0, 0, 0 })
  end
}

---@diagnostic disable-next-line: param-type-mismatch
class 'ThreeCard' : extends 'Game' (ThreeCard)

---@type ThreeCard
local game

function onLoad()
  game = new 'ThreeCard' ()
end

function dealClick()
  if game then
    game.state = game.state + 1
  end
end

---@param zone Object
---@param object Object
function onObjectEnterZone(zone, object)
  if game then
    game:onObjectEnterZone(zone, object)
  end
end

---@param zone Object
---@param object Object
function onObjectLeaveZone(zone, object)
  if game then
    game:onObjectLeaveZone(zone, object)
  end
end

---@param player PlayerInstance
---@param color string
function leftButtonClick(player, color)
  if game then
    game:leftButtonClick(player.color, color)
  end
end

---@param player PlayerInstance
---@param color string
function rightButtonClick(player, color)
  if game then
    game:rightButtonClick(player.color, color)
  end
end

---@param player PlayerInstance
---@param color string
function centerButtonClick(player, color)
  if game then
    game:centerButtonClick(player.color, color)
  end
end
