--[[
	GENERAL DEFENSE SCRIPS
	
]]--


require "display"
require "wounds"
--require system

if
	not defs
		then
	defs = {
		["current"] = {},
		["available"] = {},
		["free"] = {},
		["ubal"] = {},
		["rbal"] = {},
		["power"] = {},
	}
end --if


local domoth_effects =
{
  ["Nature"] = {
	["minor"] = "Double growth rate for an herb",
	["lesser"] = "Increase one herb's room maximum, skip hibernation",
	["major"] = "One herb has the sparkleberry effect",
  },
  ["Knowledge"] = {
	["minor"] = "+2 intelligence for your race",
	["lesser"] = "10 Magic DMP for your guild",
	["major"] = "Increased power/culture for scholars",
  },
  ["Beauty"] = {
	["minor"] = "+2 charisma for your race",
	["lesser"] = "Increased influence damage for your guild",
	["major"] = "Increased power/culture for bards",
  },
  ["Chaos"] = {
	["minor"] = "+3 to a random stat for your race",
	["lesser"] = "Random regeneration for your guild",
	["major"] = "Increased resistance to astral insanity",
  },
  ["Harmony"] = {
	["minor"] = "Increased experience gain for your race",
	["lesser"] = "Decreased experience loss for your guild",
	["major"] = "Double the dross power limit",
  },
  ["Justice"] = {
	["minor"] = "Increased willpower for your race",
	["lesser"] = "Aura of justice for your guild",
	["major"] = "Increased damage from discretionary powers",
  },
  ["War"] = {
	["minor"] = "+2 strength for your race",
	["lesser"] = "Increased attack damage for your guild",
	["major"] = "Increased level of guards",
  },
  ["Life"] = {
	["minor"] = "+2 constitution for your race",
	["lesser"] = "Decreased damage received for your guild",
	["major"] = "Health regeneration on Prime non-enemy grounds",
  },
  ["Death"] = {
	["minor"] = "Increased endurance for your race",
	["lesser"] = "Aura of vengeance for your guild",
	["major"] = "Catacombs of the Dead map at the nexus",
  },
}


function defs:reset (silent)

	self ["current"] = {}
	self ["free"] = {}
	self ["rbal"] = {}
	self ["ubal"] = {}
	self ["power"] = {}
	fst:disable ("deffing")
	flags:del ("deffing")
	
	if not silent then
		display.system ("Defenses RESET")
	end --if
	
end --function


function defs:has (defense)

	if not defense then
		return false
	else
		return self ["current"] [string.lower (defense)]
	end --if
	
end --function


function defs:to_def (ctg)
	
	if ctg == "free" then
		return next (self ["free"]) and not affs:has ("asleep")
	elseif ctg == "bal" then
		if affs:has ("blackout") then
			return
		end --if
		return (next (self ["ubal"]) or next (self ["rbal"])) and not affs:is_prone ()
	else
		display.warning ("no such defense category")
	end --if
	
end --function


function defs:start ()

	local has_sharpness = defs:has ("sharpness")
	local has_demoncloak = defs:has ("demoncloak")
	self:reset ("silent")
	stance:reset ("silent")
	flags:del ("waiting_for_def")
	defs ["current"] ["sharpness"] = has_sharpness
	defs ["current"] ["demoncloak"] = has_demoncloak
	
end --start


function defs:ondef (defense, val, silent)
	
	if type (defense) == "table" then
		for k, v in ipairs (defense) do
			defs:ondef (v)
		end --for
	else
			--some defenses are gained by using a cure
		if not defs:has (defense) then
			system:del_cure ()
		end --if
		if defense == "speed" then
			bals:onbal ("speed", "silent")
			affs:del ("no_speed")
			fst:disable ("speed")
			fst:disable ("ondef_speed")
			prompt:del_alert ("nospeed")
		--elseif (flags:get_check ("magic") or "nil") == defense then
			--magic:used (defense)
		end --if
		self ["current"] [defense] = (val or true)
		if (flags:get ("deffing") or "nil") == defense then
			fst:disable ("deffing")
			flags:del ("deffing")
			self:del (defense)
		end --if
	end --if
	
	if not silent then
		display.ondef (defense.." "..(val or ""))
	end --if
	
end --function


function defs:domoth (realm, str)

	if flags:get ("waiting_for_def") then
		local has_sharpness = defs:has ("sharpness")
		self:reset ("silent")
		flags:del ("waiting_for_def")
		if has_sharpness then
			defs ["current"] ["sharpness"] = has_sharpness
		end --if
	end --if
	
	display.domoth (realm.." "..str, domoth_effects [realm] [str])
	
end--if


function defs:del (defense)

	if type (defense) == "table" then
		for k, v in ipairs (defense) do
			defs:del (v)
		end--for
	end --if

	local is_free = system:getkey (self ["free"], defense)
	
	if is_free	then
		table.remove (self ["free"], is_free)
	else
		local is_rbal = system:getkey (self ["rbal"], defense)
		if is_rbal	then
			table.remove (self ["rbal"], is_rbal)
		else
			local is_ubal = system:getkey (self ["ubal"], defense)
			if is_ubal then
				table.remove (self ["ubal"], is_ubal)
			end --if
		end --if
	end --if
	
end --function


function defs:add_queue (defense, val, silent)

	prompt:queue (function ()defs:ondef (defense, val, silent)end, "defs_add_"..defense, true)
	
end --function


function defs:del_queue (defense, silent)

	prompt:queue (function ()defs:lostdef (defense, silent)end, "lostdef_"..defense, true)
	
end --function


function defs:lostdef (defense, silent)

	
	if type (defense) == "table" then
		for k, d in ipairs (defense) do
			defs:lostdef (d, "silent")
		end --for
	elseif defs ["current"] [defense] then
		self ["current"] [defense] = nil
		if defense == "speed" then
			self ["current"] ["adrenaline"] = nil
			bals:onbal ("speed", "silent")
		end --if
		if not silent then
			display.lostdef (defense)
		end --if
	end --if
	
end --function


function defs:scan (ctg)

	if not flags:get ("waiting_for_def") then
		if ctg == "free" and next (self ["free"]) then
			self:scan_free ()
		elseif ctg == "bal" and (next (self ["rbal"]) or next (self ["ubal"])) then
			self:scan_bal ()
		elseif not ctg then
			self:scan_free ()
			self:scan_bal ()
		end --if
	end --if
	
end --function


function defs:scan_free ()

	if not flags:get ("deffing") and next (self ["free"]) then
		for k, d in ipairs (self ["free"]) do
			if self:able (d) then
				self:use (d)
				break
			end --if
		end --for
		defs:unqueue ("free")
	end --if

end --function


function defs:scan_bal ()

	if not flags:get ("deffing") then
		if next (self ["rbal"]) then
			for k, d in ipairs (self ["rbal"]) do
				if
					not self:has (d) and
					self:able (d)
						then
					return self:use (d)
				end --if
			end --for
			defs:unqueue ("rbal")
		end --if
	
		if next (self ["ubal"]) then
			for k, d in ipairs (self ["ubal"]) do
				if
					not self:has (d) and
					self:able (d)
						then
					flags:add ("bal")
					return self:use (d)
				end --if
			end --for
			defs:unqueue ("ubal")
		end --if
	end --if

end --function


function defs:use (defense)
		
	if skills:is_available (defense) then
		skills:use (defense)
	elseif magic:is_enchantment (defense) then
		magic:use (defense)
	else
		return
	end --if
	
	fst:enable ("deffing")
	flags:add ("deffing", defense)
	
end --function
	
	
function defs:able (defense)--I specify a defense -> I don't have an able_ check for it, I return bal and eq
															---> I have an able_ check, I return the check
										--I don't specify a defense, I return true
	if affs:has("asleep") then
		return false
	end--if
	
	if defense then
		local fn = self ["able_"..defense]
		if not (fn) then--if I don't have a condition for the defense, return bal and eq
			if
				system:getkey (self ["ubal"], defense) or
				system:getkey (self ["rbal"], defense)
					then
				return (bals:has ("bal") and bals:has ("eq")) --if I don't have a special check for it, then assume it only requires balance and eq
			elseif system:getkey (self ["free"], defense) then
				return true
			elseif magic:is_enchantment (defense) then
				if bals:has ("bal") and bals:has ("eq") then
					return true
				else
					return false
				end --if
			end--if
		else
			return fn ()
		end --if
	else
		return true--defaulting to true if I haven't specified a particular defense
	end --if
	
	return false
	
end --function


function defs:unqueue (ctg)
	
	if next (defs ["to_unqueue"] or {}) then
		for d, v in pairs (defs ["to_unqueue"]) do
			table.remove (defs [ctg], (system:getkey (defs [ctg], d) or #defs [ctg]+1))
			display.system ("Defense "..d.." Unqueued")
		end --for
		defs ["to_unqueue"] = {}
		defs ["to_unqueue"] = nil
	end --if
	
end --function


function defs:queue_unqueue (d)
	
	defs ["to_unqueue"] = defs ["to_unqueue"] or {}
	defs ["to_unqueue"] [d] = true
	
end --function
		

function defs:able_aura ()

	if prompt ["vitals"] ["c_mana"] >= 80 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("aura")
		return false
	end --if
	
end --function


function defs:able_limber ()

	if prompt ["vitals"] ["c_mana"] >= 500 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("limber")
		return false
	end --if
	
end --function


function defs:able_bracing ()

	if prompt ["vitals"] ["c_mana"] >= 350 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("bracing")
		return false
	end --if
	
end --function


function defs:able_screen ()

	if prompt ["vitals"] ["c_mana"] >= 200 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("screen")
		return false
	end --if
	
end --function


function defs:able_agility ()

	if prompt ["vitals"] ["c_mana"] >= 350 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("agility")
		return false
	end --if
	
end --function

function defs:able_deathsense ()

	if prompt ["vitals"] ["c_mana"] >= 50 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("deathsense")
		return false
	end --if
	
end --function


function defs:able_totem ()

	if prompt ["vitals"] ["c_mana"] >= 50 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("totems")
		return false
	end --if
	
end --function


function defs:able_thirdeye ()

	if prompt ["vitals"] ["c_mana"] >= 30 then
		return true
	else
		defs:queue_unqueue ("thirdeye")
		return false
	end --if
	
end --function


function defs:able_red ()

	if prompt ["vitals"] ["c_mana"] >= 100 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("red")
		return false
	end --if
	
end --function


function defs:able_blue ()

	if prompt ["vitals"] ["c_mana"] >= 175 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("blue")
		return false
	end --if
	
end --function


function defs:able_indigo ()

	if prompt ["vitals"] ["c_mana"] >= 105 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("indigo")
		return false
	end --if
	
end --function


function defs:able_balancing ()

	if prompt ["vitals"] ["c_mana"] >= 470 then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("balancing")
		return false
	end --if
	
end --function



function defs:able_vitality ()
	
	if
		prompt ["vitals"] ["c_mana"] >= prompt ["vitals"] ["max_mana"] and
		prompt ["vitals"] ["c_health"] >= prompt ["vitals"] ["max_health"] and
		prompt ["vitals"] ["c_ego"] >= prompt ["vitals"] ["max_ego"]
			then
		if bals:has ("bal") and bals:has ("eq") then
			return true
		else
			return false
		end --if
	else
		defs:queue_unqueue ("vitality")
		return false
	end --if
	
end --function


function defs:bdef (silent)

	self ["free"] = skills:get_defs ("free")
	self ["ubal"] = skills:get_defs ("ubal")
	self ["rbal"] = skills:get_defs ("rbal")
	
	local i = 1
	repeat
		if self ["current"] [self ["free"] [i]] then
			table.remove (self ["free"], i)
		else
			i=i+1
		end --if
	until (i>#self ["free"])

	local i = 1
	repeat
		if self ["current"] [self ["ubal"] [i]] then
			table.remove (self ["ubal"], i)
		else
			i=i+1
		end --if
	until (i>#self ["ubal"])
	
	local i = 1
	repeat
		if  self ["current"] [self ["rbal"] [i]] then
			table.remove (self ["rbal"], i)
		else
			i=i+1
		end --if
	until (i>#self ["rbal"])
		
	if
		wounds:get () or
		not parry:has (system ["settings"] ["default_parry"])
			then
		parry:init ()
	end --if
	
	if
		wounds:get () or
		not stance:has (system ["settings"] ["default_stance"])
			then
		stance:init ()
	end --if
		
		--getting the enchanted defs
	self:mdef ()
	
		--removing deathsense if I have deathsight
	if 	system:getkey (self ["ubal"], "deathsight") or
		defs:has ("deathsight")
			then
		local has_deathsense = system:getkey (self ["ubal"], "deathsense")
		if has_deathsense then
			table.remove (self ["ubal"], has_deathsense)
		end
	end --if
		
		--putting sturdiness last, since it gets cancelled when I loose balance
	local is_sturdiness = system:getkey (self ["ubal"], "sturdiness")
	if is_sturdiness then
		table.remove (self ["ubal"], is_sturdiness)
		table.insert (self ["ubal"], "sturdiness")
	end --if
	
	system:set_auto ("sparklies", 0, "silent")
	system:set_auto ("clot", 1, "silent")
	system:set_auto ("pipes_light", 1, "silent")
	system:set_auto ("speed", 1, "silent")
	system:set_auto ("kafe", 1, "silent")
	system:set_auto ("sixthsense", 1, "silent")
	system:set_auto ("truehearing", 1, "silent")
	system:set_auto ("waterbreathe", 1, "silent")
	system:set_auto ("waterwalk", 1, "silent")
	system:set_auto ("fire", 0, "silent")
	system:set_auto ("frost", 0, "silent")
	system:set_auto ("galvanism", 0, "silent")
	system:set_auto ("rebound", 0, "silent")
	system:set_auto ("insomnia", 1, "silent")
	system:set_auto ("orgpotion", 0, "silent")
	system:set_auto ("healing", 0, "silent")
	system:set_auto ("protection", 0, "silent")
	
	if not silent then
		display.system ("BASIC Defenses enabled")
	end --if
	
		--forcing a reaction
	if not sca:is_slowed () and IsConnected () then
		Send ("")
	end--if
	
end --function


function defs:fdef ()

	self:bdef ("silent")
	self:mdef ("silent")
	
	local is_sturdiness = system:getkey (self ["ubal"], "sturdiness")
	if is_sturdiness then
		table.remove (self ["ubal"], is_sturdiness)
		table.insert (self ["ubal"], "sturdiness")
	end --if
	
	if 	skills:is_available ("waterwalk") or
		magic:is_available ("waterwalk") 
			then
		system:set_auto ("waterwalk", 1, "silent")
	end--if
	if 	skills:is_available ("waterbreathe") or
		magic:is_available ("waterbreathe") 
			then
		system:set_auto ("waterbreathe", 1, "silent")
	end--if
	if skills:is_available ("selfishness") then
		system:set_auto ("selfishness", 1, "silent")
	end--if
	
	system:set_auto ("kafe", 1, "silent")
	system:set_auto ("hme", 1, "silent")
	system:set_auto ("sparklies", 1, "silent")
	system:set_auto ("clot", 1, "silent")
	system:set_auto ("pipes_light", 1, "silent")
	system:set_auto ("speed", 1, "silent")
	system:set_auto ("rebound", 1, "silent")
	system:set_auto ("insomnia", 1, "silent")
	system:set_auto ("sixthsense", 1, "silent")
	system:set_auto ("truehearing", 1, "silent")
	system:set_auto ("tea", 1, "silent")
	system:set_auto ("orgpotion", 0, "silent")
	if gear:has ("vials", "fire") then
		system:set_auto ("fire", 1, "silent")
	else
		display.system ("No Fire Vials Detected")
	end--if
	if gear:has ("vials", "frost") then
		system:set_auto ("frost", 1, "silent")
	else
		display.system ("No Frost Vials Detected")
	end--if
	if gear:has ("vials", "galvanism") then
		system:set_auto ("galvanism", 1, "silent")
	else
		display.system ("No Galvanism Vials Detected")
	end--if
	--system:set_auto ("protection", 1, "silent")
	system:set_auto ("healing", 1, "silent")
	--system:set_auto ("metawake", 1, "silent")
	system:set_settings ("allheale", 2)
	affs:add ("no_protection", true, "silent")
	
	display.system ("Full Defenses ENABLED")
	Execute ("sys set sparklies sparkleberry")--so I won't consume herb balance when eating them
	
end --function


function defs:mdef ()

	if system:is_enabled ("magic_defs") then
		if not defs:has ("mercy") and magic:is_available ("mercy") then
			table.insert (self ["rbal"], "mercy")
		end --if
		if not defs:has ("perfection") and magic:is_available ("perfection") then
			table.insert (self ["rbal"], "perfection")
		end --if
		if not defs:has ("beauty") and magic:is_available ("beauty") then
			table.insert (self ["rbal"], "beauty")
		end --if
		if not defs:has ("kingdom") and magic:is_available ("kingdom") then
			table.insert (self ["rbal"], "kingdom")
		end --if
		if
			not system:getkey (self ["ubal"], "levitate") and
			not defs:has ("levitate") and
			magic:is_available ("levitate")
				then
			table.insert (self ["ubal"], "levitate")
		end --if
		if
			not system:getkey (self ["ubal"], "acquisitio") and
			not defs:has ("acquisitio") and
			magic:is_available ("acquisitio")
				then
			table.insert (self ["ubal"], "acquisitio")
		end --if
		if
			not system:getkey (self ["ubal"], "waterbreathe") and
			not defs:has ("waterbreathe") and
			magic:is_available ("waterbreathe")
				then
			table.insert (self ["ubal"], "waterbreathe")
		end --if
		if
			not system:getkey (self ["ubal"], "waterwalk") and
			not defs:has ("waterwalk") and
			magic:is_available ("waterwalk")
				then
			table.insert (self ["ubal"], "waterwalk")
		end --if
		if
			not system:getkey (self ["ubal"], "deathsight") and
			not defs:has ("deathsight") and
			magic:is_available ("deathsight")
				then
			table.insert (self ["ubal"], "deathsight")
		end --if
	end --if
	
end --function
