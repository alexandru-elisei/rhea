--[[
		DEALS WITH ENCHANTMENTS

-]]--

require "display"
require "serialize"


if not magic then
	magic = {
		["enchantments"] = {},
		["scrolls"] = {},
		["required"] = {
			["scrolls"] = {
				"protection",
				"healing",
			},
			["enchantments"] = {
				"mercy",
				"kingdom",
				"beauty",
				"perfection",
				"levitate",
				"waterwalk",
				"waterbreathe",
				"ignite",
				"cleanse",
				"acquisitio",
			},
		},
	}
end --if


function magic:reset (silent)

	self ["enchantments"] = {}
	self ["scrolls"] = {}
	
	if not silent	then
		display.system ("Magic items RESET")
	end --if
	
end --function


function magic:save ()

	system_enchantments = self ["enchantments"]
	SetVariable ("system_enchantments", serialize.save ("system_enchantments"))
	system_enchantments = {}
	system_enchentments = nil
	
	system_scrolls = self ["scrolls"]
	SetVariable ("system_scrolls", serialize.save ("system_scrolls"))
	system_scrolls = {}
	system_scrolls = nil
	
end --function


function magic:init ()

	loadstring (GetVariable ("system_enchantments")) ()
	self ["enchantments"] = system_enchantments
	system_enchantments = {}
	system_enchantments = nil
	
	loadstring (GetVariable ("system_scrolls")) ()
	self ["scrolls"] = system_scrolls
	system_scrolls = {}
	system_scrolls = nil
	
end --function


function magic:assign (spell, id, charges, verb)

	if
		not spell or
		not charges
			then
		return display.warning ("You Must Assign a Magic Item its SPELL, ID and CHARGES!")
	end --if
	
	if  not id then
		if not (magic ["enchantments"] [spell] or magic ["scrolls"] [spell]) then
			return display.warning ("You Must Assign a Magic Items its ID!")
		end --if
		if magic ["enchantments"] [spell] then
			id = magic ["enchantments"] [spell] ["id"]
		elseif magic ["scrolls"] [spell] then
			id = magic ["scrolls"] [spell] ["id"]
		end --if
	end --if
	
	if  not verb then
		if not (magic ["enchantments"] [spell] or magic ["scrolls"] [spell]) then
			return display.warning ("You Must Assign a Magic Items its VERB!")
		end --if
		if magic ["enchantments"] [spell] then
			verb = magic ["enchantments"] [spell] ["verb"]
		elseif magic ["scrolls"] [spell] then
			verb = magic ["scrolls"] [spell] ["verb"]
		end --if
	end --if
	
	if verb == "read" then
		self ["scrolls"] [spell] = {
			["id"] = id,
			["charges"] = tonumber (charges),
			["maxcharges"] = 50,
		}
	else
		local mc = 10
		if string.find (id, "bracelet") then
			mc = 20
		elseif string.find (id, "necklace") then
			mc = 30
		elseif string.find (id, "brooch") then
			mc = 40
		elseif string.find (id, "wands") then
			mc = 50
		elseif string.find (id, "tome") then
			mc = 50
		elseif string.find (id, "crown") then
			mc = 80		
		end --if
		self ["enchantments"] [spell] = {
			["id"] = id,
			["charges"] = tonumber (charges),
			["maxcharges"] = mc,
		}
		if not verb then
			self ["enchantments"] [spell] ["verb"] = "rub" --rub is the default
		else
			self ["enchantments"] [spell] ["verb"] = verb
		end --if
	end --if
	
	self:save ()
	
end --function


function magic:del (spell)

	magic ["scrolls"] [spell] = {}
	magic ["scrolls"] [spell] = nil
	magic ["enchantments"] [spell] = {}
	magic ["enchantments"] [spell] = nil
	display.system ("Magic Item "..spell.." Deleted")
	magic:save ()
	
end --if


function magic:check_required ()

	if not next (self ["scrolls"]) and not next (self ["enchantments"]) then
		system:set_settings ("magic_defs", 0, "silent")
		return display.warning ("No Magic Items Saved!")
	end --if
	
	local display_heading = true
	for kind, v in pairs (magic ["required"]) do
		local display_kind = true
		for k, name in ipairs (v) do
			local is_missing = false
			if  magic ["synced"] and not magic ["synced"] [name] then
				is_missing = true
			end --if
			if not is_missing and 
				not magic ["scrolls"] [name] and 
				not magic ["enchantments"] [name] and
				not skills:is_available (name)
					then
				is_missing = true
				todo:done ("recharge", "free")
			end --if
			if is_missing then
				if display_heading then
					Note ("")
					display.system ("Required magic items missing:")
					if system:is_enabled ("magic_defs") then
						system:set_settings ("magic_defs", 0, "silent")
					end --if
					display_heading = nil
				end --if
				if display_kind then
					display_kind = nil
					Note ("")
					ColourNote ("aqua", "", string.upper (kind)..":")
				end --if
				ColourNote ("red", "", "    "..name)
			end --if
		end --for
	end --for
	
end --function


function magic:sync ()

	if not system:is_enabled ("magiclist") then
		
		if magic ["number"] then
			return display.system ("Sync Aborted - Recharge in Progess")
		end --if
		
		if not next (self ["scrolls"]) and not next (self ["enchantments"]) then
			system:set_settings ("magic_defs", 0, "silent")
			return display.warning ("No Magic Items Saved!")
		end --if
		
		magic ["number"] = 0
		if next (self ["enchantments"]) then
			for name, tag in pairs (self ["enchantments"]) do
				todo:add ("free", "magic_sync", "p "..tag ["id"], nil, true)
				magic ["number"] = magic ["number"]+1
			end --for
		end --if
		
		if next (self ["scrolls"]) then
			for name, tag in pairs (self ["scrolls"]) do
				todo:add ("free", "magic_sync", "p "..tag ["id"], nil, true)
				magic ["number"] = magic ["number"]+1
			end --for
		end --if
		
		EnableTrigger ("magicsync", true)
		EnableTrigger ("magicsync_missingitem", true)
	else
		act:queue ("magiclist")
		act:exec ()
	end --if
	
end --function


function magic:sync_done ()

	if
		not next (todo ["free"]) or
		todo ["free"] [1] ["id"] ~= "magic_sync"
			then
		EnableTrigger ("magicsync", false)
		EnableTrigger ("magicsync_missingitem", false)
		
		if not system:is_enabled ("magiclist") then
			if not magic ["synced"] then
				magic ["synced"] = {}
				magic ["synced"] = nil
				magic ["number"] = nil
				return display.warning ("NO MAGIC ITEMS SYNCRONIZED")
			end --if
			
			if magic ["synced"] ["number"] < magic ["number"] then
				Note ("")
				display.system ("Missing assigned magic items:")
				
				local has_scrolls = true
				for name, tag in pairs (magic ["scrolls"]) do
					if not magic ["synced"] [name] then
						if has_scrolls then
							has_scrolls = nil
							Note ("")
							ColourNote ("aqua", "", "SCROLLS:")
						end --if
						local ch = 17
						ColourTell ("red", "", "    "..name)
						ColourNote ("silver", "", string.rep (" ", ch-string.len (name)-3)..": "..tag ["id"])
					end --if
				end --for
				local has_enchantments = true
				for name, tag in pairs (magic ["enchantments"]) do
					if not magic ["synced"] [name] then
						if has_enchantments then
							has_enchantments = nil
							Note ("")
							ColourNote ("aqua", "", "ENCHANTMENTS:")
						end --if
						local ch = 17
						ColourTell ("red", "", "    "..name)
						ColourNote ("silver", "", string.rep (" ", ch-string.len (name)-3)..": "..tag ["id"])
					end --if
				end --for
			else
				display.system ("All Magic Items Have Been SYNCHRONIZED")
			end--if
		end --if
		
		self:check_required ()
		
		magic ["synced"] = {}
		magic ["synced"] = nil
		magic ["number"] = nil
	end --if

end --function


function magic:recharge (all)

	if not next (self ["enchantments"]) and not next (self ["scrolls"]) then
		system:set_settings ("magic_defs", 0, "silent")
		return display.warning ("No Magic Items Saved!")
	end --if
	
	if all then
		flags:add_check ("recharging_all")
	end --if
	
	local all_charged = true
	if next (self ["enchantments"]) then
		for name, tag in pairs (self ["enchantments"]) do
			if tag ["charges"] < tag ["maxcharges"] then
				todo:add ("free", "recharge", "recharge "..tag ["id"].." from cube", nil, true)
				all_charged = false
				return
			end --if
		end --for
	end --if
	
	if next (self ["scrolls"]) then
		for name, tag in pairs (self ["scrolls"]) do
			if tag ["charges"] < 50 then
				todo:add ("free", "recharge", "recharge "..tag ["id"].." from cube", nil, true)
				all_charged = false
				return
			end --if
		end --for
	end --if
	
	if all_charged then
		display.system ("All magic items are already fully charged")
		flags:del_check ("recharging_all")
		if system:is_enabled ("magiclist") then
			flags:add_check ("recharge_done")
			Execute ("magiclist")
		end --if
		return
	end --if
	
end --function


function magic:recharged ()
	
		--getting the item I rechaged
	local item = string.sub (todo ["free"] [1] ["syntax"], 10, string.find (todo ["free"] [1] ["syntax"], " from cube")-1)
		--is it a scroll?
	for n, tag in pairs (magic ["scrolls"]) do
		if tag ["id"] == item then
			tag ["charges"] = 50
			display.system ("Recharged "..n)
			magic:save ()
				--if I am recharging all the items, then I scan for another item to recharge
			if flags:get_check ("recharging_all") then
				magic:recharge ()
			end --if
			return
		end --if
	end --for
		--or a normal enchantment?
	for n, tag in pairs (magic ["enchantments"]) do
		if tag ["id"] == item then
			tag ["charges"] = tag ["maxcharges"]
				--no need for more spam
			if not system:is_auto ("recharge") then
				display.system ("Recharged "..n)
			end --if
			magic:save ()
				--if I am recharging all the items, then I scan for another item to recharge
			if flags:get_check ("recharging_all") then
				magic:recharge ()
			end --if
			return
		end --if
	end --for
	
end --function

function magic:recharge_abort (reason)

	display.warning (reason)
	flags:del_check ("recharging_all")
	if system:is_enabled ("magiclist") then
		flags:add_check ("recharge_done")
		Execute ("magiclist")
	end --if
	
end --function


function magic:used (spell)

	if 
		not self ["enchantments"] [spell] and
		not self ["scrolls"] [spell]
			then
		return display.warning ("Spell Unassigned!")
	end--if
	
	if not flags:get_check ("arena") then
		local crg
		if self ["enchantments"] [spell] then
			crg = self ["enchantments"] [spell] ["charges"]-1
			self ["enchantments"] [spell] ["charges"] = crg
		elseif self ["scrolls"] [spell] then
			crg = self ["scrolls"] [spell] ["charges"]-1
			self ["scrolls"] [spell] ["charges"] = crg
		end --if
			--no need for further spam
		if system:is_auto ("recharge") and not affs:has ("blackout") then
			todo:add ("free", "recharge", "recharge "..magic:get_id (spell).." from cube", nil, true)
		else 
			if crg == 0 then
				display.warning ("You've RUN OUT Of "..spell.." Charges!")
			elseif crg<=2 then
				display.warning (tostring (crg).." Charges Remaining")
			else
				display.system (tostring (crg).." Charges Remaining")
			end --if
		end --if
		magic:save ()
	end --if
	flags:del_check ("magic")
	
end --function

	--point ignite at <target>, for regular use
	--point ignite at wall <direction>, for icewalls
function magic:use (spell, target, now)

	if not self:is_available ((spell or "nil")) then
		return display.warning ((spell or "nil").." not available!")
	else
		if self ["scrolls"] [spell] then
			if now then
				Send ("read "..self ["scrolls"] [spell] ["id"])
			else
				act:queue ("read "..self ["scrolls"] [spell] ["id"])
			end--if
		elseif self ["enchantments"] [spell] ["verb"] == "rub" then
			if target then
				if now then
					Send ("rub "..self ["enchantments"] [spell] ["id"].."  "..target)
				else
					act:queue ("rub "..self ["enchantments"] [spell] ["id"].."  "..target)
				end--if
			else
				if now then
					Send ("rub "..self ["enchantments"] [spell] ["id"])
				else
					act:queue ("rub "..self ["enchantments"] [spell] ["id"])
				end--if
			end --if
		elseif	self ["enchantments"] [spell] ["verb"] == "point" then
			if now then
				Send ("point "..self ["enchantments"] [spell] ["id"].." at "..(target or GetVariable ("system_target") or "nil"))
			else
				act:queue ("point "..self ["enchantments"] [spell] ["id"].." at "..(target or GetVariable ("system_target") or "nil"))
			end--if
		else
			if now then
				Send (self ["enchantments"] [spell] ["verb"].." "..self ["enchantments"] ["spell"] ["id"])
			else
				act:queue (self ["enchantments"] [spell] ["verb"].." "..self ["enchantments"] ["spell"] ["id"])
			end--if
		end --if
		flags:add_check ("magic", spell)
	end --if
	
end --function


function magic:is_available (spell)

		--I don't want to run out of healing in blackout... maybe
	if affs:has ("blackout") and spell == "healing" then
		return self ["scrolls"] ["healing"] ["charges"]>1
	end--if
	
	return 
		(self ["enchantments"] [spell] and next (self ["enchantments"] [spell]) and self ["enchantments"] [spell] ["charges"]>0) or
		(self ["scrolls"] [spell] and next (self ["scrolls"] [spell]) and self ["scrolls"] [spell] ["charges"] >0)
	
end --function


function magic:get_charges (spell)

	if self ["enchantments"] [spell] then
		return (self ["enchantments"] [spell] ["charges"] or 0)
	end--if
	if self ["scrolls"] [spell] then
		return (self ["scrolls"] [spell] ["charges"] or 0)
	end--if
	return false
end --function


function magic:is_enchantment (spell)

	return self ["enchantments"] [spell]
	
end --function


function magic:get_id (spell)

	if magic ["enchantments"] [spell] then
		return magic ["enchantments"] [spell] ["id"]
	elseif magic ["scrolls"] [spell] then
		return magic ["scrolls"] [spell] ["id"]
	else
		return nil
	end --if
	
end --get_id


magic:init ()


return magic

	
	