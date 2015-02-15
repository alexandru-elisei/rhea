--[[
	DISPLAY FUNCTIONS
	
]]--

if not display then
	display = {}
end --if

	--SYSTEM MESSAGE
function display.system (sMsg)
	
	ColourTell ("white", "royalblue", "  Rhea  ")
	ColourNote ("white", "", " >> "..sMsg)

end -- function

--Error message
function display.error (sMsg)
	
	ColourTell ("red", "blue", "  ERROR  ")
	ColourNote ("white", "", " "..sMsg)

end -- function


function display.option (sOp, val)
	
	local name = string.gsub (sOp, "_", " ")
	ColourTell ("aqua", "", "[SETTING]")
	ColourTell 	("lightgrey", "", " "..string.upper (string.sub (name, 1, 1))..
					string.lower (string.sub (name, 2)).." ")
	if val == true then
		ColourNote ("forestgreen", "", "ENABLED")
	elseif val == false or val == 0 then
		ColourNote ("red", "", "DISABLED")
	else
		ColourNote ("forestgreen", "", val)
	end--if
	
end --function


function display.auto (sOp, val)

	local name = string.gsub (sOp, "_", " ")
	ColourTell ("aqua", "", "[AUTO]")
	ColourTell 	("lightgrey", "", " "..string.upper (string.sub (name, 1, 1))..
					string.lower (string.sub (name, 2)).." ")
	if system:is_auto (sOp) then
		ColourNote ("forestgreen", "", "ENABLED")
	else
		ColourNote ("red", "", "DISABLED")
	end--if
	
end --function


function display.gear (items, name, val)
	
	items = string.upper (string.sub (items, 1, 1))..string.sub (items, 2)
	name = string.upper (string.sub (name, 1, 1))..string.sub (name, 2)
	ColourTell ("crimson", "yellow", " GEAR ")
	ColourTell 	("lightgrey", "", " "..name.." "..items.." set to ")
	ColourNote ("forestgreen", "", val)
	
end --function


	--WHEN YOU GET AFFLICTED
function display.affs (aff)

	if (type (aff) == "table") then
		for k, v in pairs (aff) do
			display.affs (v)
		end --for
	else
		aff = string.gsub (aff, "_", " ")
		ColourTell ("red", "", "AFF ")
		ColourNote ("white", "", string.upper(string.sub(aff, 1, 1))..string.lower(string.sub(aff, 2)))
	end --if
	
end --function


	--WHEN YOU GET CURED
function display.cured (sAff)

	string.gsub (sAff, "_", " ")
	ColourTell ("lime", "", "CURED ")
	ColourNote ("white", "", string.upper(string.sub(sAff, 1, 1))..string.lower(string.sub(sAff, 2)))
	
end --function


	--WHEN  A FAILSAFE FIRES
function display.fst (name)

	if name then
		name = string.gsub (name, "_", " ")
		ColourTell ("black", "yellow", " FST ")
		ColourNote ("white", "", " "..string.lower (name))
	end --if
	
end --function


function display.gn (sBal)

	if sBal then
		ColourTell ("black", "yellow", " GN  ")
		ColourNote ("white", "", " "..string.lower (sBal))
	end --if
	
end --function


function display.nocure (cure)

	if cure then
		ColourTell ("black", "yellow", " NOCURE ")
		ColourNote ("white", "", " "..string.gsub (cure, "_", " "))
	end--if

end --function


	--WARNING MESSAGE
function display.warning (sMsg)
	
	ColourTell ("white", "royalblue", "  Rhea  ")
	ColourTell ("white", "", " >> ")
	ColourNote ("white", "brown", string.upper(sMsg))
	
end -- function


	--WHEN YOU HAVE A DEF
function display.ondef (sDef)

	ColourTell ("lime", "", "DEF ")
	ColourNote ("white", "", string.upper(string.sub(sDef, 1, 1))..string.lower(string.sub(sDef,2)))
	
end --function

	
	--DOMOTH EFFECTS
function display.domoth (name, effect)

	ColourTell ("brown", "", "DOMOTH: ")
	ColourNote ("white", "", name.." - "..effect)
	
end --function


	--WHEN YOU LOSE A DEF
function display.lostdef (sDef)

	ColourTell ("crimson", "", "LOSTDEF ")
	ColourNote ("white", "", string.upper(string.sub(sDef, 1, 1))..string.lower(string.sub(sDef,2)))

end --function


function display.offbal (sBal)

	Tell ("OFFBAL ")
	ColourNote ("silver", "", sBal)

end --function


function display.onbal (sBal)

	ColourTell ("aqua", "", "ONBAL ")
	ColourNote ("silver", "", sBal)

end --function


function display.stance (s)

	ColourTell ("aqua", "", "STANCE ")
	ColourNote ("white", "", string.upper(string.sub(s, 1, 1))..string.lower(string.sub(s,2)))

end --function


function display.parry (part, amnt)

	ColourTell ("aqua", "", "PARRY ")
	ColourNote ("white", "", string.upper(string.sub(part, 1, 1))..string.lower(string.sub(part,2)).." "..amnt)

end --function


function display.free ()

	ColourNote ("aqua", "", ">>> GO >>> GO >>> GO >>> GO >>> GO >>> GO >>> GO >>> GO >>> GO >>> GO >>>")
	
end --function


function display.mod (modifier)
	
	modifier = string.upper (string.gsub (modifier, "%a", "%1 "))
	ColourTell ("black", "aqua", " MOD ")
	ColourNote ("lightgrey", "", " "..modifier)
	
end --mod


function display.success (aff, special)
	
	aff = string.gsub (aff, "%a", "%1 ")
	ColourNote ("red", "", string.rep ("-",24))
	ColourTell ("red", "", "[[ ")
	aff = string.upper (string.sub (aff, 1, 1))..string.lower (string.sub (aff, 2))
	ColourTell ("white", "", aff)
	ColourTell ("", "", string.rep (" ", 18-#aff))
	if special then
		ColourTell ("red", "", " ]] (")
		ColourTell ("silver", "", special)
		ColourNote ("red", "", ")")
	else
		ColourNote ("red", "", " ]]")
	end --if
	ColourNote ("red", "", string.rep ("-",24))
	
end --function


function display.enemy (msg, special)

	msg = string.upper (string.sub (msg, 1, 1))..string.sub (msg, 2)
	ColourTell ("orange", "", "[[ ")
	ColourTell ("white", "", msg)
	ColourNote ("orange", "", " ]]")
	
end --function


function display.parried ()

	ColourNote ("yellow", "", string.rep ("x", 13))
	ColourNote ("yellow", "", "| P A R R Y |")
	ColourNote ("yellow", "", string.rep ("x", 13))
	
end --function


function display.mult (fg, bg, text)
	
	local ll=80
	text = " "..text.." "
	text = string.rep (text, math.floor (ll/#text))
	text = string.sub (text, 2)
	ColourNote (fg, bg, text)
	
end --function


function display.miss ()

	ColourNote ("yellow", "", "-----------------")
	ColourNote ("yellow", "", "[[ M i s s e d ]]")
	ColourNote ("yellow", "", "-----------------")
	
end --function


function display.target_killed ()

	ColourNote ("lime", "", string.rep ("+", 80))
	display.mult ("lime", "", "DEAD")
	ColourNote ("lime", "", string.rep ("+", 80))
	
end --function


function display.shield ()

	ColourNote ("gold", "", string.rep ("o", 80))
	display.mult ("gold", "", "SHIELD")
	ColourNote ("gold", "", string.rep ("o", 80))
	
end--shield


function display.prone ()

	display.mult ("black", "aqua", "PRONE")
	
end --prone


	--DEBUGGING
function display.deb (osMsg)

	if system:is_enabled ("deb") then
		dbg = dbg or {}
		if
			osMsg
				then
			dbg [#dbg+1] = osMsg
		else
			display.tprint (dbg)
			dbg = {}
			dbg = nil
		end --if
	end --if

end --function


	--TABLE PRINTING
function display.tprint (t, option, indent, done)
	
	done = done or {}
	indent = indent or 0
		
	for key, value in pairs (t) do
		Tell (string.rep (" ", indent)) -- indent it
		if 
			type (value) == "table" and
			not done [value]
				then
			done [value] = true
			Note (tostring (key), ":");
			display.tprint (value, option, indent + 4, done)
		elseif
			option == nil
				then
			if
				type (value) ~= "function"
					then
				Tell (tostring (key), "=")
				print (value)
			end --if
		else
			Tell (tostring (key), "=")
			print (value)
		end--if
	end--for

end


return display







