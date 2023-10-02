-- @pInt = player number
function InitializeHotkey(pInt)

	local keytrig = CreateTrigger()
	local unitcaster = udg_unit

	local func = function()
		local pressedkey = BlzGetTriggerPlayerKey()
		local item
		if (pressedkey == OSKEY_E) then
			print("key OSKEY_E found")
			item = UnitItemInSlot(unitcaster,0)
			UnitUseItem(unitcaster,item)
		elseif (pressedkey == OSKEY_R) then
			print("key OSKEY_R found")
			item = UnitItemInSlot(unitcaster,1)
			UnitUseItem(unitcaster,item)
		elseif (pressedkey == OSKEY_D) then
			print("key OSKEY_D found")
			item = UnitItemInSlot(unitcaster,2)
			UnitUseItem(unitcaster,item)
		elseif (pressedkey == OSKEY_F) then
			print("key OSKEY_F found")
			item = UnitItemInSlot(unitcaster,3)
			UnitUseItem(unitcaster,item)
		elseif (pressedkey == OSKEY_C) then
			print("key OSKEY_C found")
			item = UnitItemInSlot(unitcaster,4)
			UnitUseItem(unitcaster,item)
		elseif (pressedkey == OSKEY_V) then
			print("key OSKEY_V found")
			item = UnitItemInSlot(unitcaster,5)
			UnitUseItem(unitcaster,item)
		end
	end

	BlzTriggerRegisterPlayerKeyEvent(keytrig, Player(pInt-1), OSKEY_E, 0, false)
	BlzTriggerRegisterPlayerKeyEvent(keytrig, Player(pInt-1), OSKEY_R, 0, false)
	BlzTriggerRegisterPlayerKeyEvent(keytrig, Player(pInt-1), OSKEY_D, 0, false)
	BlzTriggerRegisterPlayerKeyEvent(keytrig, Player(pInt-1), OSKEY_F, 0, false)
	BlzTriggerRegisterPlayerKeyEvent(keytrig, Player(pInt-1), OSKEY_C, 0, false)
	BlzTriggerRegisterPlayerKeyEvent(keytrig, Player(pInt-1), OSKEY_V, 0, false)

	TriggerAddAction(keytrig,func)
	TriggerAddCondition(keytrig, Filter(function() return not IsUnitType(unitcaster, UNIT_TYPE_DEAD) end))

	print("key init success")

end
