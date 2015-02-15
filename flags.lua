--[[
	SETS A FLAG FOR DIFFERENT ACTIONS
]]--


if
	not flags
		then
	flags = {
		current = {}, --flags for afflictions
		checking = {
			["prone"] = {},
			["bal"] = {},
		},--flags for various checks
	}
end --if

	--resets all current and check flags
function flags:reset (silent, keep_checks)

	self ["current"] = {}
	if not keep_checks then
		flags:reset_check ("silent")
	end --if
	
	if not silent	then
		display.system ("Flags RESET")
	end --if
	
end --function


function flags:reset_check (silent)

	self ["checking"] = {
		["prone"] = {},
		["bal"] = {},
	}
	
	if not silent then
		display.system ("Fags Checking RESET")
	end --if
	
end --function


function flags:add (sName, sVal) --sVal will be the cure;
	if sName then
		sVal = sVal or 1
		self ["current"] [sName] = string.gsub (sVal, " ", "_")
		display.deb ("FLAGS:SET -> "..sName..": "..flags:get (sName))
	end --if
			
end --function


function flags:add_check (name, val)

	if name then
		val = val or true
		if type (val) == "string" then
			val = string.gsub (val, " ", "_")
		end--if
		self ["checking"] [name] = val
		
		display.deb ("FLAGS:SET -> "..name..": "..tostring (flags:get_check (name)))
	else
		flags:reset_check ("silent")
	end --if
			
end --function


function flags:get (sName) --returns the cure sent for the flag

	return self ["current"] [sName]

end --function


function flags:get_check (sName) --returns the cure sent for the flag

	return self ["checking"] [sName]

end --function

	--if i sent a specific cure
function flags:is_sent (sCure) --returns the affliction that was cured by sCure

	local aff
	if next (flags ["current"]) and sCure then
		for a, c in pairs (flags ["current"]) do
			if string.find (c, sCure) then
				aff = a
				break
			end --if
		end --for
	end --if
	
	return aff
	
end --function	

	--getting the cure sent by balance
function flags:bals_try (bal)

	local aff
	local cure
	if next (flags ["current"]) and bal then
		for a, c in pairs (flags ["current"]) do
			if affs:get_bal (c) == bal then
				aff = a
				cure = c
				break
			end --if
		end --for
	end --if
	
	return aff, cure
	
end --function


function flags:del (name) --deletes a current flag (the flag can only be an affliction)
	
	if name	then
		if type (name) == "table" then
			for k, v in ipairs (name) do
				flags:del (v)
			end --for
		else
			self ["current"] [name] = nil
		end --if
	end --if

end --function


function flags:del_check (sName)

	if sName then
		if type (sName) == "table" then
			for k, v in ipairs (sName) do
				flags:del_check (v)
			end --for
		else
			self ["checking"] [sName] = nil
		end --if
	else--this is if I want to delete the last check, like in the case of the illusion thing
		self ["checking"] [#self ["checking"]] = nil
	end --if
	
end --function

	--shorthand for flags:add_check ("recklessness")
function flags:damaged (option)
	
	self ["checking"] ["recklessness"] = (option or true)
	display.deb ("FLAGS:DAMAGED -> "..tostring (option))
	
end--damaged



return flags