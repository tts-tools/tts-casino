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


---@class GameBet
---@field color string The color of the hand where the bet was placed
---@field steam_id string The steam id of the player who placed the bet
---@field chip_values number[] The values of the chips placed in the bet - correlates to `TablePlayerPositions.bets`


---@class GameHandPosition
---@field ui? UI
---@field color string
---@field loading? boolean The loading state of the hand's ui
---@field ui_object? Object


---@class GameHand
---@field bet GameBet
---@field player PlayerInstance
---@field position GameHandPosition


---@class Game : Class, Object
---
---@field __super? Class
---
---@field hand_ui? string
---@field positions? TablePositions
---
---@field bet_zones table<string, Object[]>
---@field card_zones table<string, Object[]>
---@field game_states (fun(self: self): nil)[]
---@field previous_bets table<string, GameBet[]>
---@field hand_positions table<string, GameHandPosition>
---
---@field deck? Object
---@field hands table<string, GameHand>
---@field restart boolean
---@field game_state integer
---@field dealer_cards Object[]
---@field player_cards table<string, Object[]>
---@field community_cards Object[]
---
---@field constructor fun(self: self, positions: TablePositions, hand_ui?: string): nil
---
---[[ Game Loop ]]
---@field start fun(self: self): nil
---@field tick? fun(self: self): nil
---
---[[ Game State Functions ]]
---@field deal fun(self: self): nil
---@field cleanup fun(self: self): nil
---
---[[ Game Utility Functions ]]
---@field findDeck fun(self: self, force?: boolean): Object?
---@field dealCardsTo fun(self: self, positions: VectorLike[], flip?: boolean, amount?: number): Object[]
---@field createCoroutine fun(self: self, fn: (fun(): nil), fn_name?: string): nil
---@field createGameObjects fun(self: self): nil
---@field destroyGameObjects fun(self: self): nil
---
---[[ Event Handlers ]]
---@field onHandUILoaded? fun(self: self, position: GameHandPosition): nil
