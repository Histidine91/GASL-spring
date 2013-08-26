local pilotsByName = {
    luckystar = {name = "Milfeulle Sakuraba", affiliation = "Angel Wing", portrait = "LuaUI/Images/portraits/milfeulle_normal.png"},
    kungfufighter = {name = "Ranpha Franboise", affiliation = "Angel Wing", portrait = "LuaUI/Images/portraits/ranpha_normal.png"},
    trickmaster = {name = "Mint Blancmanche", affiliation = "Angel Wing", portrait = "LuaUI/Images/portraits/mint_normal.png"},
    happytrigger = {name = "Forte Stollen", affiliation = "Angel Wing", portrait = "LuaUI/Images/portraits/forte_normal.png"},
    harvester = {name = "Vanilla H", affiliation = "Angel Wing", portrait = "LuaUI/Images/portraits/vanilla_normal.png"},
    sharpshooter = {name = "Karasuma Chitose", affiliation = "Angel Wing", portrait = "LuaUI/Images/portraits/chitose_normal.png"},
    elsior = {name = "Tact Meyers", affiliation = "Angel Wing", portrait = "LuaUI/Images/portraits/tact_normal.png"},
    placeholdersior = {name = "Tact Meyers", affiliation = "Angel Wing", portrait = "LuaUI/Images/portraits/tact_normal.png"},
    
    yngcommando = {name = "Neinzul Youngling", affiliation = "Roaming Enclave"},
    yngtiger = {name = "Neinzul Youngling", affiliation = "Roaming Enclave"},
    enclavestar = {name = "Enclave Mind-Hive", affiliation = "Roaming Enclave"},
}

pilotData = {}

for unitName, data in pairs(pilotsByName) do
    if UnitDefNames[unitName] then
	pilotData[UnitDefNames[unitName].id] = data
    end
end