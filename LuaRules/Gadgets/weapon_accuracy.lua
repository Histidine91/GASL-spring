--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
   return {
      name      = "Accuracy",
      desc      = "Handles weapon accuracy based on stuff",
      author    = "KingRaptor",
      date      = "2013.05.26",
      license   = "GNU GPL, v2 or later",
      layer     = 0,
      enabled   = true, 
   }
end

--------------------------------------------------------------------------------
--SYNCED
--------------------------------------------------------------------------------
if not gadgetHandler:IsSyncedCode() then
   return
end

local UPDATE_PERIOD = 15

local BASE_MORALE = 50
local MORALE_ACCURACY_MULT = -0.25	-- 25% tighter spread at max morale
local SUPPRESSION_MULT = 0.5 	-- 50% wider spread at max suppression
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local spGetUnitDefID        	= Spring.GetUnitDefID
local spGetUnitRulesParam  	= Spring.GetUnitRulesParam

local spSetUnitWeaponState  = Spring.SetUnitWeaponState
local spGetUnitWeaponState  = Spring.GetUnitWeaponState

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local units = {}
local accDefs = {}	-- [unitDefID] = { [1] = {accuracy, sprayAngle}, [2] = ... }
local ecmDefs = {}	-- [unitDefID] = num

for i=1,#UnitDefs do
   local ud = UnitDefs[i]
   if ud.weapons then
      accDefs[i] = {}
      for w=1, #ud.weapons do
	 local weaponDefID = ud.weapons[w].weaponDef
	 local weaponDef = WeaponDefs[weaponDefID]
	 accDefs[i][#accDefs[i] + 1] = {
	    baseAccuracy = weaponDef.accuracy,
	    baseSprayAngle = weaponDef.sprayAngle,
	 }
      end
   end
   ecmDefs[i] = (ud.customParams.ecm or 0)/100
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetAccMult(unitID, unitDefID, targetID, targetDefID, params)
   params = params or {useSuppression = true, useECM = true, useMoraleDefender = true}
   
   local ecmMod = 0
   if params.useECM then
      ecmMod = targetDefID and ecmDefs[targetDefID] or 0
   end
   
   local moraleDefenderMod = 0
   if params.useMoraleDefender then
      local morale = GG.GetMorale(targetDefID)
      if morale then
	 moraleDefenderMod = (morale - BASE_MORALE)/BASE_MORALE * MORALE_ACCURACY_MULT
      end
   end
   
   local suppressionMod = 0
   if params.useSuppression then
      local suppression = GG.GetUnitSuppression(unitID)
      if suppression then
	 suppressionMod = suppression * SUPPRESSION_MULT
      end
   end
      
   local accMult = 1 + ecmMod + suppressionMod + moraleDefenderMod
   return accMult
end
GG.GetAccMult = GetAccMult

local function UpdateWeaponAccuracy(unitID, unitDefID, i)
   local defData = accDefs[unitDefID]
   local unitData = units[unitID]
   local targetID, targetDefID
   
   if not unitData then
      return
   end
      
   if unitData.env then
      targetID = GG.UnitScript.CallAsUnit(unitID, unitData.env.GetWeaponTarget, i)
      if targetID then
	 targetDefID = spGetUnitDefID(targetID)
      end
   end
     
   local accMult = GetAccMult(unitID, unitDefID, targetID, targetDefID)
   unitData.weapons[i] = accMult
   spSetUnitWeaponState(unitID, i, {accuracy = defData[i].baseAccuracy * accMult, sprayAngle = defData[i].baseSprayAngle * accMult})
end

local function UpdateUnitAccuracy(unitID, unitDefID)
   local defData = accDefs[unitDefID]
   local unitData = units[unitID]
   for i=1,#unitData.weapons do
      UpdateWeaponAccuracy(unitID, unitDefID, weaponNum)
   end
end

--GG.UpdateUnitAccuracy = UpdateUnitAccuracy
GG.UpdateWeaponAccuracy = UpdateWeaponAccuracy

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
   units[unitID] = nil
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
   if accDefs[unitDefID] then
      units[unitID] = {unitDefID = unitDefID, weapons = {}, env = Spring.UnitScript.GetScriptEnv(unitID)}
      for i=1,#accDefs[unitDefID] do
	 units[unitID].weapons[i] = 1
      end
   end
end

function gadget:Initialize()
  local units = Spring.GetAllUnits()
  for i=1,#units do
    local unitID = units[i]
    local unitDefID = Spring.GetUnitDefID(unitID)
    local unitTeam = Spring.GetUnitTeam(unitID)
    gadget:UnitCreated(unitID, unitDefID, unitTeam)
  end
end

--[[
function gadget:GameFrame(f)
   if f % UPDATE_PERIOD == 1 then
      for unitID, data in pairs(units) do
	 UpdateUnitAccuracy(unitID, data.unitDefID)
      end
   end
end
]]

