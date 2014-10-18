-- just for some misc. stuff; actual icon drawing is delegated to widget	-- nope
local icontypes = VFS.Include("LuaUI/Configs/icontypes.lua")
for iconName, data in pairs(icontypes) do
    --data.size = 0
end

return icontypes