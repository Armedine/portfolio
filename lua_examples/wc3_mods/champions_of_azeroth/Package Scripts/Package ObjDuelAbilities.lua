-- @unit = pass in the obj unit to run a timer for, casting spells in their viscinity
-- @faction (int 0 or 1) = faction which determines the spell effect
function ObjDuelSpellGenerate(unit,f)
	-- config
	local spellInterval = 5.57 -- how often spell happens
	local spellDelay = 1.48 -- the spell delay
	local damage = 9*(udg_objRampReal*2.0) -- increment damage as game progresses
	local radius = 175.0 -- radius/range of damage
	--
	local p = GetOwningPlayer(unit)
	local counter = 0
	TimerStart(NewTimer(), spellInterval, true, function()
		if (not IsUnitAliveBJ(unit) or counter > 60) then
			ReleaseTimer()
		else
			local g = CreateGroup()
			local x = GetUnitX(unit)
			local y = GetUnitY(unit)
			GroupEnumUnitsInRange(g, x, y, 725.0, Condition( function() return DamagePackageEnemyNonSummonFilter(GetFilterUnit(), p) end ) )
			if (not IsUnitGroupEmptyBJ(g)) then
				local i = 0
				local u = GroupPickRandomUnit(g)
				-- transform x,y to position of picked unit
				x = GetUnitX(u)
				y = GetUnitY(u)
				-- create visual eye candy for the spell delay
				local castEffect = AddSpecialEffect('Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl', x, y)
				BlzSetSpecialEffectScale(castEffect,0.60)
				TimerStart(NewTimer(),spellDelay,false,function() -- cast after a delay
					DestroyEffect(castEffect)
					ObjDuelSpell(unit,x,y,damage,radius,f)
					ReleaseTimer()
				end)
			end
			DestroyGroup(g)
			counter = counter + 1 -- prevent infinite timer if unit check fails
		end
	end)
end


-- cast the ability for the unit it is attached to
function ObjDuelSpell(unit,x,y,damage,radius,f)
	local effect = ""
	if (f == 0) then
		effect = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl"
	elseif (f == 1) then
		effect = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
	end
	local i = 0 
	TimerStart(NewTimer(),0.11,true,function()
		-- generate effects in a radius using circle math https://programming.guide/random-point-within-circle.html
		local a = math.random() * 2 * 3.141 -- simplify pi to save on calc time
		local r = radius * math.sqrt(math.random())
		local x2 = x + (r * math.cos(a))
		local y2 = y + (r * math.sin(a))
		--
		DamagePackageDealAOE(unit, x, y, radius, damage, false, false, '', '', effect, 1.25, true)
		local e = AddSpecialEffect(effect, x2, y2)
		DestroyEffect(e)
		i = i+1
		if (i >= 24 or udg_victoryGameIsOver == true) then
			ReleaseTimer()
		end
	end)
end
