local PORTRAIT_DIR = "LuaUI/Images/portraits/"

local portraitList = {	--VFS.DirList(PORTRAIT_DIR)
	"milfeulle_normal",
	"milfeulle_happy",
	"milfeulle_veryhappy",
	"milfeulle_concerned",
	"milfeulle_serious",
	"milfeulle_oh",
	"milfeulle_stressed",
	"milfeulle_aggressive",
	"milfeulle_pain",

	"ranpha_normal",
	"ranpha_happy",
	"ranpha_veryhappy",
	"ranpha_relaxed",
	"ranpha_serious",
	"ranpha_angry",
	"ranpha_oh",
	"ranpha_worried",
	"ranpha_starryeyed",
	"ranpha_aggressive",
	"ranpha_pain",
	"ranpha_furious",
	
	"mint_normal",
	"mint_veryhappy",
	"mint_worried",
	"mint_surprised",
	"mint_aggressive",
	"mint_sigh",
	
	"forte_normal",
	"forte_happy",
	"forte_serious",
	"forte_oh",
	"forte_confident",
	"forte_concerned",
	"forte_what",
	"forte_pain",
	"forte_excited",
	
	"vanilla_normal",
	
	"chitose_normal",
	"chitose_happy",
	"chitose_sad",
	"chitose_angry",
	"chitose_surprised",
	"chitose_aggressive",
	"chitose_pain",
	
	"tact_normal",
	"tact_aggressive",
	"tact_angry",
	"tact_stressed",
	
	"lester_normal",
	"lester_serious",
	"lester_bitter",
	"lester_amused",
	"lester_aggressive",
	
	"almo_normal",
	"almo_surprised",
	"almo_happy",
	"almo_shocked",
	
	"coco_normal",
	"coco_happy",
	"coco_surprised",
	"coco_shocked",
}

portraits = {}

for i=1,#portraitList do
	local name = portraitList[i]
	portraits[name] = PORTRAIT_DIR..name..".png"
	--Spring.Echo(portraits[name])
end