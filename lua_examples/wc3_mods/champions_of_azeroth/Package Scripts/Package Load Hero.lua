-- @unit = heroId to do lookup for
-- @i = player number to init
function LoadHero(unit, i)
	local t = GetUnitTypeId(unit)
	RemoveUnitFromAllStock(t)
	if (t == FourCC('O00E')) then
		FootmanInit(unit, i)
	elseif (t == FourCC('O00M')) then
		PriestInit(unit, i)
	elseif (t == FourCC('O00T')) then
		SpellBreakerInit(unit, i)
	elseif (t == FourCC('O00C')) then
		GruntInit(unit, i)
	elseif (t == FourCC('O00Q')) then
		TaurenInit(unit, i)
	elseif (t == FourCC('O00O')) then
		AcolyteInit(unit, i)
	elseif (t == FourCC('O00R')) then
		CryptFiendInit(unit, i)
	elseif (t == FourCC('O00H')) then
		GargoyleInit(unit, i)
	elseif (t == FourCC('E000')) then
		HuntressInit(unit, i)
	elseif (t == FourCC('O00P')) then
		WispInit(unit, i)
	elseif (t == FourCC('O00J')) then
		EredarWarlockInit(unit, i)
	elseif (t == FourCC('O00S')) then
		FelOrcWarlockInit(unit, i)
	elseif (t == FourCC('O010')) then
		ShamanInit(unit, i)
	elseif (t == FourCC('O012')) then
		KnightInit(unit, i)
	elseif (t == FourCC('O013')) then
		HydraInit(unit, i)
	elseif (t == FourCC('O014')) then
		TuskarrHealerInit(unit, i)
	elseif (t == FourCC('O016')) then
		OverlordInit(unit, i)
	elseif (t == FourCC('O01B')) then
		FurbolgInit(unit, i)
	elseif (t == FourCC('O01C')) then
		DruidClawInit(unit, i)
	elseif (t == FourCC('E00T')) then
		SpiritWalkerInit(unit, i)
	elseif (t == FourCC('O01F')) then
		HeadhunterInit(unit, i)
	elseif (t == FourCC('O01G')) then
		RiflemanInit(unit, i)
	elseif (t == FourCC('O01H')) then
		ForestTrollWarlordInit(unit, i)
	end
	local s = UnitId2String(t)
	s = string.gsub(s,"custom_","")
	udg_ZplayerHeroId[i] = s -- for debugging
	 -- remove from possible a.i. heroes to prevent duplicates
	if (DoesTableContainValue(ai__faction__heroes__horde,s)) then
		DAI__RemoveHeroId(s, 0)
	elseif (DoesTableContainValue(ai__faction__heroes__alliance,s)) then
		DAI__RemoveHeroId(s, 1)
	elseif (DoesTableContainValue(ai__faction__heroes__neutral,s)) then
		DAI__RemoveHeroId(s, 2)
	end
	BlzSetHeroProperName(udg_playerShop[i],GetUnitName(unit) .. "'s Shop")
	BlzSetHeroProperName(udg_playerShopElite[i],GetUnitName(unit) .. "'s Elite Shop")
end
