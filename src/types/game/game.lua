---@meta

---@class TableDealerPositions
---@field cards? VectorLike[]
---@field community_cards? VectorLike[]


---@class TablePlayerPositions
---@field ui VectorLike
---@field bets VectorLike[]
---@field cards VectorLike[]


---@class TablePositions
---@field deck VectorLike
---@field dealer TableDealerPositions
---@field players table<string, TablePlayerPositions>


---@class ColorDetail
---@field scripting_zone string


---@alias ColorDetails table<string, ColorDetail>


---@class TableHandOwner
---@field player? PlayerInstance
---@field hand_ui? Object
---@field loading? boolean


---@class Game : Class, Object
---
---@field __super? Class
---
---@field deck? Object
---@field state integer
---@field buttons table<string, integer>
---@field restart boolean
---@field bet_zones table<string, Object[]>
---@field card_zones table<string, Object[]>
---@field hand_owners table<string, TableHandOwner>
---@field game_states? (fun(self: self): nil)[]
---@field button_count? integer
---
---@field startGame fun(self: self): nil
---@field editButton fun(self: self, name: string, parameters: Button.Parameters.Edit): boolean
---@field hideButton fun(self: self, name: string, label?: string): boolean
---@field showButton fun(self: self, name: string, label?: string): boolean
---@field createButton fun(self: self, name: string, parameters: Button.Parameters.Create, callback: (fun(self: self, player_color: string, alt: boolean, ...): nil), ...): number
---@field createObjects fun(self: self, positions: table<string, TablePlayerPositions>, hand_ui: string): nil
---@field createCoroutine fun(self: self, fn: (fun(): nil), fn_name?: string): nil
---@field clearGameObjects fun(self: self): nil
---
---@field handUILoaded? fun(self: self, color: string, hand_ui: Object): nil
