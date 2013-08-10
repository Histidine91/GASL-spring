-- Author: Tobi Vollebregt

-- Adds an aop_include() function, which enables includes with aspect oriented
-- touch to it: every function in script table that is included is prepended
-- to an already existing function in the script table, if any.

-- (In AOP terms, this makes the header of all script methods join points.)


if aop_include then return end


function aop_include(filename)

	-- here the trick is to temporarily swap out the 'script' table for an
	-- empty table, so after the include we can properly merge the functions.
	local oldScript = script
	local newScript = {}
	script = newScript
	include("aspects/"..filename)
	script = oldScript  --restore old script table

	-- now oldScript points to original script table (also destination of merge),
	-- and newScript points to the script table filled by the included file.
	for name,fun in pairs(newScript) do
		local oldFun = oldScript[name]
		if oldFun then
			oldScript[name] = function(...)
				fun(...)
				return oldFun(...)  --tail call
			end
		else
			oldScript[name] = fun
		end
	end

end