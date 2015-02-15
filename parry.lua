--[[
		PARRYING A MAXIMUM OF 2 WOUNDED BODYPARTS
		AFTER A SPECIFIC WOUNDING LEVEL, I PARRY THAT BODYPART FULLY

]]--


--require system
require "display"
require "flags"
require "wounds"


if not parry then
	parry = {
		["unparried"] = nil,
		["needed"] = nil,
		["current"] = {},
		["to_parry"] = {},
		["spread"] = { --I only parry a maximum of TWO bodyparts at once
			{100},
			{50, 50},
		},
    }
end --if


function parry:is_needed ()

	if
		not system:is_enabled ("weaponparry") or
		not system:is_auto ("parry") or
		not self ["needed"] or
		not able:to ("parry") or
		not (wounds:get () or system:is_enabled ("default_parry")) or
		flags:get ("parry")
			then
		return false
	end --if
	
	return true
	
end --if


function parry:init ()

	self ["unparried"] = nil
	self ["to_parry"] = {}
	self ["needed"] = true
	
end --function


function parry:reset (silent)

	self ["to_parry"] = {}
	self ["current"] = {}
	self ["unparried"] = nil
	self ["needed"] = nil
	flags:del ("parry")
	fst:disable ("parry")
	
	if not silent	then
		display.system ("Parry RESET")
	end --if
	
end --function


function parry:has (bpart)

	return self ["current"] [bpart]
	
end --function


function parry:try (bpart)

	if next (self ["to_parry"]) then
		for k, t in ipairs (self ["to_parry"]) do
			if type (t) == "table" then
				for p, amnt in pairs (t) do
					if p == bpart then
						return true
					end --if
				end --for
			elseif p == bpart then
				return true
			end --if
		end --for
	end --if
	
	return false
	
end --function


function parry:scan ()
	
	if next (self ["to_parry"]) then
		parry:exec ()
		return
	end --if
	
	local local_priority = {}
	for k, part in ipairs (wounds ["bpart_priority"]) do
		local_priority [k] = part
	end --for
	
	local i = 1
	repeat
		if  
			affs:has ("pit") and
			string.find ((local_priority [i] or "nil"), "leg")--removing the legs from the bodypart priority
					then
			table.remove (local_priority, i)
		elseif	not wounds:get (local_priority [i]) then
			table.remove (local_priority, i)
		else
			i=i+1
		end --if
	until (i>#local_priority)
	
	if next (local_priority) then
		if
			wounds:get ("head") and
			wounds:get ("head") >= wounds ["wounds_level"] [4] --that's heavy
				then
			self ["to_parry"] [1] = "head"--head has the only one-hit insta; the others are delayed
		else
			for k, part in ipairs (local_priority) do
				if
					(not next (self ["to_parry"]) or wounds:get (part) > wounds:get (self ["to_parry"] [1]))
						then
					self ["to_parry"] [1] = part
				end --if
			end --for
			
			local second_parry = true
			
			if
				next (self ["to_parry"]) and
				((wounds:get ("head") or 0) >= wounds ["wounds_level"] [4] or --if I am parrying head
				wounds:get (self ["to_parry"] [1]) >= wounds ["wounds_level"] [5] or--I have extra heavy wounds
				(wounds:get (self ["to_parry"] [1]) >= wounds ["wounds_level"] [4] and string.find (self ["to_parry"] [1], "leg")))--or heavy to legs
					then
				second_parry = false
			end --if
				
			if second_parry then
				for k, part in ipairs (local_priority) do
					if 	
						wounds:get (part) and
						wounds:get (part) >= 800 and
						self ["to_parry"] [1] ~= part and
						(self ["to_parry"] [2] == nil or wounds:get (part) > wounds:get (self ["to_parry"] [2]))
							then
						self ["to_parry"] [2] = part
					end --if
				end --for
			end --if
			
		end --if
	elseif
		system:is_enabled ("default_parry")
			then
		if
			affs:has ("pit") and 
			string.find (system ["settings"] ["default_parry"], "leg")
				then
			parry ["to_parry"] [1] = "head"
		else
			self ["to_parry"] [1] = system ["settings"] ["default_parry"]
		end --if
	end --if
	
	if next (self ["to_parry"]) then
		if next (self ["current"]) then
			for k, p in ipairs (self ["to_parry"]) do
				if
					self ["current"] [p] and --if I am already parrying this bodypart
					self ["current"] [p] == self ["spread"] [#self ["to_parry"]] [k]--with the same amount
						then
					parry ["needed"] = nil
					return
				end --if
			end --for
		end --if					
		self:exec ()
	end --if
	
end --function
		
						
function parry:exec ()

	if type (parry ["to_parry"] [1]) ~= "table" then --if I haven't stored the parry amounts yet
		local tp = parry ["to_parry"]
		parry ["to_parry"] = {}
		for k, v in ipairs (tp) do
			local part = {}
			part [v] = parry ["spread"] [#tp] [k]
			table.insert (parry ["to_parry"], part)
			part = {}
		end --for
	end --if
	
	if not parry ["unparried"] then
		flags:add ("parry", "unparry")
		fst:enable ("parry")
		act:queue ("unparry all") --I first remove all previous parries
	else
		local part
		local amnt
		for p, a in pairs (self ["to_parry"] [1]) do
			part = p
			amnt= a
		end --for
		flags:add ("parry", part)
		fst:enable ("parry")
		part = string.gsub (part, "eft", "")
		part = string.gsub (part, "ight", "")
		act:queue ("parry "..part.." "..tostring (amnt))
	end--if
	
end --function
	
	
function parry:done (part)
	
	local amnt
	part = string.gsub (part, " ", "")
	if #self.to_parry==2 then
		amnt = 50
	else
		amnt = 100
	end --if
	parry:set (part, amnt)
	table.remove (self ["to_parry"], 1)
	flags:del ("parry")
	fst:disable ("parry")
	
	if not next (self ["to_parry"]) then--I finished parrying
		self ["needed"] = nil
		self ["unparried"] = nil
		return
	end --if
	
end --function


function parry:set (bpart, amnt, silent)
	
	self ["current"] [string.lower (bpart)] = amnt
	
	if not silent then
		display.parry (bpart, tostring (amnt))
	end --if
	
end --function
	

return parry
				
					
				
			

	
		
		