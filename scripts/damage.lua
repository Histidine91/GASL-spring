-- effects
local damageFX = 1024

function DamageLoop(damagePiece)
	Signal(SIG_Damage);
	SetSignalMask(SIG_Damage);
	while true do
		local health = Spring.GetUnitHealth(MY_ID)
		if (health <= 50) then
			EmitSfx(damagePiece[1], damageFX)
			if (health <= 30) then
				EmitSfx(damagePiece[2], damageFX)
			end
		end
		Sleep(50)
	end
end