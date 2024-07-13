require('globals')
require('utils.misc')

---@type Object
local save_bag

---@type Object
local starter_bag

---@param force? boolean
---@return Object?
function findSaveBag(force)
  if save_bag and not force then
    return save_bag
  end

  local found = findObject('Bag', SAVE_BAG_POSITION, true)
  if found then
    save_bag = found
    return found
  end

  return nil
end

---@param force? boolean
---@return Object?
function findStarterBag(force)
  if starter_bag and not force then
    return starter_bag
  end

  local found = findObject('Bag', STARTER_BAG_POSITION, true)
  if found then
    starter_bag = found
    return found
  end

  return nil
end

---@param player SeatedPlayer
---@param spawn_loc Vector
function loadSave(player, spawn_loc)
  local save = findSave(player, spawn_loc)
  if save then return end

  createSave(player, spawn_loc)
end

---@param player SeatedPlayer
---@param spawn_loc Vector
---@return Object?
function findSave(player, spawn_loc)
  if not findSaveBag() then return nil end -- TODO: Log not found

  local saves = save_bag.getObjects()
  if not saves then return nil end

  for _, save in ipairs(saves) do
    for _, tag in ipairs(save.tags) do
      if tag == ('steam:' .. player.steam_id) then
        return save_bag.takeObject({
          guid = save.guid,
          smooth = false,
          position = spawn_loc
        })
      end
    end
  end

  return nil
end

---@param player SeatedPlayer
---@param spawn_loc Vector
function createSave(player, spawn_loc)
  if not findStarterBag() then return end

  local save = starter_bag.clone({ position = spawn_loc })

  save.addTag('steam:' .. player.steam_id)
  save.setName(player.steam_name .. "'s Save")

  for _, simple_object in ipairs(save.getObjects()) do
    local object = save.takeObject({
      guid = simple_object.guid,
      smooth = false
    })

    object.addTag('steam:' .. player.steam_id)
    save.putObject(object)
  end

  save.setLock(false)
end

---@param player SeatedPlayer
---@return Object?
function findExistingSave(player)
  local objects = getObjectsWithAllTags({ 'save', 'steam:' .. player.steam_id })
  if not objects then return nil end

  for _, object in ipairs(objects) do
    if object.type == 'Bag' and object.hasTag('save') then
      return object
    end
  end

  return nil
end

---@param player SeatedPlayer
function savePlayer(player)
  local save = findExistingSave(player)
  if not save then return end -- TODO: Log not found

  local objects = getObjectsWithTag('steam:' .. player.steam_id)
  for _, object in ipairs(objects) do
    if object.guid ~= save.guid and not object.locked then
      save.putObject(object)
    end
  end

  if not findSaveBag() then return end
  save_bag.putObject(save)
end
