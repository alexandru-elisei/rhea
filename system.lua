--[[
		MAIN SCRIPT FILE
		
		---WTF HAPPENS WHEN I GET STUNNED BEFORE THE CURE GOES THROUGH,
		IN AEON?
	
]]--

require "able"
require "pipes"
require "affs"
require "display"
require "act"
require "scan"
require "wounds"
require "flags"
require "nocure"
require "bals"
require "prompt"
require "fst"
require "defs"
require "magic"
require "todo"
require "parry"
require "offense"
require "serialize"
require "skills"
require "stance"
require "profile"
require "herbs"
require "sca"
require "calendar"
require "gear"
require "adven"--tracking of other adventurers, right now enemies/allies

my_nativity = {
  ["Sun"] = "Dolphin",
  ["Moon"] = "Burning Censer",
  ["Eroee"] = "Glacier",
  ["Sidiak"] = "Glacier",
  ["Tarox"] = "Bumblebee",
  ["Papaxi"] = "Antlers",
  ["Aapek"] = "Skull",}


if not system then
	system = {
		["exits"] = {},
		["targets"] = {},
		["last_cure"] = nil,
		["cure_queue"] = {},
		["hme_queues"] = {
			["health"] = {"health", "mana", "ego" },
			["mana"]   = {"mana", "health", "ego" },
			["ego"]    = {"ego", "health", "mana" },
			},
		["hme_threshold"] = {
			0.45, --threshold for health drinking (percentage)
			0.65,
			0.88,
			},
		["hme_afflictions"] = {
			"critical",
			"low",
			"med",
			},
		["settings"] = {},
		["auto"] = {},
		}
		
end --if


function system:init (silent)
	
	loadstring (GetVariable ("system_auto")) ()
	loadstring (GetVariable ("system_settings")) ()
	
	self ["auto"] = system_auto
	self ["settings"] = system_settings
	self ["hme_priority"] = GetVariable ("system_hme_priority")
	self ["targets"] [1] = GetVariable ("system_target")
	
	system_auto = {}
	system_auto = nil
	system_settings = {}
	system_settings = nil
	system_settings = nil
	
	skills:get_cures ("silent")
	self:update_info ()

--[[WTF]]--
	self ["settings"] ["weaponparry"] = true
	system:set_auto ("sting", 0, "silent")
	
	if self:is_auto ("rebound") then
		self:set_auto ("pipes_light", 1, "silent")
	end --if
	
	if self:is_auto ("pickup") then
		EnableTrigger ("getgold", true)
	else
		EnableTrigger ("getgold", false)
	end --if
	
	if self:is_auto ("bashing") then
		EnableTrigger ("ab_attack", true)
		EnableTrigger ("ab_killed", true)
	else
		EnableTrigger ("ab_attack", false)
		EnableTrigger ("ab_killed", false)
		todo:done ("bash", "bal")
	end --if
	
	if not silent then
		display.system ("System Initialized")
	end --if
	
end --function


function system:save ()

	system_auto = self ["auto"] or "system_auto = {}"
	SetVariable ("system_auto", serialize.save ("system_auto"))
	system_auto = {}
	system_auto = nil
	
	system_settings = self ["settings"] or "system_settings = {}"
	SetVariable ("system_settings", serialize.save ("system_settings"))
	system_settings = {}
	system_settings = nil
	
end --function


function system:on ()

	self:set_settings ("on", 1, "silent")
	self:update_info ()
	
	display.system ("System ON")
	prompt:del_alert ("sysoff")
	
end --function


function system:off (silent)

	self:set_settings ("on", 0, "silent")
	self:update_info ()
	
	if not silent then
		display.warning ("System OFF")
		prompt:add_alert ("sysoff", "<SYS OFF>", 20)
	end --if
	
end --function


function system:is_on ()

	return self ["settings"] ["on"] == 1
	
end --function


function system:set_auto (sOption, val, silent)

	sOption = string.gsub (sOption, " ","_")
	
	local unavailable
	local option = string.lower (sOption)
	local needs_magic = {
		["protection"] = true,
		["scroll"] = true,}
	local needs_skill = {
		["selfishness"] = true,
		["metawake"] = true,}
		
	if 	(option == "waterwalk" or option == "waterbreathe") and
		not magic:is_available (option) and
		not skills:is_available (option)
			then
		if 	(not val and system ["auto"] [option] == 0) or
			(val and val == 1)
				then
			self:set_auto (sOption, 0, true)
		end--if
		display.warning (sOption.." not available!")
		unavailable = true
	elseif needs_magic [option] and
		not magic:is_available (option) 
			then
		if 	(not val and system ["auto"] [option] == 0) or
			(val and val == 1)
				then
			self:set_auto (sOption, 0, true)
		end--if
		display.warning (sOption.." not available!")
		unavailable = true
	elseif  needs_skill [option] and
		not skills:is_available (option) 
			then
		if 	(not val and system ["auto"] [option] == 0) or
			(val and val == 1)
				then
			self:set_auto (sOption, 0, true)
		end--if
		display.warning (sOption.." not available!")
		unavailable = true
	elseif option == "parry" and not skills:is_available ("weaponparry") then
		if 	(not val and system ["auto"] [option] == 0) or
			(val and val == 1)
				then
			self:set_auto (sOption, 0, true)
		end--if
		display.warning (sOption.." not available!")
		unavailable = true
	end--if
	
	if not unavailable then
		if self ["auto"] [sOption] then
			val = tonumber (val)
			if val then
				if val >= 1 then
					val = 1
				else
					val = 0
				end --fi
				
				self ["auto"] [string.lower (sOption)] = val
				
				if not silent then
					display.auto (sOption, val)
				end --if
				
			else
				if self ["auto"] [sOption] == 1 then
					system:set_auto (sOption, 0, silent)
				else
					system:set_auto (sOption, 1, silent)
				end --if
				
				if
					system:is_auto ("medbag") and
					sOption == "medbag"
						then
					display.system ("Use the command 'system medbag_uses <uses>' to set the number of uses")
				end --if
				
				if
					system:is_auto ("wielding") and
					(not offense or not next (offense ["current"]))
						then
					display.warning ("You first need to detect your available weapons!")
					display.system ("Use 'ii wield' to detect your current weapons")
					system:set_auto ("wielding", 0)
				end --if
				
			end --if
		else
			display.error ("Auto Not Defined")
		end --if
	end--if
	
	if
		system:is_auto ("rebound") and
		sOption == "rebound" and --making sure I only see the message once
		not system:is_auto ("pipes_light")
			then
		system:set_auto ("pipes_light", 1, silent)
	end --if
	
	if sOption == "pipes_light" then
		pipes:scan ()
	end --if
	
	if self:is_auto ("bashing") then
		EnableTrigger ("ab_attack", true)
		EnableTrigger ("ab_killed", true)
	else
		EnableTrigger ("ab_attack", false)
		EnableTrigger ("ab_killed", false)
		todo:done ("bash", "bal")
	end --if
	
	if not system:is_auto ("sting") then
		affs:del ("no_sting")
		fst:disable ("no_sting")
	end--if
	
	self:save ()

end --function


function system:set_settings (sOption, val, silent)
	
	if
		sOption and
		val
			then
		sOption = string.lower (string.gsub (sOption, " ", "_"))
		val = tonumber (val) or val
		if sOption == "priority" then
			if
				val == "mana" or
				val == "ego" or
				val == "health"
					then
				self ["hme_priority"] = val
				SetVariable ("system_hme_priority", val)
				
				if not silent then
					display.option (sOption, val)
				end --if
			else
				display.warning ("ERROR - Healing priority can only be HEALTH, MANA OR EGO")
			end --function
		else
			if sOption == "rejecting" then
				if
					val ~= "none" and
					val ~= "all" and
					val ~= "enemies"
						then
					return display.warning ("You may only reject ENEMIES, ALL or NONE")
				end --if
				if val ~= "none" then
					affs:scan_lusted ()
				end --if
			end--if
			if sOption == "max_enemies" and val<30 then
				display.error ("Minimum Number of Enemies is 30")
				val = 30
			end--if
			self ["settings"] [sOption] = val			
			if not silent then
				display.option (sOption, val)
			end --if
		end --if
	else
		display.warning ("ERROR - no such setting/value")
	end --if
	
	self:save ()
	
end --function


function system:is_auto (sOption)

	result = false
	sOption = string.lower (string.gsub (sOption, " ","_"))
	
	if
		sOption and
		self ["auto"] [sOption] and
		self ["auto"] [sOption] == 1
			then
		result = true
	end --if
	
	return result
	
end --function


function system:is_enabled (sOption)

	sOption = string.lower (sOption)
	return 
		(self ["settings"] [sOption] and 
		self ["settings"] [sOption] ~= 0 and 
		self ["settings"] [sOption] ~= "0" and
		self ["settings"] [sOption] ~= false)
	
end --function


function system:get_settings (sOption) --returns the value of an option; digit

	return (self ["settings"] [string.lower (sOption)] or 0)
	
end --function


function system:login ()
	
	EnableTrigger ("login", false)
	EnableTrigger ("logout_stop", false)
	EnableTrigger ("logout", false)
	
	bals:reset ()
	affs:reset ()
	defs:reset ()
	flags:reset ()
	wounds:reset ()
	fst:reset ()
	prompt:unqueue ()
	todo:reset ()
	act:reset_inv ()
	self:update_info ()
	calendar:init ()
	Execute ("score")
	if not next (pipes ["current"]) then
		display.error ("CONFIGURE YOUR PIPES!")
	else
		pipes:set_unlit ("myrtle")
		pipes:set_unlit ("coltsfoot")
		pipes:set_unlit ("faeleaf")
		pipes:scan ()
	end --if
	SetVariable ("demon_power", "0")
	SetVariable ("demon_double", "0")
	SetVariable ("demon_lasthit", "-1")
	SetVariable ("demon_willhit", "0")
	
end -- function


function system:logout ()

	EnableTrigger ("logout", false)
	EnableTrigger ("logout_stop", true)
	EnableTrigger ("login", true)
	
end --function


function system:get_exits (dirs)
	
	if not dirs then
		system ["exits"] = {"none"}
		return system:update_info ()
	end --if
	
	local general_dirs = {["north"]=1, ["south"]=1, ["east"]=1, ["west"]=1, ["northeast"]=1, ["northwest"]=1, ["southeast"]=1, ["southwest"]=1, ["down"]=1, ["up"]=1}
	
	for w in string.gmatch (dirs, "%(?%a+%)?") do
		if w ~= "and" then
			table.insert (self ["exits"], w)
		end --if
	end --for
	
	for k, dir in ipairs (self ["exits"]) do
		if string.find (dir, "%(") then
			i=k
			repeat
				self ["exits"] [k-1] = self ["exits"] [k-1].." "..self ["exits"] [i]
				table.remove (self ["exits"], i)
				if string.find (self ["exits"] [k-1], "%)") then
					i = #self ["exits"] + 1
				end --if
			until (i > #self ["exits"])
		end --if
	end --for
		
	system:update_info ()

end --function


function system:update_info ()

	InfoClear ()
	InfoColour ("Blue")
	Info ("Target: ")
	InfoColour ("crimson")
	Info (GetVariable("system_target").."  ")
	InfoColour ("blue")
	Info ("Curing: ")
	if  self:is_on () then
		InfoColour ("lime")
		Info ("ON  ")
	else
		InfoColour ("crimson")
		Info ("OFF  ")
	end -- if
	InfoColour ("Blue")
	Info ("Exits: ")
	InfoColour ("crimson")
	if next (self ["exits"]) then
		for k, e in ipairs (self ["exits"]) do
			if  k<#self ["exits"] then
				Info (e..", ")
			else
				Info (e)
			end --if
		end --for
	end --if
	
end -- function


function system:cond (tName) --for conditional triggers, triggers which will be disabled at the next prompt
	
	if tName	then
		self ["conditional"] = self ["conditional"] or {}
		for k, n in ipairs (tName) do
			EnableGroup (n, true)
			self ["conditional"] [#self ["conditional"] +1] = n
		end -- for		
	elseif	self ["conditional"] then
		for k, g in ipairs (self ["conditional"]) do
			EnableGroup (g, false)
		end --for				
		self ["conditional"] = {}
		self ["conditional"] = nil
	end -- if

end -- function


function system:getkey (tName, sVal) --returns the position of a string record in a table, nil if isn't present
	
	for k,v in pairs (tName) do
		if  v == sVal then 
			return k
		end -- if
	end -- for
	
	return false

end -- function


function system:add_cure (cure)
	
	cure = string.gsub (cure, " ", "_")
	if system ["last_cure"] then
		return display.system ("Possible Illusion Detected - You Cannot Get Two Cures at Once!")
	else
		system ["last_cure"] = cure
		display.deb ("ACT:ADD_CURE -> "..cure)
	end --if
	
end --add_cure

	--adds a cure to the  cures queue; for blackout curing
function system:queue_cure (cure)
	
	cure = string.gsub (cure, " ", "_")
	if system:getkey (self ["cure_queue"], cure) then
		table.remove (self ["cure_queue"], system:getkey (self ["cure_queue"], cure))
	end --if
	self ["cure_queue"] [#self ["cure_queue"] +1] = cure
	
end--add_queue

	--removes a cure from the queue, when I've used it
function system:unqueue_cure (cure)

	if not cure then
		return display.error ("System:unqueue_cure -> Specify a cure!")
	end --if
	
	cure = string.gsub (cure, " ", "_")
	if system:getkey (self ["cure_queue"], cure) then
		system:del_cure ()
		table.remove (self ["cure_queue"], system:getkey (self ["cure_queue"], cure))
	end --if

end --unqueue_cure


function system:is_curing ()

	return system ["last_cure"]
	
end --function


function system:del_cure (cure)
	
	system ["last_cure"] = nil
	
end --del_cure


local function can_eat_now ()

	if 
		bals:get ("elixir")==0.5 and 
		not string.find (flags:get ("applying_salve") or "nil", "apply_health_to_") 
			then 
		fst:fire ("elixir", "now") 
	end--if
	if 
		bals:get ("herb")==0.5 and 
		not flags:get ("smoking") and 
		not string.find (flags:get ("applying_salve") or "nil", "apply_arnica_to_") 
			then 
		fst:fire ("herb", "now")
	end
	if
		bals:get ("speed") == 0.5 and
		(flags:get ("no_speed") or "nil") == "drink_quicksilver"
			then
		fst:fire ("speed", "now")
	end --if
	if bals:get ("purg")==0.5 then fst:fire ("purg", "now")end
	if bals:get ("sparklies") ==0.5 then fst:fire ("sparklies", "now") end
	if flags:get ("orgpotion") then fst:fire ("orgpotion", "now") end
	if bals:get ("brew") == 0.5 then fst:fire ("brew", "now") end
	if bals:get ("ah") ==0.5 then fst:fire ("ah", "now") end
	
end --can_eat_now


function system:cured (sAff, arg1)
	
	if affs:get_cure ("writhe", sAff) then
		system:cured_writhe (sAff, arg1)
	elseif system ["cured_"..sAff] then
		system ["cured_"..sAff] (self, arg1)
	else
		system:cured_simple (sAff, arg1)
	end --if
	
end --function


function system:cured_simple (sAff, silent)
	
	if not silent then
		display.cured (sAff)
	end --if
		--afflictions cured by focus body gain focus balance when they are cured
	if sAff == "paralysis" or sAff == "leglock" or sAff == "throatlock" then
		system:unqueue_cure ("focus_body")
		bals:onbal ("focus", "silent")
--[[blackout curing]]
	elseif affs:has ("blackout") then
			--regeneration is dealt with separately
		local cure = affs:get_cure ("salve", sAff)
		if cure and string.find (cure, "regeneration") then
			system:unqueue_cure (cure)
			local part = string.sub (cure, 23)
			flags:del_check ("regenerating_"..part)
			fst:disable ("apply_regeneration_to_"..part)
			local aff = flags:is_sent (cure)--what I actually wanted to cure
			flags:del (aff)
			if string.find ((aff or "nil"), "custom_") then
				affs:del_custom (cure)
			end --if
				--even in blackout, I see the allheale/powercure message exactly before the cured message
			if 	(system:is_curing () or "nil") == "powercure" or
				(system:is_curing () or "nil") == "drink_allheale"
					then
				system:del_cure ()
			end --if
				--finding the first cure sent that might have cured the affliction
		else
			if next (system ["cure_queue"]) then--if I have a cure stored
				for k, c in ipairs (system ["cure_queue"]) do--I parse the last cures table
					if affs:is_cure (c, affs:get_bal (c), sAff) then
						cure = c
						break --I stop when I find the first thing that might have cured the affliction
					end --if
				end --for
			end --if
				--if there is such a thing
			if cure then
				system:unqueue_cure (cure)
					--taking care of balances
				if cure == "drink_quicksilver" then
					bals:onbal ("speed", "silent")
				else
					bals:offbal (affs:get_bal (cure), "silent") --I loose the balance; also disable the fst_timers;enable the gn_ timers
				end --if
				
				local aff = flags:is_sent (cure)
				if string.find ((aff or "nil"), "custom_") then
					affs:del_custom (cure)
				end --if
				
				if string.find (cure, "smoke") then
					pipes:smoking ()
				end --if
				
				system:del_cure ()
			end --if
		end --if
--[[normal curing]]
	else--normal curing
		local cure = affs:get_cure ("salve", sAff)
			--taking care of regeneration
		if cure and string.find (cure, "regeneration") then
			system:unqueue_cure (cure)
			local part = string.sub (cure, 23)
			flags:del_check ("regenerating_"..part)
			fst:disable ("apply_regeneration_to_"..part)
			local aff = flags:is_sent (cure)--what I actually wanted to cure
			flags:del (aff)
			if string.find ((aff or "nil"), "custom_") then
				affs:del_custom (cure)
			end --if
			if 	(system:is_curing () or "nil") == "powercure" or
				(system:is_curing () or "nil") == "drink_allheale"
					then
				system:del_cure ()
			end --if
				--finding the cure I used right before the affliction got cured
		else
			cure = system:is_curing ()
			if cure then	
				system:unqueue_cure (cure)
				local aff = flags:is_sent (cure)--what I actually wanted to cure
				local bal = affs:get_bal (cure)--same here
				if bal and affs:is_cure (cure, bal, sAff) then
					if cure == "drink_quicksilver" then
						bals:onbal ("speed", "silent")
					else
						bals:offbal (bal, "silent")
					end --if
				else
					display.system ("Possible Illusion - "..cure.." Isn't a Cure for "..sAff)
				end --if
				if string.find ((aff or "nil"), "custom_") then
					affs:del_custom (cure)
				end --if
				flags:del (aff)
					--if I don't have such a cure, and I was forced to smoke
			elseif flags:get ("forced_smoking") then --to track puffs in case of forced smoking
				local has_smoked = affs:get_cure ("herb", sAff)
				if has_smoked and string.find (has_smoked, "smoke") then
					has_smoked = string.sub (has_smoked, 7)
					pipes:smoking (has_smoked)
				end--if
			end --if
			system:del_cure ()
		end --if
	end --if
		--deleting the afflictions, also making sure I check for removing of masked afflictions
	affs:del (sAff, "cured")
		--in blackout, you don't see the curing actions, just the afflictions getting cured
	if flags:get ("curing") then
		sca:check ()
	end --if
	
end--cured_simple


function system:cured_queue (sAff, arg1, arg2)
	
	prompt:queue (function () system:cured (sAff, arg1, arg2) end, "cured_"..sAff, true)
	
end --function


function system:cured_prone ()
	
	if (flags:get ("curing") or "nil")=="prone" then
		sca:check ()
	end --if
	display.free ()
	affs:del ("prone")
	fst:disable ("prone")
	flags:add_check ("cured_prone")
	
end --if


function system:cured_health (cure) --I pass what cured health

	--[[
	if cure == "medbag_touch" then
		system ["settings"] ["medbag_uses"] = system:get_settings ("medbag_uses")-1
	end --if
	--]]

	if affs ["vessels"]>0 then--if I have vessels
		affs:vessel (-1)
		flags:del ({"vessels_critical", "vessels_low", "vessels_med"})
	end --if
		--in blackout I keep the affliction
	if affs:has ("blackout") then
		for k, aff in ipairs (self ["hme_afflictions"]) do
			flags:del ("health_"..aff)
		end --for
		system:unqueue_cure ("drink_health")
	else
		for k, aff in ipairs (self ["hme_afflictions"]) do
			affs:del ("health_"..aff)
		end --for
	end --if
	if flags:get ("curing") then
		sca:check ()
	end --if
	system:del_cure ()
	bals:offbal ("elixir", "silent")
	display.cured ("health")
	
end --function
		

function system:cured_mana ()
	
	if affs:has ("blackout") then
		for k, aff in ipairs (self ["hme_afflictions"]) do
			flags:del ("mana_"..aff)
		end --for
		system:unqueue_cure ("drink_mana")
	else
		for k, aff in ipairs (self ["hme_afflictions"]) do
			affs:del ("mana_"..aff)
		end --for
	end --if
	if flags:get ("curing") then
		sca:check ()
	end --if
	system:del_cure ()
	bals:offbal ("elixir", "silent")
	display.cured ("mana")
	
end --function


function system:cured_ego ()
	
	if affs:has ("blackout") then
		for k, aff in ipairs (self ["hme_afflictions"]) do
			flags:del ("ego_"..aff)
		end --for
		system:unqueue_cure ("drink_ego")
	else
		for k, aff in ipairs (self ["hme_afflictions"]) do
			affs:del ("ego_"..aff)
		end --for
	end --if
	if flags:get ("curing") then
		sca:check ()
	end --if
	system:del_cure ()
	bals:offbal ("elixir", "silent")
	display.cured ("ego")
	
end --function
	

function system:cured_sparklies ()

	if affs ["vessels"]>0 then--if I have vessels
		affs:vessel (-1)
		flags:del ({"vessels_critical", "vessels_low", "vessels_med"})
	end --if
	if flags:get ("curing") then
		sca:check ()
	end --if
	if (system:get_settings ("sparklies") or "sparkleberry") ~= "sparkleberry" then
		if (system:is_curing () or "") ~= "sparkleberry" then
			local cure = system:is_curing ()
			system:unqueue_cure (cure)
			local aff = flags:is_sent (cure)--what I actually wanted to cure
			bals:offbal ("herb", "silent")
			if string.find ((aff or "nil"), "custom_") then
				affs:del_custom (cure)
			end --if
			flags:del (aff)
		end
	end
	system:del_cure ()
	flags:del ("sparklies")
	bals:offbal ("sparklies", true)
	display.cured ("sparklies")
	
end --function


function system:cured_bleeding () --it only applies to clotting

	EnableTrigger ("clotcontinue", false)
	EnableTrigger ("clotstop", false)
	
	flags:del ("clotting")
	fst:disable ("clotting")
	if flags:get ("curing") then
		sca:check ()
	end --if
	for aff, val in pairs (affs ["current"]) do --I might delete the affliction in the bleeding function, if the bleeding gets below 40
		if string.find (aff, "bleeding_") then
			affs:del (aff)
			break
		end --if
	end --for		
	
end --function


function system:cured_clot (bodypart) --bodypart will be leftarm/leftleg, and so on
	
	local cn=affs ["clots"] ["number"]
	system:cured_simple ("clot_"..tostring (cn), "silent")
	display.cured ("clot "..bodypart.." ("..tostring (cn-1).." clots remaining)")
	
	affs ["clots"] [bodypart] = nil
	if cn>1 then
		affs ["clots"] ["number"] = cn-1
		affs:add ("clot_"..tostring (cn-1))
	end--if
	
end --function


function system:cured_lacerated (part)

	system:cured_simple ("lacerated_1", "silent")
	display.cured ("lacerated "..part)
	affs:lacerated (part, true)
	
end --function


function system:cured_artery (part)

	local has
	if next (affs.current) then
		for n, v in pairs (affs.current) do
			if string.find (n, "artery_") then
				system:cured_simple (n, "silent")
				has = true
				break
			end--if
		end--for
	end--if
	
	if not has then
		system:cured_simple ("artery_1", "silent")
	end--if
	
	display.cured ("artery "..part)
	affs:artery (part, true)
	
end --function


function system:cured_aeon ()
	
	EnableTrigger ("prompt_aeon", false)
	
	flags:del_check ({"slowed", "reset_bals"})
	if flags:is_sent ("drink_phlegmatic") or flags:get ("adrenaline") then
		system:cured_simple ("aeon")
	else
		affs:del ("aeon")
		display.cured ("aeon")
	end --if
	display.free ()
	
end --function

	--to test
function system:cured_sap ()
	
	EnableTrigger ("prompt_sap", false)
	affs:del ("sap")
	fst:disable ("sca")
	flags:del ("curing")
	flags:del_check ({"slowed", "reset_bals"})
	display.free ()
	
end --function
	

function system:cured_asleep ()

	EnableTriggerGroup ("System_Awaken", false)
	if flags:get ("curing") then
		sca:check ()
	end --if
	fst:autofire ()
	affs:del ("asleep")
	fst:disable ("asleep")
	if defs:has ("insomnia") then
		defs:lostdef ("insomnia")
	end --if
	display.cured ("asleep")
	display.free ()

end --function


function system:cured_numb (part)

	if not part then
		return display.warning ("CURED_NUMB -> requires a bodypart!")
	end --if
	
	part = string.gsub (part, " ", "")
	system:cured_simple ("numb_"..part)
	affs:numb (part, nil, true)
	
end --function


function system:cured_slickness ()
	
	system:cured_simple ("slickness")
	if flags:get ("applying") then
		if string.find (flags:get ("applying"), "health") then 
			fst:fire ("elixir", "now")
		else 
			fst:fire ("salve", "now")
		end--if
	else
		local aff, cure = flags:bals_try ("herb")
		if string.find ((cure or "nil"), "apply_arnica_to_") then
			fst:fire ("herb", "now")
		end --if
	end--if

end --function


function system:cured_anorexia ()
	
	system:cured_simple ("anorexia")
	can_eat_now ()

end --if


function system:cured_slitthroat ()

	system:cured_simple ("slitthroat")
	can_eat_now ()
	
end --cured_slitthroat


function system:cured_windpipe ()

	system:cured_simple ("windpipe")
	can_eat_now ()
	
end --function


function system:cured_confusion ()
	
	system:cured_simple ("confusion")
	if flags:get ("disrupted") then
		fst:fire ("disrupted", "now")
	end --if
	
end --cured_confusion


function system:cured_stun (silent)

	fst:autofire ()
	affs:del ("stun")
	fst:disable ("stun")
	
	if not silent then
		display.cured ("stun")
		display.free ()
	end --if
	
end --function


function system:cured_blackout ()
	
	if affs:has ("blackout") then
	
			--if I cured blackout with a power cure, in sca
		if 	(flags:get ("powercure") or (system:is_curing () or "nil") == "drink_allheale")
			and flags:get ("curing") 
				then
			sca:check ()
		end --if
		affs:del ("blackout")
		display.cured ("blackout")
		affs:add ("disrupted")
		system:del_cure ()
		system:unqueue_cure ("drink_allheale")
		affs:masked (2)
		display.free ()
		flags:del_check ({"vapors", "reset_hme"})
		if system:is_auto ("healing") then
			todo:add ("free", "recharge", "recharge "..magic:get_id ("healing").." from cube", nil, true)
		end --if
		EnableTriggerGroup ("System_Blackout", false)
		EnableTriggerGroup ("System_Cures", false)
		EnableTrigger ("kata_form", false)
	end --if
	
end --function


function system:cured_writhe (aff, special)
	
	--[[
	EnableTriggerGroup ("System_WStart", false)
	EnableTriggerGroup ("System_WContinue", false)
	EnableTriggerGroup ("System_WNocure", false)
	]]--
	
	affs:del (aff)
	flags:del ("writhing")
	flags:del ("writhing_start")
	fst:disable ("writhing")
	
	if aff == "grappled" and special then
		affs:grappled (nil, special)
	end --if
	
	display.cured (aff)
	
end --function


function system:cured_narcolepsy ()

	system:cured_simple ("narcolepsy")
	if flags:get ("no_insomnia") then
		fst:fire ("no_insomnia", "now")
	end --if
	
end --cured_narcolepsy

function system:cured_hypersomnia ()

	system:cured_simple ("hypersomnia")
	if flags:get ("no_insomnia") then
		fst:fire ("no_insomnia", "now")
	end --if
	
end --cured_narcolepsy


function system:cured_coils ()

	system:cured_simple ("coils_1", "silent")
	affs:add ("coil", -1)
	
	display.cured ("coils")
	
end --function


function system:cures_on ()

	EnableTriggerGroup ("System_Cures", true)
	prompt:queue (function () EnableTriggerGroup ("System_Cures", false)end, "cures_on")
	
	display.deb ("SYSTEM:CURES_ON -> waiting for cure")
	
end --function


function system:poisons_on ()

	EnableTriggerGroup ("System_Poisons", true)
	prompt:queue (function () EnableTriggerGroup ("System_Poisons", false)end, "poisons_on")
	
	display.deb ("SYSTEM:POISONS_ON -> poisons enabled")
	
end --function


function system:check_limbs (limbs, side)

		-- Check conditions on arms or legs?
	local limb = string.sub (limbs, 1, 3)
	if side then
		if affs:condition (side..limb) == "unhealthy" or
			affs ["grapples"] [side..limb]
				then
			return
		end--if
	elseif affs:condition ("left"..limb) == "unhealthy" or
			affs:condition ("right"..limb) == "unhealthy" or
			affs ["grapples"] ["left"..limb] or
			affs ["grapples"] ["right"..limb]
				then
			return
	end--if
	
	affs:masked (1)
	if side then
		affs:add ("broken_"..side..limb)
	else
		affs:add ("broken_right"..limb)
	end--if
		
end --function


function system:install ()

	if not io then
		return display.warning ("Disk I/O is disabled in the Lua sandbox")
	end
	
	local triggers = {
		"affs",
		"aetherhunt",
		"bashing",
		"calendar",
		"combat",
		"cures",
		"def",
		"defs",
		"diag",
		"ent",
		"gear",
		"pipel",
		"poisons",
		"tracking",
		"pipel",
		"skills",
		"wounds",
		"herbs",
		"interface",
	}
	
	DeleteGroup ("System_Interface")
	DeleteGroup ("System_Acrobatics")
	DeleteGroup ("System_Aetherhunt")
	DeleteGroup ("System_Arena")
	DeleteGroup ("System_Athletics")
	DeleteGroup ("System_Awaken")
	DeleteGroup ("System_Bashing")
	DeleteGroup ("System_Blackout")
	DeleteGroup ("System_Calendar")
	DeleteGroup ("System_Cleanse")
	DeleteGroup ("System_Combat")
	DeleteGroup ("System_Cures")
	DeleteGroup ("System_Def")
	DeleteGroup ("System_Defs")
	DeleteGroup ("System_Diag")
	DeleteGroup ("System_Eating")
	DeleteGroup ("System_Ent")
	DeleteGroup ("System_Focus")
	DeleteGroup ("System_Gear")
	DeleteGroup ("System_Herbs")
	DeleteGroup ("System_Kata")
	DeleteGroup ("System_Knighthood")
	DeleteGroup ("System_Lowmagic")
	DeleteGroup ("System_MagicRecharge")
	DeleteGroup ("System_Moon")
	DeleteGroup ("System_Ninjakari")
	DeleteGroup ("System_NinjakariMods")
	DeleteGroup ("System_Parry_Check")
	DeleteGroup ("System_Pipel")
	DeleteGroup ("System_Poisons")
	DeleteGroup ("System_Prompt")
	DeleteGroup ("System_Rainbows")
	DeleteGroup ("System_ShofangiMods")
	DeleteGroup ("System_Skills")
	DeleteGroup ("System_Stealth")
	DeleteGroup ("System_TahtetsoMods")
	DeleteGroup ("System_Tracking")
	DeleteGroup ("System_Voting")
	DeleteGroup ("System_WContinue")
	DeleteGroup ("System_WNocure")
	DeleteGroup ("System_Wounds")
	DeleteGroup ("System_WoundStatus")
	DeleteGroup ("System_WStart")
	
	
	DeleteGroup ("System_SEG")
	
	
	ChangeDir(GetInfo(68))

	local xml
		-- Import all 
	for k,s in ipairs (triggers) do
		io.input ("system_" .. s .. ".xml")
		xml = io.read ("*all")
		ImportXML(xml)
	end
	
	display.system ("Installed")
	Execute ("sys set skills")
end --function


function system:died ()

	bals:reset ()
	if defs:has ("tea") then
		bals:offbal ("brew")
	end--if
	affs:reset ()
	defs:reset ()
	flags:reset ()--this resets the check for dead too
	wounds:reset ()
	fst:reset ()
	prompt:unqueue ()
	todo:reset ()
	act:reset_inv ()
	prompt:del_alert ("sluggish")--I treat sluggish like an alert, instead of like an affliction
	
	flags:add_check ("dead")--enabling check
	system ["dead"] = true
	display.system ("Death Confirmed")
	
	system:set_auto ("waterwalk", 0)
	system:set_auto ("waterbreathe", 0)
	system:set_auto ("selfishness", 0)
	system:set_auto ("metawake", 0)
	system:set_auto ("bashing", 0)

end --function


function system:is_dead ()

	return system ["dead"]
	
end --function


function system:alive ()

	system:on ()--resume curing
	system ["dead"] = nil--not dead
	display.free ()
	
end--function

function system:arena_done ()

	if flags:get_check ("arena") then
		prompt:queue (function ()
			if flags:get_check ("reset_defs") then
			  defs:reset ("silent")
			else
			  defs:lostdef("insomnia")
			end
			affs:reset ("silent")
			bals:reset ("silent")
			flags:reset ("silent")
			todo:reset ("silent")
			wounds:reset ("silent")
			offense ["feeds"] = {}
			prompt:del_alert ("unconscious")
			offense:passive ()
			display.system ("Arena Mode Disabled")
			EnableTriggerGroup ("System_Arena", false)
		end, "arena_end")
	end--if

end--arena_done


function system:show_autos ()

	display.system ("Current Autos:")
	Note ()
	if next (system.auto) then
		local sorted_autos = {}
			--sorting the autos to be able to search through them easily
		for name, value in pairs (system.auto) do
			table.insert (sorted_autos, name)
		end --for
		table.sort (sorted_autos)
			--I'm going to show them in two columns, and the options from each column will be displayed alphabetically
		local column_autos = {}
		local mid = math.ceil (#sorted_autos/2)
		for i=1,mid do
			column_autos [i] = {}
			if sorted_autos [i+mid] then
				column_autos [i] ={sorted_autos [i], sorted_autos[i+mid]}
			else --if I have an odd number of option
				column_autos [i]={sorted_autos[i]}
			end--if
		end--for
		len = 16
		for k, v in ipairs (column_autos) do
			ColourTell ("white", "", "   "..string.upper (string.sub (v[1], 1,1))..string.lower(string.sub (v[1], 2))..
							string.rep (".", len-#v[1]-3))
			ColourTell ("aqua", "", "[")
			if self:is_auto (v[1]) then
				ColourTell ("red", "", "x")
			else
				ColourTell ("", "", " ")
			end--if
			if v[2] then
				ColourTell ("aqua", "", "]"..string.rep (" ", 50-2*(len+6)))
				ColourTell ("white", "", "   "..string.upper (string.sub (v[2], 1,1))..string.lower(string.sub (v[2], 2))..
							string.rep (".", len-#v[2]-3))
				ColourTell ("aqua", "", "[")
				if self:is_auto (v[2]) then
					ColourTell ("red", "", "x")
				else
					ColourTell ("", "", " ")
				end--if
			end--if
			ColourNote ("aqua", "", "]")
		end--for
		Note ()
	end--if
	
end --show_autos


function system:show_settings ()
		
		--see above for comments
	display.system ("Current Settings:")
	Note ()
	if next (system.settings) then
		local sorted_settings = {}
		for name, value in pairs (system.settings) do
			table.insert (sorted_settings, name)
		end --for
		table.sort (sorted_settings)
		local column_settings = {}
		local mid = math.ceil (#sorted_settings/2)
		for i=1,mid do
			column_settings [i] = {}
			if sorted_settings [i+mid] then
				column_settings [i] ={sorted_settings [i], sorted_settings[i+mid]}
			else
				column_settings [i]={sorted_settings[i]}
			end--if
		end--for
		len = 20
		vlen = 12
		for k, v in ipairs (column_settings) do
			ColourTell ("white", "", "   "..string.upper (string.sub (v[1], 1,1))..string.lower(string.sub (v[1], 2))..
							string.rep (".", len-#v[1]-3))
			local value = system ["settings"] [v[1]]
			if value then
				if value == 1 or value == "1" then
					value = true
				end--if
				ColourTell ("aqua", "", "["..string.rep (" ", math.floor((vlen-string.len(tostring(value)))/2)))
				if value == 0 or value == "0" or value == "off" or value == "false" then
					ColourTell ("red", "", tostring(value))
				else
					ColourTell ("green", "", tostring (value))
				end--if
			else
				ColourTell ("", "", string.rep (" ",vlen))
				value = "123456789123"
			end--if
			ColourTell ("aqua", "", string.rep (" ", vlen-math.floor((vlen-string.len(tostring(value)))/2)-string.len(tostring(value))).."]")
			if v[2] then
				ColourTell ("", "", string.rep (" ", 50-2*(len+vlen+6)))
				ColourTell ("white", "", "   "..string.upper (string.sub (v[2], 1,1))..string.lower(string.sub (v[2], 2))..
							string.rep (".", len-#v[2]-3))
				local value = system ["settings"] [v[2]]
				if value then
					if value == 1 or value == "1" then
						value = true
					end--if
					ColourTell ("aqua", "", "["..string.rep (" ", math.floor((vlen-string.len(tostring(value)))/2)))
					if value == 0 or value == "0" or value == "off" or value == "false" then
						ColourTell ("red", "", tostring(value))
					else
						ColourTell ("green", "", tostring (value))
					end--if
				else
					ColourTell ("", "", string.rep (" ",vlen))
					value = "123456789123"
				end--if
				ColourTell ("aqua", "", string.rep (" ", vlen-math.floor((vlen-string.len(tostring(value)))/2)-string.len(tostring(value))).."]")
			end--if
			Note ()
		end--for
		Note ()
	end--if
	
end --show_settings


system:init ()


return system