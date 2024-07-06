math.randomseed(os.time())

local charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'

---@param length integer
---@return string
function string.random(length)
  if length == 0 then return '' end

  local rand = math.random(1, #charset)
  local rand_char = charset:sub(rand, rand)

  return string.random(length - 1) .. rand_char
end
