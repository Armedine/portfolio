function EnableDevCommands()
	local bool
	for i = 2,10 do
		if (GetPlayerSlotState(Player(i-1)) == PLAYER_SLOT_STATE_EMPTY) then
			bool = true
		else
			bool = false
			break
		end
	end
	if (bool == true) then
		udg_zEliteShopRemove = false
		EnableTrigger(gg_trg_Dev_AIPrintTesting)
		EnableTrigger(gg_trg_Dev_Test_Printing)
		EnableTrigger(gg_trg_Dev_Obj_Init)
		EnableTrigger(gg_trg_Dev_MUI_Test)
		EnableTrigger(gg_trg_Dev_Test_Upgrades)
		EnableTrigger(gg_trg_Dev_Disable_FF)
		EnableTrigger(gg_trg_Dev_Enable_FF)
		EnableTrigger(gg_trg_Dev_Disable_Item_Owners)
		EnableTrigger(gg_trg_Dev_Waves)
		EnableTrigger(gg_trg_Dev_Invul_Debug)
		EnableTrigger(gg_trg_Dev_CDs)
		EnableTrigger(gg_trg_Dev_Blink_Item)
		EnableTrigger(gg_trg_Dev_Damage_Item)
		EnableTrigger(gg_trg_Dev_Regen_Item)
		EnableTrigger(gg_trg_Dev_Health)
		EnableTrigger(gg_trg_Dev_Spawn)
		EnableTrigger(gg_trg_Dev_Spawn_10)
		EnableTrigger(gg_trg_Dev_Level_Up)
		EnableTrigger(gg_trg_Dev_Level_21)
		EnableTrigger(gg_trg_Dev_Exp)
		EnableTrigger(gg_trg_Dev_Exp_2)
		EnableTrigger(gg_trg_Dev_Level_Me)
		EnableTrigger(gg_trg_Dev_Food)
		EnableTrigger(gg_trg_Dev_Reveal)
		EnableTrigger(gg_trg_Dev_Pause_Alliance)
		EnableTrigger(gg_trg_Dev_Unpause_Alliance)
		EnableTrigger(gg_trg_Dev_Pause_Horde)
		EnableTrigger(gg_trg_Dev_Unpause_Horde)
		EnableTrigger(gg_trg_Dev_Night)
		EnableTrigger(gg_trg_Dev_Gold)
		EnableTrigger(gg_trg_Dev_Lumber)
		EnableTrigger(gg_trg_Dev_Day)
		EnableTrigger(gg_trg_Dev_Kill_Me)
		EnableTrigger(gg_trg_Dev_Level_Abils)
		EnableTrigger(gg_trg_Dev_Kill_Horde_Base)
		EnableTrigger(gg_trg_Dev_Kill_Alliance_Base)
		EnableTrigger(gg_trg_Dev_Share)
		EnableTrigger(gg_trg_Dev_MapTest)
		EnableTrigger(gg_trg_Dev_Elite)
		EnableTrigger(gg_trg_Dev_Clear)
	end
end
