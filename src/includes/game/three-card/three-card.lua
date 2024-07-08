require('chips')
require('game.game')
require('utils.misc')

local HAND_UI = require('game.three-card.ui.hand')
local THREE_CARD_POSITIONS = require('game.three-card.positions')

---@enum ThreeCardGameState
local GameState = {
  NONE = 0,
  DEAL = 1,
  FLIP_DEALER = 2,
  CLEANUP = 3,
}

---@type ThreeCard
local ThreeCard = {
  game_state = GameState.NONE,

  constructor = function (self)
    self.__super.constructor(self, THREE_CARD_POSITIONS, HAND_UI)

    self.game_states = {
      self.deal,
      self.flipDealer,
      self.cleanup,
    }

    self:start()
  end,

  tick = function (self)
    -- TODO
  end,

  deal = function (self)
    self.__super.deal(self)

    if not self:findDeck() then return nil end

    self.UI.setAttribute('deal_button', 'interactable', false)
    self.deck.randomize()

    -- TODO: validate bets and lock

    wait(0.5)

    -- TODO: deal players

    self.dealer_cards = self:dealCardsTo(self.positions.dealer.cards)

    self.UI.setAttribute('deal_button', 'text', 'Flip')
    self.UI.setAttribute('deal_button', 'interactable', true)
  end,

  flipDealer = function (self)
    self.UI.setAttribute('deal_button', 'interactable', false)

    for _, card in ipairs(self.dealer_cards) do
      card.flip()
    end

    -- TODO: toggle hand ui

    wait(0.5)

    self.UI.setAttribute('deal_button', 'text', 'Reset')
    self.UI.setAttribute('deal_button', 'interactable', true)
  end,

  cleanup = function (self)
    self.__super.cleanup(self)

    -- TODO
  end,

  onHandUILoaded = function (self, position)
    -- TODO
  end,

  onObjectEnterZone = function (self, zone, object)
    -- TODO
  end,

  onObjectLeaveZone = function (self, zone, object)
    -- TODO
  end,

  onLeftButtonClick = function (self, player_color, color)
    -- TODO
  end,

  onRightButtonClick = function (self, player_color, color)
    -- TODO
  end,

  onCenterButtonClick = function (self, player_color, color)
    -- TODO
  end,
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
    game.game_state = game.game_state + 1
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
    game:onLeftButtonClick(player.color, color)
  end
end

---@param player PlayerInstance
---@param color string
function rightButtonClick(player, color)
  if game then
    game:onRightButtonClick(player.color, color)
  end
end

---@param player PlayerInstance
---@param color string
function centerButtonClick(player, color)
  if game then
    game:onCenterButtonClick(player.color, color)
  end
end
