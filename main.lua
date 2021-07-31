local game = Game()
local rplus = RegisterMod("Repentance Plus", 1)
local sfx = SFXManager()
local music = MusicManager()

Collectibles = {
  -- 12RR, on use deactivates all items and deletes everything from every room, allowing you to pass freely. On second use, this item discharges and everything
  -- goes back to normal, allowing you to gain charges for next use.
	ORDLIFE = Isaac.GetItemIdByName("Ordinary Life"),
	MISSINGMEMORY = Isaac.GetItemIdByName("Missing Memory")
}

Trinkets = {
	BASEMENTKEY = Isaac.GetTrinketIdByName("Basement Key")
}

function rplus:OnGameStart(continued)
	if not continued then
		ORDLIFE_DATA = "notused"
		MISSINGMEMORY_DATA = nil
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, rplus.OnGameStart)

function rplus:OnItemUse(ctype, rng, player, flags, slot, customdata)
	local level = game:GetLevel()
	local player = Isaac.GetPlayer(0)
	
	if ORDLIFE_DATA == "notused" then
		ORDLIFE_DATA = "used"
		ORDLIFE_STAGE = level:GetStage()
		music:Disable()
		level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, false)
		PlayerSprite = player:GetSprite()
		PlayerSprite:Load("gfx/characters/character_001_ordinarylife.anm2", true)
		return {Discharge = false, Remove = false, ShowAnim = true}
	elseif ORDLIFE_DATA == "used" then
		ORDLIFE_DATA = "notused"
		music:Enable()
		level:RemoveCurses(LevelCurse.CURSE_OF_DARKNESS)
		return {Discharge = true, Remove = false, ShowAnim = true}
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_ITEM, rplus.OnItemUse, Collectibles.ORDLIFE)

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





















































