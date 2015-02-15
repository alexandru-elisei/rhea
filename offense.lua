--[[
		offenseING SCRIPTS

		TO DO SOMETHING ABOUT RAZING SOMEONE WHO HAS MORE THAN ONE REBOUND
		FIXED IN OFFENSE:EXEC
]]--


require "serialize"

if not offense then
	offense = {
		["rebounds"] = {},
		["casters"] = {},
		["powers"] = {},
		["pacts"] = {
			["Gorgulu"] = {
				["darksilver"] = true,
				["rigormortis"] = true,
				["worms"] = true,
				["scabies"] = true,
				["anorexia"] = true,},
			["Nifilhema"] = {
				["masochism"] = true,
				["sensitivity"] = true,
				["bleeding"] = true,
				["shackles"] = true,
				["hemiplegy"] = true,},
			["Baalphegar"] = {
				["paranoia"] = true,
				["stupidity"] = true,
				["confusion"] = true,
				["epilepsy"] = true,
				["dementia"] = true,},
			["Ashtorath"] = {
				["impatience"] = true,
				["loneliness"] = true,
				["recklessness"] = true,
				["flame"] = true,
				["crunch"] = true,},
			["Luciphage"] = {
				["dominate"] = true,
				["paralysis"] = true,
				["powersink"] = true,
				["healthleech"] = true,
				["amnesia"] = true,},
		}
	}
end --if

local function setattackkeys ()
	
--[[BASIC ATTACKS]]--
	AcceleratorTo ("F1", "Send ('evoke pentagram')", 12)
	AcceleratorTo ("ALT + F1", "Send ('abjure timeslip')", 12)
	AcceleratorTo ("CTRL + F1", "Send ('evoke pentagram psi')", 12)
	AcceleratorTo ("F2", "offense:exec ('attack', 'bash')", 12)
	AcceleratorTo ("CTRL+F2", "offense:exec ('powah', {'abjure cosmicfire', 'target'})", 12)
	AcceleratorTo ("F3", "if system:is_auto ('sting') then system:set_auto ('sting', false) else system:set_auto ('sting', true)end ", 12)
	AcceleratorTo ("CTRL + F3", "system:set_auto ('bashing')\nSend ('')", 12)
	AcceleratorTo ("F4", "offense:exec ('raze', {'evoke void', 'target'})", 12)

--[[PVP AFFS]]--
	AcceleratorTo ("F5", "offense:exec ('powah', {'chant carcer'})", 12)
	AcceleratorTo ("CTRL + F5", "SendNoEcho ('outd fall') offense:exec ('powah', {'fling fall at ground'})", 12)
	AcceleratorTo ("F6", "offense:exec ('powah', {'darkchant feed', 'target'})", 12)
	AcceleratorTo ("F7", "offense:exec ('powah', {'darkchant leech', 'target'})", 12)
	AcceleratorTo ("CTRL + F7", "SendNoEcho ('outd dreamer') offense:exec ('powah', {'fling dreamer at', 'target'})", 12)
	AcceleratorTo ("ALT + F7", "offense:exec ('powah', {'chant amissio', 'target'})", 12)
	AcceleratorTo ("F8", "offense:exec ('powah', {'darkchant crucify', 'target'})", 12)
	AcceleratorTo ("CTRL + F8", "offense:exec ('powah', {'darkchant shrivel', 'target'})", 12)
	AcceleratorTo ("F9", "offense:exec ('powah', {'darkchant sacrifice', 'target'})", 12)
	AcceleratorTo ("CTRL + F9", "offense:exec ('powah', {'darkcall harrow'}) EnableTrigger ('demon_harrow', true)", 12)
	AcceleratorTo ("CTRL + SHIFT + F9", "offense:exec ('powah', {'darkcall scourge'})", 12)
	AcceleratorTo ("F10", "offense:exec ('powah', {'darkchant ectoplasm', 'target'})", 12)
	AcceleratorTo ("CTRL + F10", "offense:exec ('powah', {'darkchant ectoplasm'})", 12)
	AcceleratorTo ("ALT + F10", "offense:exec ('powah', {'darkchant ectoplasm all'})", 12)
	AcceleratorTo ("F11", "offense:exec ('powah', {'breathe contagion'})", 12)
	AcceleratorTo ("F12", "offense:exec ('powah', {'darkcall wrack', 'target'})", 12)
	AcceleratorTo ("CTRL + F12", "offense:exec ('powah', {'darkcall torture', 'target'})", 12)
	AcceleratorTo ("CTRL + SHIFT + F12", "Send ('contemplate '..GetVariable ('system_target')) EnableTrigger ('contemplating_wrack', true)", 12)
	
--[[ABILITIES AND -SPECIAL- FORMS]]--
	AcceleratorTo ("CTRL + [", "offense:exec ('powah', {'darkchant omen', 'target'})", 12)
	AcceleratorTo ("CTRL + SHIFT + [", "offense:exec ('powah', {'darkchant disfigure', 'target'})", 12)
	AcceleratorTo ("CTRL + ]", "if defs:has ('putrefaction') then Send ('solidify') else Send ('darkchant putrefaction') end", 12)
	AcceleratorTo ("CTRL + U", "if defs:has ('coldaura') then Send ('coldaura off') else Send ('coldaura on') end", 12)
	AcceleratorTo ("CTRL + G", "if defs:has ('ghost') then Send ('nativeform') else Send ('darkchant ghost') end", 12)--TO DEAL WITH THIS IN CASE OF CHOKE SYNC
	AcceleratorTo ("CTRL + H", "offense:exec ('powah', {'evoke hexagram', 'target'})", 12)--TO DEAL WITH THIS IN CASE OF CHOKE SYNC
	AcceleratorTo ("CTRL + S", "offense:exec ('powah', {'shieldstun', 'target'})", 12)
	AcceleratorTo ("CTRL + ALT + SHIFT + S", "Send ('darkcall thrall dismiss') EnableTrigger ('demon_dismiss' , true)", 12)
	AcceleratorTo ("CTRL + SHIFT + S", "Send ('darkcall thrall') EnableTrigger ('demon_summon')", 12)
	AcceleratorTo ("CTRL + J", "offense:exec ('powah', {'chant conjuctio', 'target'})", 12)
	AcceleratorTo ("CTRL + A", "offense:exec ('powah', 'aggressify')", 12)
	AcceleratorTo ("CTRL + SHIFT + A", "offense:exec ('powah', 'passify')", 12)
	AcceleratorTo ("CTRL + T", "offense:exec ('powah', {'touch', 'target'})", 12)
	AcceleratorTo ("CTRL + L", "offense:exec ('powah', {'abjure sleep', 'target'})", 12)
	AcceleratorTo ("CTRL + Q", "offense:exec ('powah', {'abjure quickening'})", 12)
	AcceleratorTo ("CTRL + F", "offense:exec ('powah', {'abjure fear'})", 12)
	AcceleratorTo ("CTRL + M", "offense:exec ('powah', {'deathmark place', 'target'})", 12)
	AcceleratorTo ("CTRL + D", "offense:exec ('powah', {'darkchant drain', 'target'})", 12)
	AcceleratorTo ("CTRL + B", "if skills:is_available ('web') then offense:exec ('powah', {'abjure web', 'target'}) else magic:use ('web') end", 12)
	AcceleratorTo ("CTRL + K", "offense:exec ('powah', {'darkcall beckon', 'target'})", 12)
	AcceleratorTo ("CTRL +SHIFT + K", "offense:exec ('powah', {'darkcall beckon'})", 12)
	AcceleratorTo ("CTRL + W", "offense:exec ('powah', {'darkcall spawn', 'target'})", 12)
	AcceleratorTo ("CTRL + E", "SendNoEcho ('outd hangedman') offense:exec ('powah', {'fling hangedman', 'target'})", 12)
	AcceleratorTo ("CTRL + ;", "offense:exec ('powah', 'soulless_rub')", 12)
	AcceleratorTo ("CTRL + SHIFT + ;", "Execute ('sniff soulless') EnableTrigger ('soulless_sniff', true)", 12)
	AcceleratorTo ("CTRL + '", "offense:exec ('powah', 'soulless_fling')", 12)
	AcceleratorTo ("CTRL + ,", "SendNoEcho ('outd aeon') offense:exec ('powah', {'fling aeon at', 'target'})", 12)
	AcceleratorTo ("CTRL + SHIFT + ,", "SendNoEcho ('outd fool') offense:exec ('powah', {'fling fool at ground'})", 12)
	AcceleratorTo ("CTRL + /", "SendNoEcho ('outd empress') offense:exec ('powah', {'fling empress at', 'target'})", 12)
	AcceleratorTo ("CTRL + SHIFT + /", "SendNoEcho ('outd lust') offense:exec ('powah', {'fling lust at', 'target'})", 12)
	AcceleratorTo ("CTRL + .", "SendNoEcho ('outd dreamer') offense:exec ('powah', {'fling dreamer at', 'target'})", 12)
	AcceleratorTo ("CTRL + Y", "Execute ('fling hermit at ground')", 12)
	AcceleratorTo ("CTRL + SHIFT + Y", "Execute ('darkcall syphon')", 12)
	AcceleratorTo ("CTRL + ALT + R", "Send ('refresh power')", 12)
	AcceleratorTo ("CTRL + R", "Send ('darkchant raisedead '..GetVariable ('system_target'))", 12)
	
	--[[DOUBLE VENOMS]]--
	AcceleratorTo ("CTRL + -", "", 12)
	AcceleratorTo ("CTRL + 0", "offense:double_envenom ({'dulak', 'niricol'})", 12)
	AcceleratorTo ("CTRL + 9", "offense:double_envenom ({'calcise', 'calcise'})", 12)
	AcceleratorTo ("CTRL + 8", "offense:double_envenom ({'senso', 'chansu'})", 12)
	AcceleratorTo ("CTRL + 7", "offense:double_envenom ({'dulak', 'senso'})", 12)
	AcceleratorTo ("CTRL + 6", "offense:double_envenom ({'dulak', 'hadrudin'})", 12)
	AcceleratorTo ("CTRL + 5", "offense:double_envenom ({'mantakaya', 'hadrudin'})", 12)
	AcceleratorTo ("CTRL + 4", "offense:double_envenom ({'morphite', 'morphite'})", 12)
	AcceleratorTo ("CTRL + 3", "offense:double_envenom ({'dulak', 'haemotox'})", 12)
	
--[[SINGLE VENOMS]]--
	AcceleratorTo ("ALT + 0", "offense:single_envenom ('dulak')", 12)
	AcceleratorTo ("ALT + 3", "offense:single_envenom ('haemotox')", 12)
	AcceleratorTo ("ALT + 6", "offense:single_envenom ('hadrudin')", 12)
	
end --setcombatkeys


local function setmovekeys ()

	AcceleratorTo ("Numpad1", "Execute ('sw')", 12)
	AcceleratorTo ("CTRL + Numpad1", "Execute ('tumble sw')", 12)
	AcceleratorTo ("ALT + Numpad1", "Execute ('somersault sw')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad1", "Execute ('evade sw')", 12)
	AcceleratorTo ("Numpad2", "Execute ('s')", 12)
	AcceleratorTo ("CTRL + Numpad2", "Execute ('tumble s')", 12)
	AcceleratorTo ("ALT + Numpad2", "Execute ('somersault s')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad2", "Execute ('evade s')", 12)
	AcceleratorTo ("Numpad3", "Execute ('se')", 12)
	AcceleratorTo ("CTRL + Numpad3", "Execute ('tumble se')", 12)
	AcceleratorTo ("ALT + Numpad3", "Execute ('somersault se')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad3", "Execute ('evade se')", 12)
	AcceleratorTo ("Numpad4", "Execute ('w')", 12)
	AcceleratorTo ("CTRL + Numpad4", "Execute ('tumble w')", 12)
	AcceleratorTo ("ALT + Numpad4", "Execute ('somersault w')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad4", "Execute ('evade w')", 12)
	AcceleratorTo ("Numpad5", "Execute ('look')", 12)
	AcceleratorTo ("Numpad6", "Execute ('e')", 12)
	AcceleratorTo ("CTRL + Numpad6", "Execute ('tumble e')", 12)
	AcceleratorTo ("ALT + Numpad6", "Execute ('somersault e')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad6", "Execute ('evade e')", 12)
	AcceleratorTo ("Numpad7", "Execute ('nw')", 12)
	AcceleratorTo ("CTRL + Numpad7", "Execute ('tumble nw')", 12)
	AcceleratorTo ("ALT + Numpad7", "Execute ('somersault nw')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad7", "Execute ('evade nw')", 12)
	AcceleratorTo ("Numpad8", "Execute ('n')", 12)
	AcceleratorTo ("CTRL + Numpad8", "Execute ('tumble n')", 12)
	AcceleratorTo ("ALT + Numpad8", "Execute ('somersault n')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad8", "Execute ('evade n')", 12)
	AcceleratorTo ("Numpad9", "Execute ('ne')", 12)
	AcceleratorTo ("CTRL + Numpad9", "Execute ('tumble ne')", 12)
	AcceleratorTo ("ALT + Numpad9", "Execute ('somersault ne')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad9", "Execute ('evade ne')", 12)
	AcceleratorTo ("Subtract", "Execute ('u')", 12)
	AcceleratorTo ("CTRL + Subtract", "Execute ('tumble up')", 12)
	AcceleratorTo ("ALT + Subtract", "Execute ('somersault up')", 12)
	AcceleratorTo ("CTRL + ALT + Subtract", "Execute ('evade up')", 12)
	AcceleratorTo ("Add", "Execute ('d')", 12)
	AcceleratorTo ("CTRL+ Add", "Execute ('tumble d')", 12)
	AcceleratorTo ("ALT+ Add", "Execute ('somersault d')", 12)
	AcceleratorTo ("CTRL + ALT+ Add", "Execute ('evade d')", 12)
	AcceleratorTo ("Numpad0", "Execute ('in')", 12)
	AcceleratorTo ("CTRL + Numpad0", "Execute ('tumble up')", 12)
	AcceleratorTo ("ALT + Numpad0", "Execute ('climb in')", 12)
	AcceleratorTo ("CTRL + ALT + Numpad0", "Execute ('evade in')", 12)
	AcceleratorTo ("Decimal", "Execute ('out')", 12)
	AcceleratorTo ("CTRL + Decimal", "Execute ('tumble down')", 12)
	AcceleratorTo ("ALT + Decimal", "Execute ('climb out')", 12)
	AcceleratorTo ("Divide", "Execute ('fly')", 12)
	AcceleratorTo ("Multiply", "Execute ('land')", 12)
	
end --setmovekeys


function offense:install ()

	DeleteAlias ("sheathe")
	DeleteAlias ("wielding")
	DeleteTriggerGroup ("System_Offense")
	io.input ("system_offense.xml")
	local xml = io.read ("*all")
	ImportXML(xml)
	setattackkeys ()
	setmovekeys ()
	
	if GetVariable ("demon_power")==nil then SetVariable ("demon_power", "0") end
	if GetVariable ("demon_lasthit")==nil then SetVariable ("demon_lasthit", "-1") end
	if GetVariable ("demon_willhit")==nil then SetVariable ("demon_willhit", "-1") end
	if GetVariable ("demon_double")==nil then SetVariable ("demon_double", "0") end
	
	display.system ("Offense Installed")
	display.system ("Searching for Wielded Weapons...")
	Execute ("ii wield")
	
end --function


function offense:reset (option, silent)

	if option then
		self [option] = {}
		self [option] = nil
	else
		for k, v in pairs (self) do
			if 	type (k) == "table" and
				k ~= "pacts"
					then
				self [k] = {}
				self [k] = nil
			end --if
		end--for
	end--if
	
	if not silent then
		display.system ("Offense RESET")
	end --if

end --function


function offense:init ()

	offense:reset (nil, true)
	loadstring (GetVariable ("system_offense")) ()
	for kind, ids in pairs (system_offense) do
		self [kind] = self [kind] or {}
		for k, id in pairs (ids) do
			if type (k) == "number" then
				table.insert (self [kind], id)
			else
				self [kind] [k] = id
			end --if
		end --for
	end --for
	system_offense = {}
	system_offense = nil
	setattackkeys ()
	setmovekeys ()
	
	if GetVariable ("demon_power")==nil then SetVariable ("demon_power", "0") end
	if GetVariable ("demon_lasthit")==nil then SetVariable ("demon_lasthit", "-1") end
	if GetVariable ("demon_willhit")==nil then SetVariable ("demon_willhit", "-1") end
	if GetVariable ("demon_double")==nil then SetVariable ("demon_double", "0") end
	
end --function


function offense:save ()

	system_offense = {}
	for kind, ids in pairs (self) do
		if
			type (ids) == "table" and
			kind ~= "rebounds" and
			kind ~= "casters" and
			kind ~= "powers"
				then
			system_offense [kind] = offense [kind]
		end --if
	end --for
	SetVariable ("system_offense", serialize.save ("system_offense"))
	system_offense = {}
	system_offense = nil
	
end --function


function offense:exec (kind, input, arg1, arg2)

	if not offense:able (kind) then
		return
	end --if
	
	if type (input) == "string" then
		local fn = offense [input]
		if fn then
			fn (self, arg1, arg2)
			return
		end --if
	end --if
	
	if type (input) == "table" then
		local command
		for k, v in ipairs (input) do
			if type (v) == "table" then
				for p, t in ipairs (v) do
					if t == "target" then
						t = GetVariable ("system_target")
					elseif string.find (t, "demon") and GetVariable ("demon_id") ~= "" then
						t = GetVariable ("demon_id")
					end --if
					if not command then
						command = t
					else
						command = command.." "..t
					end --if
				end --for
				Send (command)
				command = nil
			else
				if v == "target" then
					v = GetVariable ("system_target")
				elseif string.find (v, "demon") and GetVariable ("demon_id") ~= "" then
					v = GetVariable ("demon_id")
				end --if
				if not command then
					command = v
				else
					command = command.." "..v
				end --if
			end --if
		end --for
		if command then
			Send (command)
		end --if
		if able:to ("sting") then
			Send ("sting "..GetVariable ("system_target"))
		end--if
	else
		display.warning ("You must specify a string or a table value for your offensive actions!")
	end --if
	
end --function


function offense:assess (arg1, arg2, arg3)

	as=as or {}
	if not arg1 then
		if not next (as) then
			return display.system ("Nothing was Assessed!")
		end --if
		local ll=80
		local colour = {
			["critical"] = "magenta",
			["heavy"] = "deeppink",
			["medium"] = "yellow",
		}
		ColourTell ("white", "", string.rep (" ", math.floor (ll-#tostring (as ["health"] ["current"])-3-#tostring (as ["health"] ["max"]))/2))
		if tonumber (as ["health"] ["current"]) >= tonumber (as ["health"] ["max"])*2/3 then
			ColourTell ("steelblue", "", as ["health"] ["current"])
		elseif tonumber (as ["health"] ["current"]) >= tonumber (as ["health"] ["max"])*1/3 then
			ColourTell ("yellow", "", as ["health"] ["current"])
		else
			ColourTell ("red", "", as ["health"] ["current"])
		end --if
		ColourNote ("steelblue", "", " - "..as ["health"] ["max"])
		ColourNote ("silver", "", string.rep (" ", math.floor ((ll-1)/2)).."--")
		ColourTell ("lime", "", string.rep (" ", math.floor (ll-#as ["Head"]-2)/2).."[")
		if colour [as ["Head"]] then
			ColourTell (colour [as ["Head"]], "", as ["Head"])
		else
			ColourTell ("silver", "", as ["Head"])
		end--if
		ColourNote ("lime", "", "]")
		ColourNote ("silver", "", string.rep (" ", math.floor ((ll-1)/2)).."--")
		ColourNote ("silver", "", string.rep (" ", math.floor (ll-1)/2).."|")
		ColourTell ("silver", "", string.rep (" ", math.floor (ll-#as ["Chest"]-6)/2).."/ ")
		ColourTell ("lime", "", "[")
		if colour [as ["Chest"]] then
			ColourTell (colour [as ["Chest"]], "", as ["Chest"])
		else
			ColourTell ("silver", "", as ["Chest"])
		end--if
		ColourTell ("lime", "", "]")
		ColourNote ("silver", "", " \\")
		ColourTell ("lime", "", string.rep (" ", math.floor (ll-#as ["Right arm"]-#as ["Chest"]-#as ["Left arm"]-8)/2).."[")
		if colour [as ["Right arm"]] then
			ColourTell (colour [as ["Right arm"]], "", as ["Right arm"])
		else
			ColourTell ("silver", "", as ["Right arm"])
		end--if
		ColourTell ("lime", "", "]")
		ColourTell ("silver", "", string.rep (" ", math.floor ((#as ["Chest"]+4)/2)).."|")
		ColourTell ("lime", "", string.rep (" ", math.floor ((#as ["Chest"]+4)/2)).."[")
		if colour [as ["Left arm"]] then
			ColourTell (colour [as ["Left arm"]], "", as ["Left arm"])
		else
			ColourTell ("silver", "", as ["Left arm"])
		end--if
		ColourNote ("lime", "", "]")
		ColourNote ("silver", "", string.rep (" ", math.floor (ll/2)).."|")
		ColourTell ("lime", "", string.rep (" ", math.floor (ll-#as ["Gut"]-2)/2).."[")
		if colour [as ["Gut"]] then
			ColourTell (colour [as ["Gut"]], "", as ["Gut"])
		else
			ColourTell ("silver", "", as ["Gut"])
		end--if
		ColourNote ("lime", "", "]")
		ColourNote ("silver", "", string.rep (" ", math.floor ((ll-6)/2)).."/    \\")
		ColourTell ("lime", "", string.rep (" ", math.floor ((ll-8-#as ["Left leg"]- #as ["Right leg"])/2)).."[")
		if colour [as ["Right leg"]] then
			ColourTell (colour [as ["Right leg"]], "", as ["Right leg"])
		else
			ColourTell ("silver", "", as ["Right leg"])
		end--if
		ColourTell ("lime", "", "]    [")
		if colour [as ["Left leg"]] then
			ColourTell (colour [as ["Left leg"]], "", as ["Left leg"])
		else
			ColourTell ("silver", "", as ["Left leg"])
		end--if
		ColourNote ("lime", "", "]")
		--ColourNote ("silver", "", string.rep (" ", math.floor ((ll-12)/2)).."/          \\")
		as={}
		as=nil
	else
		if arg1 == "health" then
			as ["health"] = {
				["current"] = arg2,
				["max"] = arg3,
			}
		else
			as [arg1] = arg2
		end --if
	end --if

end --function


function offense:set_caster (name, spell)

	offense ["casters"] [spell] = name
	
end --function


function offense:get_caster (spell)

	return offense ["casters"] [spell]
	
end --function


function offense:set_current (id, fullname)

	self ["current"] = self ["current"] or {}
	self ["current"] [id] = fullname
	self:save ()
	
end --function


function offense:bash_attack (input)

	if not input then
		return display.system ("ERROR - you must specify an attack VERB for your bashing attack!")
	end --if
	
	if type (input) ~= "table" then
		return display.system ("ERROR - you must specify a TABLE of attacks")
	end --if
	
	self ["bashing"] = input
	self:save ()
	
end --function


function offense:rebound (person, lost, special)

	if not person then
		return display.warning ("Must specify a person to track rebound!")
	end --if
	
	if not lost then
		self ["rebounds"] [person] = (self ["rebounds"] [person] or 0)+1
		if person == GetVariable ("system_target") and special then
			display.shield ()
		end --if
	else
		self ["rebounds"] [person] = (self ["rebounds"] [person] or 1)-1
		if self ["rebounds"] [person] == 0 then
			self ["rebounds"] [person] = nil
		end --if
	end --if
	
end --function


function offense:has_rebound (person)

	if self ["rebounds"] [person or GetVariable ("system_target")] then
		return true
	else
		return false
	end --if
	
end --function


function offense:able (action)
	
	if affs:has ("aeon") then
		display.warning (" Stand Still!   AEON   AEON   AEON AEON   AEON   AEON   AEON   AEON")	 
		return false
	elseif affs:has ("sap") then
		display.warning (" Stand Still!   SAP   SAP   SAP SAP   SAP   SAP   SAP   SAP   SAP   SAP")
		return false
	elseif action then
		if action == "attack" then
			if not GetVariable ("system_target") then
				display.warning ("You must specify a TARGET")
				return false
			end --if
		elseif action == "envenom" then
			if not next (self ["current"]) then
				display.warning ("You don't have any weapons wielded!")
				return false
			end --if
		end --if
	end --if
	
	return true
	
end --function


function offense:demon (line, pact)

	local colour = "lime"
	if next (offense ["powers"]) then
			--the current power number that is discharging
		local power = tonumber (GetVariable ("demon_power"))
			--if I was discharging two powers, and how many times will I be doing that
		local double = tonumber (GetVariable ("demon_double"))
			--how many powers I was discharging
		local amount = 1
			--the discharging power, to be displayed
		local msg = offense ["powers"] [power]
			--last power number to be discharged
		local last = #offense ["powers"]
			--if I have the message, but the power I am tracking does not correspund
		if not self ["pacts"] [pact] [self ["powers"] [power]] then
			local found
				--serching through the following powers
			for k = power+1, last do
				if self ["pacts"] [pact] [self ["powers"] [k]] then
					SetVariable ("demon_power", k)
					power = k
					found = true
					break
				end
			end --for
				--and throught the previous ones
			if not found then
				for k = 1, power-1 do
					if self ["pacts"] [pact] [self ["powers"] [k]] then
						SetVariable ("demon_power", k)
						power = k
						found = true
						break
					end
				end--for
			end--if
				--powers are not synced
			if not found then
				display.warning ("Powers tracking unsynchronized")
				ColourNote (colour, "", line)
				return display.warning ("Powers tracking unsynchronized")
			end--if
		end--if
			--keeping track of the last power discharged
		offense.powers.last_power = msg
			--setting the next power(s) to be used
		if double>0 then
			local p
			if power == last then
				p = offense ["powers"] [1]
			else
				p = offense ["powers"] [power+1]
			end--if
			msg = msg.." + "..p --I show the message for both powers discharging
			offense.powers.last_power = p
			amount = 2
			double = double-1
			SetVariable ("demon_double", double)
		end
		display.enemy (msg)
		ColourNote (colour, "", line)
		display.enemy (msg)
		power = power + amount
		if power > last then
			power = power - last
		end--if
		if power == 0 then power = 1 end
		SetVariable ("demon_power", power)
		SetVariable ("demon_willhit", "8")
		SetVariable ("demon_lasthit", os.time ())
	else
		display.enemy ("demon untracked")
		ColourNote (colour, "", line)
		display.enemy ("demon untracked")
	end--if
	if IsTimer ("demon_four") ~= 0 then
		ImportXML([[<timers>
		<timer
		name="demon_four"
		minute="0"
		second="4"
		offset_second="0.00"
		send_to="12"
		group="System_Offense" >
		<send>EnableTimer ("demon_four", false)
		EnableTimer ("demon_one", true)
		ResetTimer ("demon_one")
		ColourNote ("red", "", "  _  _")   
		ColourNote ("red", "", " | || |  ")
		ColourNote ("red", "", " | || |_ ")
		ColourNote ("red", "", " |__   _|")
		ColourNote ("red", "", "    | |  ")
		ColourNote ("red", "", "    |_|  ")</send>
		</timer>
		</timers>]])
	end
	EnableTimer ("demon_four", true)
	ResetTimer ("demon_four")
	if IsTimer ("demon_one") ~= 0 then
		ImportXML([[<timers>
		<timer
		name="demon_one"
		minute="0"
		second="3"
		offset_second="0.00"
		send_to="12"
		group="System_Offense" >
		<send>EnableTimer ("demon_one", false)
		EnableTrigger ("demon_attacked", true)
		ColourNote ("red", "", "  __ ")
		ColourNote ("red", "", " /_ |")
		ColourNote ("red", "", "  | |")
		ColourNote ("red", "", "  | |")
		ColourNote ("red", "", "  | |")
		ColourNote ("red", "", "  |_|")</send>
		</timer>
		</timers>]])
	end
	EnableTimer ("demon_one", false)

end --demon


function offense:passify ()

	Send ('order '..GetVariable ("demon_id")..' passive') 
	EnableTrigger ('demon_passive', true) 

end--passive


function offense:passive ()

	display.success ("passive")
	local diff = 8 - os.time () + tonumber (GetVariable ("demon_lasthit"))
	if diff<0 then
		SetVariable ("demon_willhit", "0")
	else
		SetVariable ("demon_willhit", diff)
	end
	SetVariable ("demon_lasthit", "0")
	EnableTimer ("demon_four", false)
	EnableTimer ("demon_one", false)

end--passive


function offense:aggressify ()

	Send ("order "..GetVariable ("demon_id").." attack "..GetVariable ("system_target"))
	EnableTrigger ('demon_attacked', true)
	if IsTimer ("demon_four") ~= 0 then
		ImportXML([[<timers>
		<timer
		name="demon_four"
		minute="0"
		second="4"
		offset_second="0.00"
		send_to="12"
		group="System_Offense" >
		<send>EnableTimer ("demon_four", false)
		EnableTimer ("demon_one", true)
		ResetTimer ("demon_one")
		ColourNote ("red", "", "  _  _")   
		ColourNote ("red", "", " | || |  ")
		ColourNote ("red", "", " | || |_ ")
		ColourNote ("red", "", " |__   _|")
		ColourNote ("red", "", "    | |  ")
		ColourNote ("red", "", "    |_|  ")</send>
		</timer>
		</timers>]])
	end
	if IsTimer ("demon_one") ~= 0 then
		ImportXML([[<timers>
		<timer
		name="demon_one"
		minute="0"
		second="3"
		offset_second="0.00"
		send_to="12"
		group="System_Offense" >
		<send>EnableTimer ("demon_one", false)
		EnableTrigger ("demon_attacked", true)
		ColourNote ("red", "", "  __ ")
		ColourNote ("red", "", " /_ |")
		ColourNote ("red", "", "  | |")
		ColourNote ("red", "", "  | |")
		ColourNote ("red", "", "  | |")
		ColourNote ("red", "", "  |_|")</send>
		</timer>
		</timers>]])
	end		

end--aggressify


function offense:aggressive ()

	display.success ("attack")
	if GetVariable ('demon_lasthit') == '0' then SetVariable ('demon_lasthit', os.time ()) end
	EnableTimer ("demon_four", true)
	
end--aggresive


function offense:soulless_rub ()

	if flags:get_check ("soulless") then --if the soulless card is already in my inv
		Send ("rub soulless on "..GetVariable ("system_target"))
	else
		SendNoEcho ("outd soulless")
		flags:add_check ("soulless_rub")
	end--if

end--soulless rub


function offense:soulless_fling ()

	Execute ('sys off') 
	Send ("fling soulless at "..GetVariable ("system_target")) 
	EnableTrigger ('soulless_try', true)

end--soulless_fling
	

function offense:shield (psi)

	if not offense:able () then
		return
	else
		if psi then psi = " psi"
		else psi = " " end
		if skills:is_available ("circle") then
			Send ("invoke circle"..psi)
		elseif skills:is_available ("pentagram") then
			Send ("evoke pentagram"..psi)
		else
			display.system ('No Shield Ability Available - Check Your SKILLS?')
		end--if
	end--if
	
end --function


function offense:bash ()

	local command
	for k, t in ipairs (self ["bashing"] [1]) do
		if t == "target" then
			t = GetVariable ("system_target")
		end --if
		if not command then
			command = t
		else
			command = command.." "..t
		end --if
	end --for
	Send (command)
	
end --bashing

function offense:double_envenom (poisons, special)

	if not offense:able ("envenom") then
		return
	end--if
	
	for k, id in ipairs (self ["current"]) do
		SendNoEcho ("wipe "..id)
	end --for
	
	if special then
		if special == "disable" then
			if #self ["current"] == 2 then
				combos = {{"dulak", "mantakaya"}, {"dulak", "niricol",}, {"niricol", "mantakaya",}}
			elseif #self ["current"] == 1 then
				combos = {{"niricol"}, {"dulak"},}
			end--if
			poisons = combos [math.random (#combos)]
			combos = {}
			combos = nil
		end--if
	end --if
	
	for k=1,2 do
		Send ("envenom "..offense ["current"] [1].." with "..poisons [k])
	end --for

end --function

function offense:single_envenom (poison)

	for k, id in ipairs (self ["current"]) do
		SendNoEcho ("wipe "..id)
	end --for
	
	Send ("envenom "..offense ["current"] [1].." with "..poison)
	
end --function

		
offense:init ()


return offense