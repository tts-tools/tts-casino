---@meta

---@enum (key) HandStatus
local hand_status = {
  thinking = 1,
  playing = 2,
  folding = 3
}


---@class ValidHand
---@field cards Object[]
---@field status HandStatus
---@field player PlayerInstance


---@class ThreeCard : Game
---
---@field __super? Game
---
---@field dealt_cards table<string, Object[]>
---@field valid_hands table<string, ValidHand>
---@field player_text? table<string, Object>
---@field dealer_cards table<string, Object[]>
---
---@field startGame fun(self: self): nil
---@field dealCards fun(self: self): nil
---@field flipDealer fun(self: self): nil
---@field cleanup fun(self: self): nil
---
---@field createAuxLoop fun(self: self): nil
---@field updateBetStatus fun(self: self): nil
---@field updatePlayStatus fun(self: self): nil
---
---@field findDeck fun(self: self, force?: boolean): Object?
---@field isBetValid fun(self: self, color: string): boolean, Object[][]?, PlayerInstance?
---@field dealCardsTo fun(self: self, positions: VectorLike[], flip?: boolean): Object[]
---@field updateHandOwner fun(self: self, zone_color: string, object: Object): nil
---
---@field createButtons fun(self: self): nil
---@field leftButtonClick fun(self: self, player_color: string, alt: boolean, color: string): nil
---@field rightButtonClick fun(self: self, player_color: string, alt: boolean, color: string): nil
---@field centerButtonClick fun(self: self, player_color: string, alt: boolean, color: string): nil
---
---@field onObjectEnterZone fun(self: self, zone: Object, object: Object): nil
---@field onObjectLeaveZone fun(self: self, zone: Object, object: Object): nil
