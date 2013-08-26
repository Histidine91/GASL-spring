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

-- code by Greg James: http:--www.flipcode.com/archives/Fast_Point-In-Cylinder_Test.shtml
function Spring.Utilities.IsPointInCylinder(origin, vector, lengthsq, radius_sq, testpt, deNormalizeVector)
    local dx, dy, dz = unpack(vector)
    if deNormalizeVector then
	local length = lengthsq^0.5
	dx = dx * length
	dy = dy * length
	dz = dz * length
    end
    local pdx, pdy, pdz	-- vector pd from point 1 to test point
    local dot, dsq
    
    pdx = testpt[1] - origin[1]	-- vector from origin to test point.
    pdy = testpt[2] - origin[2]
    pdz = testpt[3] - origin[3]
    
    -- Dot the d and pd vectors to see if point lies behind the 
    -- cylinder cap at origin[1], origin[2], origin[3]
    
    dot = pdx * dx + pdy * dy + pdz * dz;
    
    -- If dot is less than zero the point is behind the origin cap.
    -- If greater than the cylinder axis line segment length squared
    -- then the point is outside the other end cap at pt2.
    
    if( dot < 0 or dot > lengthsq ) then
	--Spring.Echo(dot, lengthsq)
	return false
    else 
	-- Point lies within the parallel caps, so find
	-- distance squared from point to line, using the fact that sin^2 + cos^2 = 1
	-- the dot = cos() * |d||pd|, and cross*cross = sin^2 * |d|^2 * |pd|^2
	-- Carefull: '*' means mult for scalars and dotproduct for vectors
	-- In short, where dist is pt distance to cyl axis: 
	-- dist = sin( pd to d ) * |pd|
	-- distsq = dsq = (1 - cos^2( pd to d)) * |pd|^2
	-- dsq = ( 1 - (pd * d)^2 / (|pd|^2 * |d|^2) ) * |pd|^2
	-- dsq = pd * pd - dot * dot / lengthsq
	--  where lengthsq is d*d or |d|^2 that is passed into this function 
    
	-- distance squared to the cylinder axis:
    
	dsq = (pdx*pdx + pdy*pdy + pdz*pdz) - dot*dot/lengthsq
    
	if( dsq > radius_sq ) then
	    return false
	else
	    return true, dsq -- return distance squared to axis
	end
    end
end
