require('utils.class')
require('utils.strings')

local base = self

class 'Game' {
  state = 0,
  buttons = {},
  restart = false,
  bet_zones = {},
  card_zones = {},
  hand_owners = {},

  startGame = function(self)
    local coroutine_name = string.random(10)

    self:createCoroutine(function()
      while true do
        for state, state_fn in ipairs(self.game_states) do
          repeat
            if self.isDestroyed() then
              self:clearGameObjects()
              return 1
            end

            coroutine.yield(0)

            if self.restart then
              self.restart = false;

              startLuaCoroutine(base, coroutine_name)

              return 1
            end
          until self.state == state

          state_fn(self)
        end
      end

      return 1
    end, coroutine_name)
  end,

  editButton = function(self, name, parameters)
    local button_index = self.buttons[name]
    if not button_index then return false end

    local edit_parameters = parameters
    parameters.index = button_index

    return self.__object.editButton(edit_parameters)
  end,

  hideButton = function(self, name, label)
    local button_index = self.buttons[name]
    if not button_index then return false end

    return self.__object.editButton({
      index = button_index,
      scale = { 0, 0, 0 },
    })
  end,

  showButton = function(self, name, label)
    local button_index = self.buttons[name]
    if not button_index then return false end

    local parameters = --[[@type Button.Parameters.Edit]] {
      index = button_index,
      scale = { 1, 1, 1 },
    }

    if label then
      parameters.label = label
    end

    return self.__object.editButton(parameters)
  end,

  createButton = function(self, name, parameters, callback, ...)
    parameters.click_function = string.random(10)
    parameters.function_owner = self.__object

    local args = pack(...)

    _G[parameters.click_function] = function(_, player_color, alt)
      callback(self, player_color, alt, unpack(args))
    end

    self.__object.createButton(parameters)

    self.button_count = (self.button_count or -1) + 1
    self.buttons[name] = self.button_count

    return self.button_count
  end,

  createObjects = function(self, positions, hand_ui)
    for color, position in pairs(positions) do
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

      local ui_obj = spawnObject({
        type = 'BlockSquare',
        scale = { 1.1, 0.02, 1.1 },
        sound = false,
        rotation = self.getRotation(),
        position = self.positionToWorld(position.ui),
      })

      ui_obj.UI.setXml(hand_ui)
      --ui_obj.UI.setXmlTable(hand_ui)

      ui_obj.addTag('game-object')
      ui_obj.setLock(true)
      ui_obj.setColorTint({ 0, 0, 0, 0 })

      self.hand_owners[color] = {
        hand_ui = ui_obj,
        loading = true,
      }
    end

    local coroutine_name = string.random(10)
    self:createCoroutine(function ()
      local all_done = true

      repeat
        all_done = true

        wait(0.5)

        for color, hand in pairs(self.hand_owners) do
          if hand.loading then
            if hand.hand_ui.UI.loading then
              all_done = false
            else
              hand.loading = false
              self:handUILoaded(color, hand.hand_ui)
            end
          end
        end
      until all_done

      return 1
    end, coroutine_name)
  end,

  createCoroutine = function(_, fn, fn_name)
    fn_name = fn_name or string.random(10)

    _G[fn_name] = fn
    startLuaCoroutine(self, fn_name)
  end,

  clearGameObjects = function()
    for _, object in ipairs(getObjectsWithTag('game-object')) do
      object.destruct()
    end
  end
}
