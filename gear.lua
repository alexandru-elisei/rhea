--[[
		Module for tracking of gear, i.e. potions, herbs, and whatnot
--]]

if not gear then
	gear = {
		["vials"] = {
			["current"] = {},
			["desired"] = {},
		},
	}
end--if


function gear:reset (items)

	if items and self [items] ["current"] then 
		self [items] ["current"] = {}
	else
		for n, v in pairs (self) do
			if type (v) == "table" then
				self [n] = {}
			end--if
		end--for
	end--if
	
end--reset	


function gear:init (silent)
	
	loadstring (GetVariable ("gear_vials_current")) ()
	self ["vials"] ["current"] = gear_vials_current
	gear_vials_current = {}
	gear_vials_current = nil
	
	loadstring (GetVariable ("gear_vials_desired")) ()
	self ["vials"] ["desired"] = gear_vials_desired
	gear_vials_desired = {}
	gear_vials_desired = nil
	
	--loadstring (GetVariable ("gear_herbs_desired")) () --pending
	
end --init


function gear:save ()

	gear_vials_current = self ["vials"] ["current"] or "gear_vials_current={}"
	SetVariable ("gear_vials_current", serialize.save ("gear_vials_current"))
	gear_vials_current = {}
	gear_vials_current = nil
	
	gear_vials_desired = self ["vials"] ["desired"] or "gear_vials_desired={}"
	SetVariable ("gear_vials_desired", serialize.save ("gear_vials_desired"))
	gear_vials_desired = {}
	gear_vials_desired = nil

end --save


function gear:update (items, itype, name, number)

	if not items or not self [items] then
		return display.error ("Gear:update -> "..(items or "nil").." is Invalid!")
	end--items check
	
	if not itype then
		return display.error ("Gear:update -> Invalid item type")
	end --type check
	
	if not name then
		return display.error ("Gear:update -> Invalid name!")
	end--name check
	
	if number then
		self [items] [itype] [name] = number
	else
		self [items] [itype] [name] = (self [items] ["current"] [name] or 0)+1
	end--if
	
	if itype == "desired" then
		display.system (string.upper (string.sub (name, 1, 1))..
					string.lower (string.sub (name, 2)).." set to "..tostring (number))
	end--display
	
	self:save ()
	
end --update


function gear:check (items)
	
	if not items or not gear [items] then
		return display.error ("Gear:check -> "..(items or "nil").." Is Invalid!")
	end--if
	
	if not next (gear [items]) then
		return
	end--if
	
	if not gear [items] ["desired"] or not next (gear [items] ["desired"]) then
		return display.system ("Gear:check -> There is no desired quantity of "..items)
	end--if
	
	local needed = {}
	for name, number in pairs (gear [items] ["desired"]) do
		if 	not gear [items] ["current"] [name] then
			needed [name] = number
		elseif	gear [items] ["current"] [name] < number then
			needed [name] = number - gear [items] ["current"] [name]
		end--if
	end--for
	
	local c1 = 3
	local ca = "red"
	local cb = "silver"
	local c2 = 12
	
	if not next (needed) then
		return display.system ("All the desired "..items.." are OK")
	else
		
		local total = 0
		Note ("")
		if items == "vials" then
			display.warning ("Missing Potions:")
		else
			display.warning ("Missing "..items..":")
		end--if
		for name, ineed in pairs (needed) do
			total = total+ineed
			ColourTell (ca, "", "   [")
			ColourTell (cb, "", string.rep (" ", c1 - string.len (tostring (ineed)))..
							tostring (ineed))
			ColourTell (ca, "", "]")
			Tell ("   ")
			ColourTell (cb, "", string.rep (" ", c2-string.len(name))..name)
			Tell ("   ")
			ColourTell (ca, "", "["..string.rep (" ", 3-string.len (tostring (gear [items] ["current"] [name] or 0))))
			ColourTell (cb, "", tostring ((gear [items] ["current"] [name] or 0)).." in inventory,"..
							string.rep (" ", 3-string.len (tostring (gear [items] ["desired"] [name])))..
							tostring (gear [items] ["desired"] [name]).." desired")
			ColourNote (ca, "", " ]")
		end--for
		ColourTell (ca, "", "   [")
		ColourTell ("yellow", "", string.rep (" ", c1 - string.len (tostring (total)))..
								tostring (total))
		ColourTell (ca, "", "]")
		Tell ("   ")
		ColourNote ("yellow", "", string.rep (" ", c2-string.len("TOTAL")).."TOTAL")
	end--if
	
	if gear [items] ["current"] ["empty"] then
		local empty = gear [items] ["current"] ["empty"]
		Note ("")
		display.warning ("Empty "..items..":")
		ColourTell (ca, "", "   [")
		ColourTell (cb, "", string.rep (" ", c1 - string.len (tostring (empty)))..
							tostring (empty))
		ColourTell (ca, "", "]")
		Tell ("   ")
		ColourNote (cb, "", "empty vials")
	end--if
		
end --check


function gear:refill (number, potion)

	if not gear ["vials"] then
		return display.error ("No Vials Stored")
	end --vials check
	
	if not gear ["vials"] ["current"] then
		return display.error ("No Current Vials")
	end--current check
	
	if not gear ["vials"] ["desired"] then
		return display.error ("No Desired Vials")
	end--desired check
	
	self ["to_refill"] = {}
		--if I want to refill a number of vials
	if number then
		if not potion then
			return display.error ("You Must Specify a Number of Refills and a Potion")
		end
		local tag = {}
		tag [potion] = number
		self ["to_refill"] [1] = tag
	else--if I want to refill all the vials to desired potions
		for name, number in pairs (gear ["vials"] ["desired"]) do
			if (gear ["vials"] ["current"] [name] or 0) < number then
				local no = number - (gear ["vials"] ["current"] [name] or 0)
				local tag = {}
				tag [name] = no
				table.insert (self ["to_refill"], tag)
			end--if
		end --for
	end--if
	
	if next (self ["to_refill"]) then
		for name, number in pairs (self ["to_refill"] [#self ["to_refill"]]) do
			todo:add ("bal", "refilling", "refill empty from "..name)
			break
		end--for
		EnableTrigger ("refilling", true)
		EnableTrigger ("noemptyvial", true)
		EnableTrigger ("novial", true)
		EnableTrigger ("nogold", true)
		EnableTrigger ("nokeg", true)
	else
		display.system ("All Vials Are in the Desired Quantity")
		Execute ("pl")
		self ["to_refill"] = nil
	end--to_refill

end--refill.


function gear:refilled (aborted)

	todo:done ("refilling", "bal")
	if aborted then
		display.error ("Refill Aborted")
		EnableTrigger ("refilling", false)
		EnableTrigger ("noemptyvial", false)
		EnableTrigger ("novial", false)
		EnableTrigger ("nogold", false)
		EnableTrigger ("nokeg", false)
		Execute ("pl")
		self ["to_refill"] = {}
		self ["to_refill"] = nil
	else
		local last = #self ["to_refill"]
		for name, no in pairs (self ["to_refill"] [last]) do
			no = no-1
			if no<1 then
				self ["to_refill"] [last] = nil
			else
				self ["to_refill"] [last] [name] = no
			end--if
			break
		end --for
		if next (self ["to_refill"]) then
			for name, number in pairs (self ["to_refill"] [#self ["to_refill"]]) do
				todo:add ("bal", "refilling", "refill empty from "..name)
				break
			end--for
		else
			display.system ("Vials Are Refilled")
			Execute ("pl")
			self ["to_refill"] = {}
			self ["to_refill"] = nil
			EnableTrigger ("refilling", false)
			EnableTrigger ("noemptyvial", false)
			EnableTrigger ("novial", false)
			EnableTrigger ("nogold", false)
			EnableTrigger ("nokeg", false)
		end--if
	end --if
			
end--to_refill

function gear:makevial (gem, number, in_inv)
	
	if not gem then
		return display.error ("No gem type specified")
	end--if
	
	--if I have the vials in my inventory
	self ["vials"] ["in_inv"] = in_inv
	self ["vials"] ["gem_type"] = gem
	self ["vials"] ["to_fashion"] = number
	
	if not self ["vials"] ["to_fashion"] then
			--I fashion all the vials I need for my desired potions
		if not gear ["vials"] then
			return display.error ("No Vials Stored")
		end --vials check
		
		if not gear ["vials"] ["current"] then
			return display.error ("No Current Vials")
		end--current check
		
		if not gear ["vials"] ["desired"] then
			return display.error ("No Desired Vials")
		end--desired check
			
		number = 0
		for name, no in pairs (gear ["vials"] ["desired"]) do
			if not gear ["vials"] ["current"] [name] then
				number = number + no
			elseif no > gear ["vials"] ["current"] [name] then
				number = number + no - gear ["vials"] ["current"] [name]
			end--if
		end --for		
		number = number - (gear ["vials"] ["current"] ["empty"] or 0)
		self ["vials"] ["to_fashion"] = number
		
	end--if
		
		--if I don't have the vials in my inventory I outrift them each time
	if not self ["vials"] ["in_inv"] then
		todo:add ("free", "outr_gem", "outr 5 "..gem)
		EnableTrigger ("outr_gem", true)
		EnableTrigger ("outr_nogem", true)
	else
		todo:add ("bal", "makevial", "fashion vial "..gem)
		EnableTrigger ("madevial", true)
		EnableTrigger ("nogem", true)
		EnableTrigger ("novialtype", true)
		EnableTrigger ("noskill", true)
	end --if
	
end--makevial


function gear:madevial (aborted)
	
	todo:done ("makevial", "bal")
	if aborted then
		display.system ("Vial Making Canceled")
		gear ["vials"] ["to_fashion"] = nil
		gear ["vials"] ["in_inv"] = nil
		Execute ("pl")
		EnableTrigger ("outr_gem", false)
		EnableTrigger ("outr_nogem", false)
		EnableTrigger ("madevial", false)
		EnableTrigger ("nogem", false)
		EnableTrigger ("noskill", false)
		EnableTrigger ("novialtype", false)
		EnableTrigger ("madevial", false)
		EnableTrigger ("nogem", false)
		EnableTrigger ("novialtype", false)
		EnableTrigger ("noskill", false)
	else
		self ["vials"] ["to_fashion"] = self ["vials"] ["to_fashion"]-1
		if self ["vials"] ["to_fashion"] >=1 then
			if not self ["vials"] ["in_inv"] then
				todo:add ("free", "outr_gem", "outr 5 "..self ["vials"] ["gem_type"])
				EnableTrigger ("outr_gem", true)
				EnableTrigger ("outr_nogem", true)
			else
				todo:add ("bal", "makevial", "fashion vial "..self ["vials"] ["gem_type"])
				EnableTrigger ("madevial", true)
				EnableTrigger ("nogem", true)
				EnableTrigger ("noskill", true)
			end --if
		else
			gear ["vials"] ["to_fashion"] = nil
			gear ["vials"] ["in_inv"] = nil
			display.system ("Vials Crafted")
			Execute ("pl")
		end--if
	end--if

end--madevial


function gear:has (typ, name)

	if not typ then
		return false, display.error ("Specify a Gear Type!")
	end--typ
	if not name then
		return false, display.error ("Specify a Name to Search!")
	end--name
	if not self [typ] or not next (self [typ]) then
		return false, display.error ("Type Not Found!")
	end--not items
	
	for n, no in pairs (self [typ] ["current"]) do
		if n==name then return true end
	end--for
	
	return false

end--has
		
gear:init ()

return gear
		