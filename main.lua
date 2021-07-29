local game = Game()
local RepPlus = RegisterMod("Repentance Plus", 1)
local sfx = SFXManager()

local Collectibles = {
  ORDLIFE = Isaac.GetItemIdByName("Ordinary Life"),
  MISSINGMEMORY = Isaac.GetItemIdByName("Missing Memory")
}

local Trinkets = {
  BASEMENTKEY = Isaac.GetTrinketIdByName("Basement Key")
}