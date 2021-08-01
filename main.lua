---!! VARIABLES !!---
local game = Game()
local rplus = RegisterMod("Repentance Plus", 1)
local sfx = SFXManager()
local music = MusicManager()

local BASEMENTKEY_CHANCE = 5

Collectibles = {
	-- 12RR, on use deactivates all items and deletes everything from every room, allowing you to pass freely. On second use, this item discharges and everything
	-- goes back to normal, allowing you to gain charges for next use.
	ORDLIFE = Isaac.GetItemIdByName("Ordinary Life"),
	-- Passive, allows you to continue runs after Mother is defeated.
	MISSINGMEMORY = Isaac.GetItemIdByName("Missing Memory")
}

Trinkets = {
	-- Passive. Every golden chest has a chance to turn into an old chest.
	BASEMENTKEY = Isaac.GetTrinketIdByName("Basement Key")
}

PocketItems = {
	BERSERKER = Isaac.GetCardIdByName("The Berserker"),
	SDDSHARD = Isaac.GetCardIdByName("Spindown Dice Shard")
}


---!! LOCAL FUNCTIONS !!---
-- If Isaac has Mom's Box, trinkets' effects are doubled.
local function HasBox(trinketchance)
	if Isaac.GetPlayer(0):HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
		trinketchance = trinketchance * 2
	end
	return trinketchance
end





---!! GLOBAL FUNCTIONS !!---
-- GAME STARTED --
function rplus:OnGameStart(continued)
	if not continued then
		ORDLIFE_DATA = nil
		MISSINGMEMORY_DATA = nil
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, rplus.OnGameStart)

-- ACTIVE ITEM USED --
	-- this function is solely for Ordinary Life item
function rplus:OnItemUse(ctype, rng, player, flags, slot, customdata)
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	
	if not ORDLIFE_DATA then
		ORDLIFE_DATA = "used"
		ORDLIFE_STAGE = level:GetStage()
		music:Disable()
		level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, false)
		PlayerSprite = player:GetSprite()
		PlayerSprite:Load("gfx/characters/character_001_ordinarylife.anm2", true)
		return {Discharge = false, Remove = false, ShowAnim = true}
	elseif ORDLIFE_DATA == "used" then
		ORDLIFE_DATA = nil
		music:Enable()
		level:RemoveCurses(LevelCurse.CURSE_OF_DARKNESS)
		return {Discharge = true, Remove = false, ShowAnim = true}
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_ITEM, rplus.OnItemUse, Collectibles.ORDLIFE)

-- EVERY FRAME --
function rplus:OnFrame()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	local stage = level:GetStage()
	
	if player:HasCollectible(Collectibles.ORDLIFE) and ORDLIFE_DATA == "used" then
		for i = 0,7 do
			door = room:GetDoor(i)
			if door then door:Open() end
		end
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type > 4 and entity.Type ~= 33 and entity.Type ~= 1000 and entity.Type ~= 17 then
				entity:Remove()
			end
		end
		if ORDLIFE_STAGE ~= level:GetStage() then
			player:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
			player:UseActiveItem(Collectibles.ORDLIFE, false, false, true, false, -1)
			ORDLIFE_DATA = "notused"
		end
	end
	
	if player:HasCollectible(Collectibles.MISSINGMEMORY) then
		if MISSINGMEMORY_DATA == "dark" and player:GetSprite():IsPlaying("Trapdoor") then
			level:SetStage(LevelStage.STAGE4_2, StageType.STAGETYPE_ORIGINAL)
			MISSINGMEMORY_DATA = nil
		elseif MISSINGMEMORY_DATA == "light" and player:GetSprite():IsPlaying("LightTravel") then
			level:SetStage(LevelStage.STAGE4_2, StageType.STAGETYPE_ORIGINAL)
			MISSINGMEMORY_DATA = nil
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_UPDATE, rplus.OnFrame)

-- WHEN NPC (ENEMY) DIES --
function rplus:OnNPCDeath(npc)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(Collectibles.MISSINGMEMORY) and npc.Type == EntityType.ENTITY_MOTHER then
		if player:HasCollectible(328) then
			Isaac.GridSpawn(GridEntityType.GRID_TRAPDOOR, 0, Vector(320,280), false)
			MISSINGMEMORY_DATA = "dark"
		elseif player:HasCollectible(327) then
			Isaac.Spawn(1000, EffectVariant.HEAVEN_LIGHT_DOOR, 0, Vector(320,280), Vector.Zero, nil)
			MISSINGMEMORY_DATA = "light"
		end
	end	
end
rplus:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, rplus.OnNPCDeath)

-- ON PICKUP INITIALIZATION -- 
function rplus:OnPickupInit(pickup)
	local player = Isaac.GetPlayer(0)
	
	if player:HasTrinket(Trinkets.BASEMENTKEY) and pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST and math.random(100) <= HasBox(BASEMENTKEY_CHANCE) then
		pickup:Morph(5, PickupVariant.PICKUP_OLDCHEST, 0, true, true, false)
	end
	
	-- If you want custom pickups to look fancy on the ground, use this template to replace the spritesheet 
	-- (the spritesheet HAS to be exactly 128*128 with the image of custom pickup almost in the top-left, because
	-- cardbacks default to a suit card, and we need to replace how THIS SUIT CARD'S BACK looks).
	if pickup.Variant == 300 and pickup.SubType == PocketItems.SDDSHARD then
		local sprite = pickup:GetSprite()
		sprite:ReplaceSpritesheet(0, "gfx/items/pick ups/sddshard.png")
		sprite:LoadGraphics()
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, rplus.OnPickupInit)





















































