local ADDON_FOLDER = debug.getinfo(1,"S").source:sub(2,-37)


local GROUP_INFO = {
	Global = "Global functions. These can be called without any class.",
	CBaseEntity = "The base class for stuff",
	CDOTA_PlayerResource = "''Global accessor variable:'' <code>PlayerResource</code>",
	CDOTAGamerules = "''Global accessor variable:'' <code>GameRules</code>",
	CDOTATutorial = "''Global accessor variable:'' <code>Tutorial</code>",
	CEntities = "''Global accessor variable:'' <code>Entities</code>",
	Convars = "''Global accessor variable:'' <code>ConVars</code>",
	CScriptHeroList = "''Global accessor variable:'' <code>HeroList</code>",
	CScriptParticleManager = "''Global accessor variable:'' <code>ParticleManager</code>",
	Vector = "''Global accessor variable:'' <code>Vector(x,y,z)</code>",
	CCustomGameEventManager = "''Global accessor variable:'' <code>CustomGameEventManager</code>",
	CCustomNetTableManager = "''Global accessor variable:'' <code>CustomNetTables</code>",
	CDOTA_CustomUIManager = "''Global accessor variable:'' <code>CustomUI</code>",
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
	for k,v in pairs(debug.getinfo(_G.PlayerResource.__self)) do print(k,v) end
	-- wikiCreator()
end

function wikiCreator()
	local preWiki = "{{otherlang2\n|zh-cn=Dota 2 Workshop Tools/Scripting/API:zh-cn\n|ru=Dota 2 Workshop Tools/Scripting/API:ru\n}}{{Note | This page is automatically generated. Changes can be submitted on Jochnickels github page: https://github.com/Jochnickel/dota_wiki_dumper}}\n  \n==='''Accessing the DOTA 2 Scripting API from Lua===\n\nWhile Lua is [http://en.wikipedia.org/wiki/Dynamically_typed dynamically typed], the DOTA 2 engine is written primarily in C++, which is [http://en.wikipedia.org/wiki/Type_system#Static_type-checking statically typed]. Thus, you'll need to be conscious of your data types when calling the API. (If you try to pass the wrong type to an API function, you'll get an error message in Vconsole telling you what you passed and what it was expecting.)\n__TOC__"
	local file = io.open(ADDON_FOLDER.."dumpWiki.txt","w")
	file:write(preWiki)
	file:write(generateGroup("Global",_G.FDesc))
	forOrdered(_G.CDesc,function(className,class)
		file:write(generateGroup(className,class.FDesc))
	end)
	file:close()
	
end

function generateGroup(groupName,desc) -- returns wiki string
	local extendedClass = getmetatable( _G[groupName] ) and getmetatable( _G[groupName] ).__index
	local extendedClassName = "" for k,v in pairs(_G.CDesc) do if extendedClass==v then extendedClassName=k end end
	local out = string.format("=== %s ===\n",groupName)
	if extendedClass then
		out = string.format("%s:::::extends [[#%s|%s]]\n",out,extendedClassName,extendedClassName)
	end
	out = string.format("%s''%s''\n",out,GROUP_INFO[groupName] or "No Description Set")
	out = out.."{| class=\"standard-table\" style=\"width: 100%;\"\n! Function \n! Signature \n! Description \n"
	for funcName,userd in pairs(desc) do
		out = string.format("%s|- [[Dota 2 Workshop Tools/Scripting/API/%s.%s | %s]] \n",out,groupName,funcName,funcName)
		-----
		local parameterList = {}
		for i = 0, #userd-1 do
			local prmType, prmName = unpack( userd[i] )
			if prmName == nil or prmName == "" then prmName = string.format( "%s_%d", prmType, i+1 ) end
			table.insert(parameterList,string.format("%s %s",prmType,prmName))
		end
		local fullFuncString = string.format("%s(%s)",funcName,table.concat(parameterList,", "))
		----
		out = string.format("%s| <code>%s %s </code>\n",out,userd.returnType,fullFuncString)
		out = string.format("%s| %s \n",out,userd.desc or "No Description Set")
	end
	out = out.."|}\n\n"
	return out
end
