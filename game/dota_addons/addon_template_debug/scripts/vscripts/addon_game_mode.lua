local ADDON_FOLDER = debug.getinfo(1,"S").source:sub(2,-37)



function forOrdered(t,hFunc)
	if "table"~=type(t) then return end
	local keys = {}
	for k in pairs(t) do
		table.insert(keys,k)
	end
	for _,k in ipairs(keys) do
		local v = t[k]
		hFunc(k,v)
	end
end


function Activate()
	dumpGlobals()
end



function dumpGlobals()
	local seenTables = {}
	local file1
	local file2
	function printDump(path,t)
		print(path,type(t),t)
		file1:write(path.." "..type(t).." "..tostring(t).."\n")
		if "userdata"==type(t) then
			-- local a = string.gsub(tostring(t),"\n","YOLO")
			file2:write(path.." "..type(t).." "..tostring(t).."\n")
		end
	end
	

	function dump(t,path)
		if seenTables[t] then 
			printDump(path.." == "..seenTables[t],t)
			return
		else
			printDump(path,t)
		end
		if "table"~=type(t) then return end
		seenTables[t] = path
		local keys = {}
		for k in pairs(t) do
			table.insert(keys,k)
		end
		table.sort(keys)
		for _,k in ipairs(keys) do
			local v = t[k]
			if "string"==type(k) then
				dump(v,path.."."..k)
			else
				dump(v,path.."["..k.."]")
			end
		end
	end
	file1 = io.open(ADDON_FOLDER.."dump1.txt","w")
	file2 = io.open(ADDON_FOLDER.."dump2.txt","w")
	dump(_G,"_G")
	file1:close()
	file2:close()
end


function wikiCreator()
	local file = io.open(ADDON_FOLDER.."dumpWiki.txt","w")

	function subPage(tab,preText,groupname)
		file:write(preText)
		forOrdered(tab,function(funcName,desc)
			local descParsed = string.gsub(desc,"\n","</code>\n| ")
			file:write("|-\n| [[Dota 2 Workshop Tools/Scripting/API/"..groupname.."."..funcName.." | "..funcName.."]]\n")
			file:write("| <code>"..descParsed)
		end)
	end
	
	subPage(
		_G.FDesc,
		"=== Global ===\n''Global functions.  These can be called without any class''\"{| class=\"standard-table\" style=\"width: 100%;\"\n! Function \n! Signature \n! Description \n",
		"Global"
	)

	file:close()
	
end
