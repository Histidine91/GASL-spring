function math.round(num, idp)
	return ("%." .. (((num==0) and 0) or idp or 0) .. "f"):format(num)
end

function Spring.Utilities.GetAnglesFromVector(vx, vy, vz)
    local rx, ry, rz
    local rx = math.atan2(vx, vy)
    if vz then
	ry = math.atan2(vx, vz)
    	rz = math.atan2(vy, vz)
    end
    return rx, ry, rz
end
