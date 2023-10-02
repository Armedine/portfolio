-- ***********************************************************************************************************************************************
-- :: pre-packaged group of functions for applying knockback.
-- :: requires Lua Group Utils.
-- ***********************************************************************************************************************************************

-- set up global KB ignore conditions if desired:
LUA_KB_CONFIG.defaultBoolE = function() return
	not IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)
	and not IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)
	and not IsUnitType(GetFilterUnit(),UNIT_TYPE_DEAD)
end

-- :: knock back units from a center point (angle being from center point towards position of affected units)
-- @unitOwner = owner of the KB (determines enemy and ally targets)
-- @x,y = point of origination.
-- @enemyBool = set to true for enemies, false for allies.
-- @areaEffectRadius = radius to look for units.
-- @KBdistance,KBpause,KBduration,KBcollisionFunc,KBcustomData = see original readme.
-- @boolexpr = (optional) custom boolean return conditions to pass in for units to knock back e.g. IsUnitType() etc. (overwrites the enemyBool flag)
function BasicKnockbackAreaPoint(unitKBowner,x,y,enemyBool,areaEffectRadius,KBdistance,KBpause,KBduration,KBcollisionFunc,KBcustomData,boolexpr)
	local g = CreateGroup()
	local angle
	local boolE
	if (boolexpr ~= nil) then
		boolE = boolexpr
	else
		if (enemyBool) then
			boolE = function() return IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(unitKBowner)) end
		else
			boolE = function() return IsUnitAlly(GetFilterUnit(),GetOwningPlayer(unitKBowner)) end
		end
	end	
	GroupEnumUnitsInRange(g,x,y,areaEffectRadius, Filter(function() return boolE() and LUA_KB_CONFIG.defaultBoolE() end ) )
	GroupUtilsAction(g,function()
		angle = AngleBetweenPointsXY(x,y,GetUnitX(LUA_FILTERUNIT),GetUnitY(LUA_FILTERUNIT))
		BasicKnockback(LUA_FILTERUNIT, angle, KBdistance, KBpause, KBduration, KBcollisionFunc, KBcustomData)
	end)
	DestroyGroup(g)
	boolE = nil
end
