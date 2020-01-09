local ADDON_FOLDER = debug.getinfo(1,"S").source:sub(2,-37)


local GROUP_INFO = {
	Global = "Global functions. These can be called without any class.",
	CBaseEntity = "The base class for stuff",
	CDOTA_PlayerResource = "Global accessor variable: <code>PlayerResource</code>",
	CDOTAGamerules = "Global accessor variable: <code>GameRules</code>",
	CDOTATutorial = "Global accessor variable: <code>Tutorial</code>",
	CEntities = "Global accessor variable: <code>Entities</code>",
	Convars = "Global accessor variable: <code>ConVars</code>",
	CScriptHeroList = "Global accessor variable: <code>HeroList</code>",
	CScriptParticleManager = "Global accessor variable: <code>ParticleManager</code>",
	Vector = "Global accessor variable: <code>Vector(x,y,z)</code>",
	CCustomGameEventManager = "Global accessor variable: <code>CustomGameEventManager</code>",
	CCustomNetTableManager = "Global accessor variable: <code>CustomNetTables</code>",
	CDOTA_CustomUIManager = "Global accessor variable: <code>CustomUI</code>",
}

local userInfo = {
	Global = {
		GetDedicatedServerKeyV2 = "used in https://github.com/dota2unofficial/12v12/blob/master/game/scripts/vscripts/common/webapi.lua",
		ApplyDamage = "ApplyDamage({victim = {}, attacker = {}, damage = 0, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR, ability = {}})",
	}
	CBaseEntity = {
		GetAbsOrigin = "Returns the position of the entity on the map. Very Useful!",
	},
	CDOTABaseAbility = {
		CastAbility = "You are probably looking for OnSpellStart()",
	},
}


function forOrdered(t,hFunc)
	if "table"~=type(t) then return end
	local keys = {}
	for k in pairs(t) do
		table.insert(keys,k)
	end
	table.sort(keys)
	for _,k in ipairs(keys) do
		local v = t[k]
		hFunc(k,v)
	end
end


function Activate()
	-- DumpScriptBindings()
	wikiCreator()
end

function wikiCreator()
	local preWiki = "{{otherlang2\n|zh-cn=Dota 2 Workshop Tools/Scripting/API:zh-cn\n|ru=Dota 2 Workshop Tools/Scripting/API:ru\n}}{{Note | This page is automatically generated. Changes can be submitted on Jochnickels github page: https://github.com/Jochnickel/dota_wiki_dumper}}\n  \n==='''Accessing the DOTA 2 Scripting API from Lua===\n\nWhile Lua is [http://en.wikipedia.org/wiki/Dynamically_typed dynamically typed], the DOTA 2 engine is written primarily in C++, which is [http://en.wikipedia.org/wiki/Type_system#Static_type-checking statically typed]. Thus, you'll need to be conscious of your data types when calling the API. (If you try to pass the wrong type to an API function, you'll get an error message in Vconsole telling you what you passed and what it was expecting.)\n__TOC__\n"
	local afterWiki ="\n{{shortpagetitle}}\n[[Category: Dota 2 Workshop Tools]]\n"
	local file = io.open(ADDON_FOLDER.."dumpWiki.txt","w")
	
	file:write(preWiki)
	file:write("\n=== Functions ===\n\n")
	file:write(generateClassGroup("Global",_G.FDesc))

	forOrdered(_G.CDesc,function(className,class)
		file:write(generateClassGroup(className,class.FDesc))
	end)

	-- file:write("=== Constants ===\n")

	-- forOrdered(_G.EDesc,function(constGroupName,constTable)
	-- 	file:write(generateConstGroup(constGroupName,constTable))
	-- end)

	-- file:write(afterWiki)



	file:close()
	print("FileDump Done")
end

function generateClassGroup(groupName,desc) -- returns wiki string
	local extendedClass = getmetatable( _G[groupName] ) and getmetatable( _G[groupName] ).__index
	local extendedClassName = "" for k,v in pairs(_G.CDesc) do if extendedClass==v then extendedClassName=k end end
	local out = string.format("==== %s ====\n",groupName)
	if extendedClass and extendedClass~=_G[groupName] then
		out = string.format("%s:::::extends [[#%s|%s]]\n",out,extendedClassName,extendedClassName)
	end
	out = string.format("%s''%s''\n",out,GROUP_INFO[groupName] or "No Description Set")
	out = out.."{| class=\"standard-table\" style=\"width: 100%;\"\n! Function \n! Signature \n! Description \n"
	forOrdered(desc,function(funcName,userd)
		out = string.format("%s|-\n",out)
		out = string.format("%s| [[Dota 2 Workshop Tools/Scripting/API/%s.%s | %s]] \n",out,groupName,funcName,funcName)
		-----
		local parameterList = {}
		for i = 0, #userd-1 do
			local prmType, prmName = unpack( userd[i] )
			if prmName == nil or prmName == "" then prmName = string.format( "%s_%d", prmType, i+1 ) end
			table.insert(parameterList,string.format("%s %s",prmType,prmName))
		end
		local fullFuncString = string.format("%s(%s)",funcName,table.concat(parameterList,", "))
		----
		out = string.format("%s| <code>%s %s</code>\n",out,userd.returnType,fullFuncString)
		local userDesc = userInfo and userInfo[groupName] and userInfo[groupName][funcName]
		out = string.format("%s| %s \n",out,userDesc or userd.desc or "No Description Set")
	end)
	out = out.."|}\n\n"
	return out
end

function generateConstGroup(groupName,desc)
	local out = string.format("==== %s ====\n",groupName)
	out = out.."{| class=\"standard-table\" style=\"width: 50%;\"\n! Name \n! Value \n! Description \n"
	forOrdered(desc,function(funcName,userd)
		out = string.format("%s|-\n",out)
		-- out = string.format("%s| [[Dota 2 Workshop Tools/Scripting/API/%s.%s | %s]] \n",out,groupName,funcName,funcName)
		-- -----
		-- local parameterList = {}
		-- for i = 0, #userd-1 do
		-- 	local prmType, prmName = unpack( userd[i] )
		-- 	if prmName == nil or prmName == "" then prmName = string.format( "%s_%d", prmType, i+1 ) end
		-- 	table.insert(parameterList,string.format("%s %s",prmType,prmName))
		-- end
		-- local fullFuncString = string.format("%s(%s)",funcName,table.concat(parameterList,", "))
		-- ----
		-- out = string.format("%s| <code>%s %s </code>\n",out,userd.returnType,fullFuncString)
		-- out = string.format("%s| %s \n",out,userd.desc or "No Description Set")
	end)
	out = out.."|}\n\n"
	return out
end
