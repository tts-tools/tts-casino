---@meta

---@class ColorDetail
---@field board? string
---@field exchange_zone? string
---@field scripting_zone string

---@class ColorDetailLoaded
---@field board? Object
---@field exchange_zone? Object
---@field scripting_zone? Object

---@alias ColorDetails table<string, ColorDetail>
---@alias ColorDetailsLoaded table<string, ColorDetailLoaded>

---@class SeatedPlayer
---@field color string
---@field steam_id string
---@field steam_name string
