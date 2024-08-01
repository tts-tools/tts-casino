require('game.game')
require('utils.misc')
require('utils.chips')

local HAND_UI = require('game.mississippi-stud.ui.hand')
local MISSISSIPPI_STUD_POSITIONS = require('game.mississippi-stud.positions')

---@enum MississippiStudGameState
local GameState = {
  NONE = 0,
  DEAL = 1,
  THIRD_STREET = 2,
  FOURTH_STREET = 3,
  FIFTH_STREET = 4,
  SIXTH_CARD = 5,
  CLEANUP = 6,
}

---@type MississippiStud
local MississippiStud = {
  game_state = GameState.NONE,

  constructor = function (self)
    self.__super.constructor(self, MISSISSIPPI_STUD_POSITIONS, HAND_UI)

    self.game_states = {
      self.deal,
      self.thirdStreet,
      self.fourthStreet,
      self.fifthStreet,
      self.sixthCard,
      self.cleanup,
    }

    self:start()
  end,

  tick = function (self)
    if GameState.NONE == self.game_state then
      self:updatePlayStatus()
    elseif GameState.SIXTH_CARD ~= self.game_state and GameState.CLEANUP ~= self.game_state then
      self:updateBetStatus()
    end
  end,

  updatePlayStatus = function (self)
    for color, hand in pairs(self.hand_positions) do
      if hand.ui and not hand.ui.loading then
        local valid_bet = self.hands[color] and self:isBetValid(self.hands[color])

        hand.ui.setValue('player-text', valid_bet and 'Playing' or '')
        hand.ui.setAttribute('player-text', 'active', valid_bet)
      end
    end
  end,

  updateBetStatus = function (self)
    for _, playing in pairs(self.hands_playing) do
      local current_bet = nil
      if GameState.DEAL == self.game_state then
        current_bet = next(playing.hand.bet.chip_counts[4])
      elseif GameState.THIRD_STREET == self.game_state then
        current_bet = next(playing.hand.bet.chip_counts[5])
      elseif GameState.FOURTH_STREET == self.game_state then
        current_bet = next(playing.hand.bet.chip_counts[6])
      end

      if 'folding' == playing.status then
        -- noop
      elseif current_bet then
        if 'playing' ~= playing.status then
          playing.status = 'playing'

          local hand_ui = playing.hand.position.ui
          if hand_ui and not hand_ui.loading then
            hand_ui.setValue('player-text', 'Playing')
            hand_ui.setAttribute('btn-left', 'active', false)
            hand_ui.setAttribute('btn-right', 'active', false)
          end
        end
      elseif 'thinking' ~= playing.status then
        playing.status = 'thinking'

        local hand_ui = playing.hand.position.ui
        if hand_ui and not hand_ui.loading then
          hand_ui.setValue('player-text', 'Thinking')

          hand_ui.setAttribute('btn-left', 'text', 'Play')
          hand_ui.setAttribute('btn-left', 'visibility', playing.hand.player)
          hand_ui.setAttribute('btn-left', 'active', true)

          hand_ui.setAttribute('btn-right', 'text', 'Fold')
          hand_ui.setAttribute('btn-right', 'visibility', playing.hand.player)
          hand_ui.setAttribute('btn-right', 'active', true)
        end
      end
    end
  end,

  deal = function (self)
    self.__super.deal(self)

    if not self:findDeck() then return nil end

    self.UI.setAttribute('deal_button', 'interactable', false)
    self.deck.randomize()

    for _, hand in pairs(self.hands) do
      if hand.all_chips and self:isBetValid(hand) then
        for _, bet in ipairs(hand.all_chips) do
          for _, chip in ipairs(bet) do
            chip.locked = true
          end
        end
      end
    end

    wait(0.5)

    for color in pairs(self.positions.players) do
      local hand = self.hands[color]
      if hand and hand.all_chips and self:isBetValid(hand) then
        local cards = self:dealCardsTo(self.positions.players[color].cards, true)
        self.player_cards[color] = cards
        self.hands_playing[color] = {
          hand = hand,
          cards = cards,
          status = 'playing',
        }
      end
    end

    self.UI.setAttribute('deal_button', 'text', 'Flop')
    self.UI.setAttribute('deal_button', 'interactable', true)
  end,

  thirdStreet = function (self)
    -- TODO
  end,

  fourthStreet = function (self)
    -- TODO
  end,

  fifthStreet = function (self)
    -- TODO
  end,

  sixthCard = function (self)
    -- TODO
  end,

  cleanup = function (self)
    self.__super.cleanup(self)

    -- TODO
  end,

  foldHand = function (self, playing)
    -- TODO
  end,

  isBetValid = function (self, hand)
    return next(hand.bet.chip_counts[3]) ~= nil
  end,

  updateHandOwner = function (self, color, steam_id)
    local hand = self.__super.updateHandOwner(self, color, steam_id)

    local ui = self.hand_positions[color].ui
    if not ui or ui.loading then return end

    if hand then
      ui.setAttribute('indicator', 'color', hand.player)
      ui.setAttribute('indicator', 'active', true)
      ui.setAttribute('indicator', 'player', hand.player)
      ui.setAttribute('indicator', 'onClick', self.__object.getGUID() .. '/' .. 'indicatorButtonClick(' .. color .. ')')
    end
  end,

  onFoldHand = function (self, playing)
    -- TODO
  end,

  onHandUILoaded = function (self, position)
    position.ui.setAttribute('btn-left', 'onClick', self.__object.getGUID() .. '/' .. 'leftButtonClick(' .. position.color .. ')')
    position.ui.setAttribute('btn-right', 'onClick', self.__object.getGUID() .. '/' .. 'rightButtonClick(' .. position.color .. ')')
    position.ui.setAttribute('btn-center', 'onClick', self.__object.getGUID() .. '/' .. 'centerButtonClick(' .. position.color .. ')')
  end,

  onLeftButtonClick = function (self, player, color)
    -- TODO
  end,

  onRightButtonClick = function (self, player, color)
    local playing = self.hands_playing[color]
    if not playing or player.color ~= playing.hand.player then return end

    self:foldHand(playing)
  end,

  onCenterButtonClick = function (self, player, color)
    -- TODO
  end,

  onIndicatorButtonClick = function (self, player, color)
    if self.hands[color] then return end

    local position = self.hand_positions[color]
    if position.ui.loading or (not player.admin and position.ui.getAttribute('indicator', 'player') ~= player.color) then return end

    position.ui.setAttribute('indicator', 'active', false)
    position.ui.setAttribute('indicator', 'player', nil)
    position.ui.setAttribute('indicator', 'onClick', nil)
  end
}

---@diagnostic disable-next-line: param-type-mismatch
class 'MississippiStud' : extends 'Game' (MississippiStud)

---@type MississippiStud
local game

function onLoad()
  game = new 'MississippiStud' ()
end

function dealClick()
  if game then
    game.game_state = game.game_state + 1
  end
end

---@param player PlayerInstance
---@param color string
function leftButtonClick(player, color)
  if game then
    game:onLeftButtonClick(player, color)
  end
end

---@param player PlayerInstance
---@param color string
function rightButtonClick(player, color)
  if game then
    game:onRightButtonClick(player, color)
  end
end

---@param player PlayerInstance
---@param color string
function centerButtonClick(player, color)
  if game then
    game:onCenterButtonClick(player, color)
  end
end

---@param player PlayerInstance
---@param color string
function indicatorButtonClick(player, color)
  if game then
    game:onIndicatorButtonClick(player, color)
  end
end
