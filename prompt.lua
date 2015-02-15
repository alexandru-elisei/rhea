--[[
	PROMPT
]]--


require "display"
require "scan"
require "affs"
require "flags"
--require "system"


if
	not prompt
		then
	prompt = {
		["vitals"] = {
			c_health = c_health or 0,
			c_mana = c_mana or 0,
			c_ego = c_ego or 0,
			c_power = c_power or 0,
			c_willpower = c_willpower or 0,
			c_endurance = c_endurance or 0,
			max_health = max_health or 0, --to do something about this
			max_mana = max_mana or 0,
			max_ego = max_ego or 0,
			max_power = 10,
			max_willpower = max_willpower or 0,
			max_endurance = max_endurance or 0,
			},
		["count"] = nil,
		["queued"] = {
			["current"] = {},
			["checking"] = {},
			["ids"] = {},
		},
		["alerts"] = {},
	}
end --if


	--QUEUES ACTIONS TO BE EXECUTED AT THE PROMPT (LIKE ADDING AFFLICTIONS THAT HAVE PASSED THE ANTI-ILUSSION CHECKS
function prompt:queue (f, id, check)

	if
		not f or
		type (f) ~= "function"
			then
		return display.Error ("Must pass a valid function to the prompt queue")
	end--if
	
	if not id then
		return display.warning ("error - must pass an id for the queued functions")
	end--if
	
	if next (self ["queued"] ["current"]) then
		for k, v in ipairs (self ["queued"] ["current"]) do
			if v==id then
				return
			end --if
		end --for
	end --if
	
	self ["queued"] ["ids"] [id] = f
	self ["queued"] ["current"] [#self ["queued"] ["current"]+1] = id
	
	if check then
		self ["queued"] ["checking"] [id] = check
		EnableTrigger ("illusioned", true)
		self:queue (function ()EnableTrigger ("illusioned", false)end, "disable_illusioned")
	end--if
		
	display.deb ("PROMPT:QUEUE-> added "..id.." for a total of "..tostring (#prompt ["queued"] ["current"]))
	
end --function


	--REMOVES QUEUED ACTIONS
function prompt:unqueue (name)
	if next (self ["queued"] ["current"]) then
		if name then
			for k, id in ipairs (self ["queued"] ["current"]) do
				if id == name then
					table.remove (self ["queued"] ["current"], k)
					self ["queued"] ["ids"] [id] = nil
					self ["queued"] ["checking"] [id] = nil
					break
				end --if
			end --for
		else
			i = 1
			repeat
				local is_checked = self ["queued"] ["current"] [i]
				if  self ["queued"] ["checking"] [is_checked] then
					self ["queued"] ["checking"] [is_checked] = nil
					table.remove (self ["queued"] ["current"], i)
				else
					i=i+1
				end --if
			until (i>#self ["queued"] ["current"])
			flags:reset_check ("silent")		
			system:del_cure ()
			display.system ("Prompt Unqueued")
		end --if
	end --if
	
end --function


function prompt:is_queued (name)

	if next (self.queued.current) then
		for k, n in ipairs (self.queued.current) do
			if n==name then
				return true
			end--if
		end--for
	end--if
	
	return false
	
end--function


function prompt:queue_reset (silent)
	
	self ["queued"] = {
		["current"] = {},
		["checking"] = {},
		["ids"] = {},
	}
	
	if not silent then
		display.system ("Prompt RESET")
	end --if

end --function


function prompt:add_alert (name, msg, visibility, remaining, priority)

	if not name then
		return display.error ("Prompt:add_alert -> Must specify a name!")
	end--if
	
	if not msg then msg = name end--no message means that it will show the name
	
	if not visibility or type (visibility) ~= "number" then
		return display.error ("Prompt:add_alert -> Must specify a number of seconds!")
	end--if
	
	if remaining and remaining ~= -1 and remaining ~= 1 then
		return display.error ("Prompt:add_alert -> third argument must be -1 or 1")
	end--if
	
	if priority and type (priority) ~= "number" then
		return display.error ("Prompt:add_alert -> the priority must be a number")
	end--if
	
	name = string.lower (string.gsub (name, " ", "_"))
		--updating the alert if it already existss
	if next (self ["alerts"]) then
		for k, tag in ipairs (self ["alerts"]) do
			if tag ["name"] == name then
				table.remove (self ["alerts"], k)
				break
			end--if
		end --for
	end --if
	
		--adding the alert
	local tag = {
		["name"] = name,
		["message"] = msg,
		["start_time"] = os.time (),
		["visibility"] = visibility,
		["remaining"] = remaining,
	}
	if priority then
		table.insert (self ["alerts"], priority, tag)
	else
		table.insert (self ["alerts"], tag)
	end--if
		--making sure I delete the alert after its time is up
	local minutes = math.floor(visibility/60)
	local seconds = math.fmod (visibility,60)
	if IsTimer ("alert_"..name) ~= 0 then
		ImportXML([[<timers>
<timer
name="]].."alert_"..name..[["
minute="]] .. minutes .. [["
second="]] .. seconds .. [["
offset_second="0.00"
one_shot="y"
send_to="12"
group="System_Fst" >
<send>local an = string.gsub ("]]..name..[[", "_", " ")
prompt:del_alert(an)
DeleteTimer ("alert_]]..name..[[")</send>
</timer>
</timers>]])
	else
		SetTimerOption ("alert_"..name, "second", visibility)
	end--if
	EnableTimer ("alert_"..name, true)
	ResetTimer ("alert_"..name)

end --add_alert


function prompt:del_alert (name)
	
	name = string.lower (string.gsub (name, " ", "_"))
	if next (self ["alerts"]) then
		for k, tag in ipairs (self ["alerts"]) do
			if tag ["name"] == name then
				table.remove (self ["alerts"], k)
				DeleteTimer ("alert_"..string.lower (name))
				break
			end--if
		end --for
	end--if
	
end --del_alert


function prompt:alert ()
	
	local alerted
	
	if affs:has ("asleep") then
		ColourTell ("red", "", "Sleep|")
	end--if
	
	if affs:has ("recklessness") then
		ColourTell ("red", "", "R|")
		alerted = true
	end --if
	
	if affs:is_prone () then
		ColourTell ("red", "", "PR|")
		alerted = true
	end --if

	if affs:has ("choke") then
		ColourTell ("red", "", "CHK|")
		alerted = true
	else
		if affs:has ("sap")	 then
			ColourTell ("red", "", "SP|")
			alerted = true
		end --if
		if affs:has ("aeon") then
			ColourTell ("red", "", "AE|")
			alerted = true
		end --if
	end --if
	
	if affs:has ("unwield") then
		ColourTell ("red", "",  "UNWIELD!|")
		alerted = true
	end --if
	
	if affs:has ("tendon_leftleg") or affs:has ("tendon_rightleg") then
		ColourTell ("red", "", "Tendon|")
		alerted = true
	end --if
	
	if affs:has ("mangled_leftarm") or affs:has ("mangled_rightarm") then
		ColourTell ("red", "", "ManArm|")
		alerted = true
	end --if
	
	if affs:has ("mangled_leftleg") or affs:has ("mangled_rightleg") then
		ColourTell ("red", "", "ManLeg|")
		alerted = true
	end --if
	
	if affs:has ("amputated_leftarm") or affs:has ("amputated_rightarm") then
		ColourTell ("red", "", "AmpArm|")
		alerted = true
	end --if
	
	if affs:has ("amputated_leftleg") or affs:has ("amputated_rightleg") then
		ColourTell ("red", "", "AmpLeg|")
		alerted = true
	end --if
	
	if affs:has ("pinleg") then
		ColourTell ("red", "", "PinLeg")
		alerted = true
	end--if
	
	if affs:has ("shatteredankle_leftleg") or affs:has ("shatteredankle_rightleg") then
		ColourTell ("red", "", "Ankle|")
		alerted = true
	end --if
	
	if affs:has ("slitthroat") then
		ColourTell ("red", "", "SLITTHROAT|")
		alerted = true
	end --if
	
	if affs:has ("windpipe") then
		ColourTell ("red", "", "WINDPIPE|")
		alerted = true
	end --if
	
	if affs:has ("diag") then
		ColourTell ("red", "", "Dg|")
		alerted = true
	end --if
	
	--[[
	if defs:has ("enraged") then
		ColourTell ("deepskyblue", "", "Rage|")
		alerted = true
	end --if]]
	
	if defs:has ("timeslip") then
		ColourTell (("deespkyblue"), "", "TS|")
		alerted = true
	end --if
	
	if defs:has ("quickened") then
		ColourTell (("deespkyblue"), "", "Quick|")
		alerted = true
	end --if
	
	if defs:has ("fool") then
		ColourTell (("deespkyblue"), "", "Fool|")
		alerted = true
	end --if
	
	if defs:has ("warrior") then
		ColourTell (("deespkyblue"), "", "Wa|")
		alerted = true
	end --if
	
	if defs:has ("starleaper") then
		ColourTell (("deespkyblue"), "", "Leaper|")
		alerted = true
	end --if
	
	if defs:has ("enigma") then
		ColourTell (("deespkyblue"), "", "Enigma|")
		alerted = true
	end --if
	
	if defs:has ("world") then
		ColourTell (("deespkyblue"), "", "World|")
		alerted = true
	end --if
	
	if defs:has ("shroud") then
		ColourTell (("deespkyblue"), "", "Shroud|")
		alerted = true
	end --if
	
	if defs:has ("fortuna") then
		ColourTell (("deespkyblue"), "", "Fort|")
		alerted = true
	end --if
	
	if defs:has ("adroitness") then
		ColourTell (("deespkyblue"), "", "Adroit|")
		alerted = true
	end --if--]]
	
	if affs:has ("pit") then
		ColourTell ("red", "", ">> PIT <<")
		if flags:get ("climbing") or flags:get ("pit") then
			ColourTell ("deepskyblue", "", "climb")
		end --if
		alerted = true
	end --if
	
	if offense ["feeds"] and next (offense ["feeds"]) then
		for name, v in pairs (offense ["feeds"]) do
			ColourTell ("limegreen", "", name.." "..tostring (v).."|")
		end--for
		alerted = true
	end--if
	
	if alerted then
		Note ("")
	end --if
	
	if next (self ["alerts"]) then
		local t = os.time ()
		ColourTell ("aqua", "", "|")
		for k, tag in pairs (self ["alerts"]) do
			if (tag ["remaining"] or 0) == -1 then
				local r = tag ["visibility"]+tag ["start_time"]-t
				ColourTell ("red", "", tag ["message"].." "..tostring (r))
				ColourTell ("aqua", "", "r|")
			elseif (tag ["remaining"] or 0) == 1 then
				local r = t-tag ["start_time"]
				ColourTell ("red", "", tag ["message"].." "..tostring (r))
				ColourTell ("aqua", "", "S|")
			else
				ColourTell ("red", "", tag ["message"])
				ColourTell ("aqua", "", "|")
			end --if
		end --for
		Note ("")
	end --if

end --function
		
		
function prompt:score (cmnd)

	if not cmnd then cmnd = "score" end
	
	EnableTrigger ("oldscore", true)
	EnableTrigger ("score_vitals", true)
	EnableTrigger ("qsc", true)
	EnableTrigger ("qsc_demi", true)
	
	act:queue (cmnd)
	act:exec ()
	fst:enable ("score")
	
end --function


function prompt:normal (chp, cm, ce, cp, cend, cwill, status)
	
	self ["status"] = status
	if status == "*" then
		if not affs:has ("blackout") then
			affs:add_simple ("blackout")
			flags:add_check ("reset_hme")
		end --if
		if flags:get_check ("vapors") then
			affs:add ("vapors")
			flags:del_check ("vapors")
		end --if
	else
		affs:del ("blackout")
	end--if
	
	health = chp
	mana = cm
	ego = ce
	power = cp
	willpower = cwill
	endurance = cend
	
	local mh = self ["vitals"] ["max_health"] --for ease of use
	local mm = self ["vitals"] ["max_mana"]
	local me = self ["vitals"] ["max_ego"]
	
	if flags:get_check ("dead") then--if I am scanning for death
		if health == 0 then--and I have 0 health
			if not system:is_dead () then--and I haven't already confirmed death
				prompt ["count"] = (prompt ["count"] or 0)+1--I count the prompts
				system:off ("silent")--and shut down curing
			end --if
		else--if I don't have 0 health
			flags:del_check ("dead")--I don't need to check for dead
			if not system:is_dead () then--if death wasn't confirmed
				display.system ("Illusion - PWN him")--illusion - getting annoyed
			else--this means I am alive!
				system:alive ()
			end --if
		end --if
		if not system:is_dead () then--if I haven't already confirmed death
			if prompt ["count"] == 3 then --if I have counted three prompts since I've been trying to confirm death
				prompt ["count"] = nil--stop counting
				system:died ()--confirming death
			else
				Send ("")--if I haven't reached 3 prompts I force a reaction
			end --if
		end --if
	end --if
		
		--getting possible damage
	local h_dif = health - self ["vitals"] ["c_health"]
	local m_dif = mana - self ["vitals"] ["c_mana"]
	local e_dif = ego - self ["vitals"] ["c_ego"]
	
		--checking for illusory wounds
	if flags:get_check ("illusory_wounds") then--how does it work? it always stays at 2/3*max_health			then
		if health <=  math.floor (2/3 * vitals ["c_health"]) then
			affs:add ("illusory_wounds")
			fst:enable ("illusory_wounds")
		end --if
		flags:del_check ("illusory_wounds")
	end --if
	
		--taking care of illusory wounds, if any
	if
		affs:has ("illusory_wounds") and
		health > math.floor (2/3*mh)
			then
		fst:fire  ("illusory_wounds")
	end --if
	
		--getting current stats
	self ["vitals"] ["c_health"] = health
	self ["vitals"] ["c_mana"] = mana
	self ["vitals"] ["c_ego"] = ego
	self ["vitals"] ["c_power"] = power
	self ["vitals"] ["c_willpower"] = willpower
	self ["vitals"] ["c_endurance"] = endurance
	
	
		--recklessness
	if flags:get_check ("recklessness") then
		local hr = 1
		if affs:has ("illusory_wounds") then
			hr = 2/3
		end--if
		if
			health == mh*hr and
			mana == mm*hr and
			ego >= me*hr and --as an illithoid, it is expected to have my ego bigger than max
			power == 10
				then
			affs:add ("recklessness")
			affs:del_hex ()
		end --if
		flags:del_check ("recklessness")
	end --if
	
		--hex
	if (flags:get_check ("hex") or 0)>0 then
		if flags:get_check ("hex") == 1 then
			affs:masked (1)
		else
			affs:masked (2)
		end --if
		flags:del_check ("hex")
	end --if		
	
		--getting equilibrium
	if string.find (status, "e") then
		if affs:has ("disrupted") then
			display.cured ("disrupted")
			affs:del ("disrupted")
			fst:disable ("disrupted")
		end --if
		bals:onbal ("eq", "silent")
		flags:del_check ("disrupted")
	elseif bals:has ("eq") then--if I just lost equilibrium
		flags:add_check ("disrupted", os.time ())--I store the time when I lost eq
		bals:offbal ("eq", "silent")
	else
		local t = os.time ()
		if (flags:get_check ("disrupted") or t)-t > 12 then--if I haven't got eq in the last 12 seconds
			affs:add ("disrupted")
			flags:del_check ("disrupted")
		end --if
		bals:offbal ("eq", "silent")
	end --if

		--dealing with armbalances
	if
		not system:is_enabled ("armbalance") and
		(string.find (status, "r") or string.find (status, "l"))
			then
		system:set_settings ("armbalance", 1)
	end --if
	
		--getting armbalances
	if system:is_enabled ("armbalance") then
		if  string.find (status, "r") then
			bals:onbal ("rightarm", "silent")
			if flags:get_check ("check_arm") == "right" then
				affs:add ("broken_rightarm")
			end--if
		else
			bals:offbal ("rightarm", "silent")
		end --if
		if string.find (status, "l") then
			bals:onbal ("leftarm", "silent")
			if flags:get_check ("check_arm") == "left" then
				affs:add ("broken_leftarm")
			end--if			
		else
			bals:offbal ("leftarm", "silent")
		end --if
	end --if
		
		--psionic channels
	if system:is_enabled ("channels") then
		if  string.find (status, "s") then
			bals:onbal ("sub", "silent")
		else
			bals:offbal ("sub", "silent")
		end --if
		if string.find (status, "S") then
			bals:onbal ("super",  "silent")
		else
			bals:offbal ("super", "silent")
		end --if
		if string.find (wildcards [7], "i") then
			bals:onbal ("id", "silent")
		else
			bals:offbal ("id", "silent")
		end --if
	end --if
	
		--executing the actions stored in the queue
	if next (self ["queued"] ["current"]) then
		for k, unique_ids in ipairs (self ["queued"] ["current"]) do
			self ["queued"] ["ids"] [unique_ids] ()
		end
		self:queue_reset ("silent")
	end
	
	if not affs:has ("blackout") then
			--checking for kafe
		if string.find (status, "k") then
			defs:ondef ("kafe", true, "silent")
			affs:del ("no_kafe")
		else
			defs:lostdef ("kafe", "silent")
		end --if

			--checking for blindness
		if string.find (status, "b") then
			if not defs:has ("sixthsense") then
				affs:add ("blindness", true, "silent")
			else
				affs:del ("blindness")
			end--if
		else
			affs:del ("blindness")
			defs:lostdef ("sixthsense", "silent") --if  I am not blind, then I don't have sixthsense
		end --if

			--checking for deafness
		if string.find (status, "d") then
			if not defs:has ("truehearing") then
				affs:add ("deafness", true, "silent")
			else
				affs:del ("deafness")
			end --if
		else
			affs:del ("deafness")
			defs:lostdef ("truehearing", "silent")--if I am not deaf, I don't have truehearing
		end --if
	end--if
	
		--checking for prone and different afflictions that prone
	local prone_checking = flags ["checking"] ["prone"] or {}
	if string.find (status, "p") then
		if next (prone_checking) then
			for k, aff in ipairs (prone_checking) do
				affs:add_simple (aff)
			end --for
		end --if
		if not affs:has ("prone") then
			local p_affs = {"entangled", "shackled", "roped", "crucified", "frozen", "stun",
							"paralysis", "pinleg", "severedspine", "tendon_leftleg",
							"tendon_rightleg", "mangled_leftleg", "mangled_rightleg",
							"amputated_rightleg", "amputated_leftleg"}
			local should_stand = true
			for k, v in ipairs (p_affs) do
				if affs:has (v) then
					should_stand = false
					break
				end --if
			end --for
			if should_stand then
				if flags:get_check ("cured_prone") then
					system:masked (1)
				else
					affs:add_simple ("prone")
				end --if
			end --if
			flags:del_check ("cured_prone")
		end --if
	elseif affs:has ("blackout") then --I am assuming all afflictions were real
		if next (prone_checking) then
			for k, aff in ipairs (prone_checking) do
				affs:add_simple (aff)
			end --for
		end --if
	else
		affs:del ({ "asleep", "entangled", "frozen", "paralysis", "roped", "stunned", "shackled" })
		if affs:has ("impaled") or affs:has ("crucified") then
			affs:impaled (0)
		end --if
		if affs:has ("prone") then
			system:cured ("prone")
		end --if
		flags:del_check ("cured_prone")
	end --if
	
	flags ["checking"] ["prone"] = {}
	
		--checking for balance and different afflictions that put you offbal
	local bal_checking = flags ["checking"] ["bal"]
	if  string.find (status, "x") then
		bals:onbal ("bal", "silent")
	else
		if next (bal_checking) then
			for k, aff in ipairs (bal_checking) do
				affs:add (aff)
			end --for
		end --if
		bals:offbal ("bal", "silent")
	end--if
	
	flags ["checking"] ["bal"] = {}
	
	local last_cure = system:is_curing ()
	if last_cure then
		nocure:check (last_cure)
	end --if
	
		--GAGGING THE PROMPT
	if not affs:has ("blackout") then
		if
			health == mh and
			mana == mm and
			ego == me
				then
			ColourTell ("steelblue", "", tostring (health).."h, "..tostring (mana).."m, "..tostring (ego).."e, ")
		else
			if  health <= mh * 3/4 then
				if health <= mh * 1/3 then
					ColourTell ("crimson", "", tostring (health).."h, ")
				else
					ColourTell ("yellow", "", tostring (health).."h, ")
				end -- if
			else
				ColourTell ("green", "", tostring (health).."h, ")
			end -- if
		
			if mana <= mm * 3/4 then
				if mana <= mm * 1/2 then
					ColourTell ("crimson", "", tostring (mana).."m, ")
				else
					ColourTell ("yellow", "", tostring (mana).."m, ")
				end -- if
			else
				ColourTell ("green", "", tostring (mana).."m, ")
			end -- if
			
			if ego <= me * 3/4 then
				if ego <= me * 1/2 then
					ColourTell ("crimson", "", tostring (ego).."e, ")
				else
					ColourTell ("yellow", "", tostring (ego).."e, ")
				end -- if
			else
				ColourTell ("green", "", tostring (ego).."e, ")
			end -- if
		end -- if
		
		if power <= 7 then
			if power <= 4 then
				ColourTell ("crimson", "", tostring (power).."p, ")
			else
				ColourTell ("yellow", "", tostring (power).."p, ")
			end -- if
		else
			ColourTell ("green", "", tostring (power).."p, ")
		end -- if
		
		if  endurance <= self ["vitals"] ["max_endurance"] * 3/4 then
			if  endurance <= self ["vitals"] ["max_endurance"] * 1/3 then
				ColourTell ("crimson", "", tostring (endurance).."en, ")
			else
				ColourTell ("yellow", "", tostring (endurance).."en, ")
			end -- if
		else
			ColourTell ("green", "", tostring (endurance).."en, ")
		end -- if

		if willpower <= self ["vitals"] ["max_willpower"] * 3/4 then
			if willpower <= self ["vitals"] ["max_willpower"] * 1/3 then
				ColourTell ("crimson", "", tostring (willpower).."w, ")
			else
				ColourTell ("yellow", "", tostring (willpower).."w, ")
			end -- if
		else
			ColourTell ("green", "", tostring (willpower).."w, ")
		end -- if
		
			--[[momentum
		if not system:is_enabled ("momentum") and offense ["mo"] then
			system:set_settings ("momentum", 1, "silent")
		end --if
		if system:is_enabled ("momentum") then
			ColourTell ("aqua", "", tostring (offense ["mo"]).."mo")
		end --if]]

			--GAGGING THE STATUS
		ColourTell ("silver", "", status.."- ")

			--BALANCE
		if bals:has ("eq") and bals:has ("bal") then
			ColourTell ("white", "forestgreen", "On")
		else
			ColourTell ("white", "crimson", "Off")
		end --if
	else
		ColourTell ("lightgrey", "", "--- BLACKOUT --->")
	end --if
	
		--high precision timer
	ColourTell ("silver", "", "|"..string.format("%0.3f|", GetInfo(232) % 60)..tostring (bals:get ("elixir"))..tostring (bals:get ("purg"))..tostring (bals:get ("herb"))..tostring (bals:get ("salve"))..tostring (bals:get ("focus"))..
tostring (bals:get ("ah")).."|")		
		
		--displaying damage and healing
	if not affs:has ("blackout") then
		if (h_dif ~= 0) then
			if h_dif >0 then
				ColourTell ("green", "", " +"..tostring(h_dif).."H")
			else
				ColourTell ("crimson", "", " "..tostring(h_dif).."H")
			end -- if
		end -- if
		if (m_dif ~= 0) then
			if m_dif >0 then
				ColourTell ("green", "", " +"..tostring(m_dif).."M")
			else
				ColourTell ("crimson", "", " "..tostring(m_dif).."M")
			end -- if
		end -- if
		if (e_dif ~= 0) then
			if e_dif >0 then
				ColourTell ("green", "", " +"..tostring(e_dif).."E")
			else
				ColourTell ("crimson", "", " "..tostring(e_dif).."E")
			end -- if
		end -- if
	end --if
	
	Note ("")
		--taking care of the alerts
	prompt:alert ()	
	if  next (offense ["powers"]) then
		ColourTell ("aqua", "", ">")
		local diff
		local lasthit = tonumber (GetVariable ("demon_lasthit"))
		local willhit
		if lasthit > -1 then
			willhit = 8 - os.time () + lasthit
			if willhit < 0 then
				if lasthit == 0 then
					willhit = 8
				else
					willhit = 0
				end--if
			end
			SetVariable ("demon_willhit", willhit)
			ColourTell ("pink", "", willhit.." ")
		end--if
		if GetVariable ("demon_power") ~= 0 and
			next (offense ["powers"])
				then
			local msg
			local no = tonumber (GetVariable ("demon_power"))
			if tonumber (GetVariable ("demon_double"))>0 then
				msg = offense ["powers"] [no]
				no = no+1
				if no>#offense ["powers"] then
					no = 1
				end --if
				msg = msg.." + "..offense ["powers"] [no]
			else
				msg = offense ["powers"] [no]
			end --if				
			ColourTell ("pink", "", msg)
			if willhit then
				ColourTell ("pink", "", " "..tostring (willhit))
			end--if
			Note ("")
		end--if
	end --if
	
	if
		system:is_on () and
		not affs:has ("stun") and--can't do a thing while stun
		not affs:has ("unconscious")--can't do a thing while unconscious
			then
		pipes:scan ()
		if not affs:has ("asleep") then
			scan.healing ()--done
			scan.elixir ()--done
			scan.sparklies ()--done
			scan.free ()--done
			scan.herb ()--done
			scan.salve ()--done
			scan.focus ()--done
			scan.bal () --done
			scan.bleeding ()--done. Maybe I should clot only if I don't have any other afflictions
		else
			scan.free ()--this is where I cure asleep
		end --if
	end --if
	if not sca:is_slowed () then
		act:exec ()
	end--if
	Note ("")
	
	display.deb ()
	
end -- function


return prompt


