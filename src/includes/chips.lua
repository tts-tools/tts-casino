---@param bet_zones table<string, Object[]>
---@param color string
---@param only_locked? boolean
---@return Object[][]
function findChips(bet_zones, color, only_locked)
  only_locked = only_locked or false

  local chips = {} ---@type Object[][]

  for index, zone in ipairs(bet_zones[color]) do
    chips[index] = {}

    for _, object in ipairs(zone.getObjects()) do
      if object.type == 'Chip' then
        if not only_locked or object.locked then
          table.insert(chips[index], object)
        end
      end
    end
  end

  return chips
end

---@param container Object
---@param object Object
function onObjectLeaveContainer(container, object)
  if container.hasTag('chip') then
    object.addTag('chip')
  end
end
