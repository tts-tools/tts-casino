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


---@class PayoutParams
---@field position Vector
---@field player_color string


---@class GameBet
---@field color string The color of the hand where the bet was placed
---@field steam_id string The steam id of the player who placed the bet
---@field chip_values table<string, table<integer, integer>>[] The values of the chips placed in the bet - correlates to `TablePlayerPositions.bets`


---@class GameHandPosition
---@field ui? UI
---@field color string
---@field loading? boolean The loading state of the hand's ui
---@field ui_object? Object


---@class GameHand
---@field bet? GameBet
---@field player string
---@field position GameHandPosition
---@field steam_id string
---@field all_chips? Object[][]


---@class PlayingGameHand
---@field hand GameHand
---@field cards Object[]
---@field status string


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
---@field hands_playing table<string, PlayingGameHand>
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
---@field foldHand fun(self: self, playing: PlayingGameHand): nil
---@field updateBet fun(self: self, color: string, steam_id: string, chips: table<string, Object[]>[], all_chips: Object[]): nil
---@field dealCardsTo fun(self: self, positions: VectorLike[], flip?: boolean, amount?: number): Object[]
---@field createCoroutine fun(self: self, fn: (fun(): nil), fn_name?: string): nil
---@field updateHandOwner fun(self: self, color: string, steam_id?: string): GameHand?
---@field createGameObjects fun(self: self): nil
---@field destroyGameObjects fun(self: self): nil
---
---[[ Event Handlers ]]
---@field onPayout fun(self: self, params: PayoutParams): nil
---@field onFoldHand? fun(self: self, playing: PlayingGameHand): nil
---@field onHandUILoaded? fun(self: self, position: GameHandPosition): nil
---@field onObjectEnterZone fun(self: self, zone: Object, object: Object): nil
---@field onObjectLeaveZone fun(self: self, zone: Object, object: Object): nil
