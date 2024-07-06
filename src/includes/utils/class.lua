--[[
  Copyright (c) 2012-2022 Scott Chacon and others

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- https://github.com/lodsdev/lua-class

local classes = {} ---@type table<string, Class>

---@generic First : Class
---@generic Second : Class
---@param first_table First
---@param second_table Second | Object
---@return First | Second
local function tableCopy(first_table, second_table)
  local new_table = {}

  for index, value in pairs(first_table) do
    if not new_table[index] then
      new_table[index] = value
    end
  end

  if second_table then
    new_table.__super = second_table
    new_table.__super_name = second_table.type
  end

  local object = new_table.__object

  setmetatable(new_table, {
    __index = function (_, key)
      if second_table and second_table[key] ~= nil then
        return second_table[key]
      end

      if not object then return nil end

      local status, result = pcall(function() return object[key] end)
      if status then return result end

      return nil
    end
  })

  return new_table
end

---@param class_name string
---@param class_structure Class
---@param super_class Class
---@return Class
local function createClass(class_name, class_structure, super_class)
  if classes[class_name] then
    error('Class ' .. class_name .. ' already exists.')
  end

  local new_class = class_structure
  new_class.__name = class_name

  if super_class then
    new_class.__super = super_class
    new_class.__super_name = super_class.__name
  end

  if self then
    new_class.__object = self
    new_class.__object_type = self.type
  end

  classes[class_name] = new_class

  return new_class
end

--@overload fun(class_name: `C`): { ['extends']: fun(self: C, super_class: string): fun(class_structure: C): C }

---@generic C : Class
---@param class_name `C`
---@return fun(class_structure: C): C]
---@overload fun(class_name: `C`): { ['extends']: fun(self: C, super_class: string): fun(class_structure: C): C }
function class(class_name)
  local new_class = {} ---@type Class

  ---@type table
  local modifiers = {
    ---@param super_class_name string
    extends = function(_, super_class_name)
      return function(sub_class)
        local super_class = classes[super_class_name]

        return createClass(class_name, sub_class, super_class)
      end
    end
  }

  setmetatable(new_class, {
    __index = function(_, key)
      if modifiers[key] then
        return modifiers[key]
      end

      if classes[class_name] then
        return classes[class_name][key]
      end

      error('Class ' .. class_name .. ' does not exist.')
    end,

    __call = function(_, class_structure, super_class)
      if classes[class_name] then
        error('Class ' .. class_name .. ' already exists.')
      end

      return createClass(class_name, class_structure, super_class)
    end
  })

  return new_class
end

---@generic C : Class
---@param class_name `C`
---@return fun(...): C
function new(class_name)
  return function(...)
    local class = classes[class_name]
    if not class then
      error('Class ' .. class_name .. ' does not exist.')
    end

    local super = class.__super
    local new_instance = tableCopy(class, super)

    if new_instance.constructor then
      new_instance.constructor(new_instance, ...)
    end

    return new_instance
  end
end
