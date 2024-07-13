---@param time  integer
function wait(time)
  local start_time = Time.time

  repeat
    coroutine.yield(0)
  until Time.time - start_time > time
end

---@param type string
---@param position VectorLike
---@param debug? boolean
function findObject(type, position, debug)
  for _, hit in ipairs(Physics.cast({
    type = 1,
    debug = debug or false,
    origin = position,
    direction = { 0, 1, 0 },
    max_distance = 5,
  })) do
    if hit.hit_object.type == type then
      return hit.hit_object
    end
  end

  return nil
end

---@param object Object
---@return string?
function findSteamId(object)
  for _, tag in ipairs(object.getTags()) do
    local steam_id = tag:match('^steam:([0-9]+)$')
    if steam_id then return steam_id end
  end

  return nil
end
