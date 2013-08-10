local PORTRAIT_DIR = "LuaUI/Images/portraits/"

local portraitList = {	--VFS.DirList(PORTRAIT_DIR)
	"milfeulle_normal",
	"milfeulle_happy",
	"milfeulle_veryhappy",
	"milfeulle_concerned",
	"milfeulle_serious",
	"milfeulle_stressed",
	"milfeulle_aggressive",
	"milfeulle_pain",
	"milfeulle_oh",
	
	"ranpha_normal",
	"ranpha_happy",
	"ranpha_veryhappy",
	"ranpha_serious",
	"ranpha_aggressive",
	"ranpha_pain",
	
	"forte_normal",
	"forte_happy",
	"forte_serious",
	"forte_confident",
	"forte_concerned",
	"forte_pain",
	"forte_excited",
}

portraits = {}

for i=1,#portraitList do
	local name = portraitList[i]
	portraits[name] = PORTRAIT_DIR..name..".png"
	--Spring.Echo(portraits[name])
end