
|cffffc800 YELLOW INFO TEXT|r 255 200 0

|cff6fff4dForest Creature|r
|cff6fff4d

|cffc0c0c0Cooldown:|r
|cffc0c0c0

|cff8080ff BLUE KEYWORD TEXT |r
|cff8080ff

|cffff4242 RED KEYWORLD NEGATIVE TEXT |r 255 66 66

|cff64ff64 GREEN KEYWORD POSITIVE TEXT|r 100 255 100

|cff2c2ce9 ALLIANCE COLOR CODE |r

|cffff2c2c HORDE COLOR CODE |r

|cffc800c8Experience|r

|cffff8505 FIRE/ORANGE/BURNING MAGIC COLOR CODE |r

|cff00b1ff FROST/ICE/LIGHT BLUE MAGIC COLOR CODE |r

|cff5aff5a ACID/GREEN/POISON MAGIC COLOR CODE |r

|cff64c8ff Amphibious |r


special effects repo:
Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl
ReplaceableTextures\\CommandButtons\\BTNWarStomp.blp
Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl
Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl
Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl
Abilities\\Weapons\\BlackKeeperMissile\\BlackKeeperMissile.mdl
Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl
Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl
Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl

MISSILE PACKAGE:
MissileGenerate(udg_hydraUnit, udg_temppoint, udg_tempstring, udg_tempstring, 80.0, 1.0, 1.0, 600.0, udg_tempreal, ?radius, true, false)

KNOCKBACK PACKAGE:
BasicKnockback(udg_footmanChargeTarget, AngleBetweenPoints(udg_temppoint,udg_temppoint2), 300.0, false, 0.25)

UnitApplyTimedLifeBJ( 30.0, FourCC('BTLF'), u )

DAMAGE PACKAGE SNIPPETS

add mana:
DamagePackageAddMana(udg_footmanUnit, 5, false)

restore health:
DamagePackageRestoreHealth(udg_unit,amountReal,bool)
DamagePackageRestoreHealth(udg_unit,amountReal,bool,effectString)

heal:
DamagePackageDealDirect(udg_cryptFiendUnit, udg_temptargetarray[udg_playerNumber], udg_DamageEventAmount, 0, 0, true, '')
DamagePackageDealDirect(GetTriggerUnit(), GetSpellTargetUnit(), udg_DamageEventAmount, 0, 0, true)

dummy self:
15% ms buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A029','bloodlust')
25% ms buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A042','bloodlust')
25% atksp buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A05S','bloodlust')
25% atksp buff 6 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A045','bloodlust')
25% ms + atksp buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A063','bloodlust')
25% ms + atksp buff 6 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A05G','bloodlust')
5 armor buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A05J','innerfire')
10 armor buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A053','innerfire')
10 armor buff 6 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A04J','innerfire')
15 armor buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A04L','innerfire')
25 armor buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A00O','innerfire')
50 armor buff 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A047','innerfire')

dummy target:
10% slow 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A07D','slow',GetSpellTargetUnit())
15% slow 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A04B','slow',GetSpellTargetUnit())
25% slow 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A009','slow',GetSpellTargetUnit())
25% atk speed slow 3 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A054','slow',GetSpellTargetUnit())
25% ms + atk speed slow 6 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A05H','slow',GetSpellTargetUnit())
stun 1 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A03H','thunderbolt',GetSpellTargetUnit())
stun 0.5 sec:
DamagePackageDummyTarget(GetTriggerUnit(),'A008','thunderbolt',GetSpellTargetUnit())
-5 armor:
DamagePackageDummyTarget(GetTriggerUnit(),'A04S','faeriefire',target)

dommy target point aoe:
DamagePackageDummyAoE(udg_gargoyleUnit, 'A04X', 'silence', nil, GetUnitX(udg_DamageEventTarget), GetUnitY(udg_DamageEventTarget), GetUnitX(udg_DamageEventTarget), GetUnitY(udg_DamageEventTarget), nil)

silence 1.0 sec:
DamagePackageDummyAoE(udg_tuskarrHealerUnit, 'A060', 'silence', nil, GetLocationX(udg_temppoint), GetLocationY(udg_temppoint), GetLocationX(udg_temppoint), GetLocationY(udg_temppoint), nil)

damage:
DamagePackageDealDirect(udg_taurenUnit, GetSpellTargetUnit(), udg_tempreal, 0, 0, false, 'abilities\\weapons\\catapult\\catapultmissile.mdl')

damage w/ special effect:
DamagePackageDealDirect(udg_hydraUnit, GetSpellTargetUnit(), udg_DamageEventAmount, 0, 0, false, 'abilities\\weapons\\catapult\\catapultmissile.mdl')


aoe damage w/o dummy:
DamagePackageDealAOE(udg_huntressUnit, GetLocationX(udg_temppoint), GetLocationY(udg_temppoint), 150.0, udg_DamageEventAmount, false, false, '', '', udg_tempstring, 1.0)
DamagePackageDealAOE(udg_hydraUnit, GetLocationX(udg_hydraBreathPoints[udg_tempint]), GetLocationY(udg_hydraBreathPoints[udg_tempint]), 
	200.0, udg_DamageEventAmount, false, false, '', '', 'Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl', 0.55)
DamagePackageDealAOE(udg_hydraUnit, GetLocationX(udg_hydraBreathPoints[udg_tempint]), GetLocationY(udg_hydraBreathPoints[udg_tempint]), 
	200.0, udg_DamageEventAmount, false, false, '', '', 'Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl', 0.55)

aoe damage w/ dummy:
DamagePackageDealAOE(udg_hydraUnit, GetLocationX(udg_hydraBreathPoints[udg_tempint]), GetLocationY(udg_hydraBreathPoints[udg_tempint]), 
	200.0, udg_DamageEventAmount, false, true, 'A03H', 'thunderbolt', 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl', 0.7)
DamagePackageDealAOE(udg_tuskarrHealerUnit, GetLocationX(udg_temppoint), GetLocationY(udg_temppoint), 200.0, 0.0, true, true, 'A047', 'innerfire', '', 0.7)

aoe heal:
DamagePackageDealAOE(udg_cryptFiendUnit, GetLocationX(udg_temppoint), GetLocationY(udg_temppoint), 250.0, udg_DamageEventAmount, true, false, '', '', '', 0)

preplaced unit variable naming = gg_unit_<rawcode>_<num> e.g. gg_unit_hkni_0000 (placed knight #1)

Change ability mana cost and CD (0-based i.e. level 1 is 0 in the function):
call BlzSetUnitAbilityCooldown( gg_unit_Hpal_0000, 'AHhb', 0, 1.00 )
call BlzSetUnitAbilityManaCost( gg_unit_Hpal_0000, 'AHhb', 0, 0 )