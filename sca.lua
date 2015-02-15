--[[
		MAIN MODULE TO DEAL WITH SAP, CHOKE, AEON CURING

--]]


if not sca then
	sca = {
		["local_affs"] = {},
	}
end --if

	--test if I have sap/choke/aeon
function sca:is_slowed ()

	return affs:has ("sap") or affs:has ("choke") or affs:has ("aeon")

end --is_slowed

	--if I have an affliction
function sca:has (aff)
	
	return sca ["local_affs"] [aff]

end --has

	--I add afflictions to the local affliction list
function sca:add (aff, val)

	sca ["local_affs"] [aff] = (val or true)
	
end --add

	--I delete afflictions from the local affliction list because I cannot cure them
function sca:del (aff)

	if type (aff) == "table" then
		for k, v in ipairs (aff) do
			sca:del (v)
		end --for
	else
		sca ["local_affs"] [aff] = nil
	end --if
	
end --del


function sca:cure (aff, health, mana, ego, power, endurance, willpower, status)
	
	local fn = sca ["cure_"..aff]
	if not fn then
		return display.error ("Dumb Fuck, NO SUCH FUNCTION!")
	end --if
	
	prompt:normal (health, mana, ego, power, endurance, willpower, status)
	
	if not affs:has (aff) then
		EnableTrigger ("prompt_"..aff, false)
		flags:del_check ("reset_bals")
		return
	end --if
	
	if not system:is_on () then
		return
	end --if
	
		--resetting balances, since every action I take now will cancel every action before it that didn't finish
	if flags:get_check ("reset_bals") then
		local to_reset = {"speed", "purg", "elixir", "scroll", "herb", "salve", "focus"}
		for k, bal in ipairs (to_reset) do
			if bals:get (bal) == 0.5 then 
				local a, c = flags:bals_try (bal)
				if a then flags:del (a) end --if
				fst:fire (bal, "now")
			end --if
		end--for
		--flags:del ("curing")--not right, it will slow me down if I get aeoned again before curing
		if flags:get ("writhing_start") then
			fst:fire ("writhing", true)
		end--if
		if flags:get ("fastwrithe") then
			fst:fire ("fastwrithe", true)
		end--if
		flags:del_check ("reset_bals")
	end --if
		
--[[copying the afflictions to deal with them internally]]--
	if next (affs ["current"]) then
		for aff, val in pairs (affs ["current"]) do
			local cure = affs:get_cure ("salve", aff)
				--one regen cure per body part
			if cure and string.find (cure, "regeneration") then
				local part = string.sub (cure, 23)
				if not flags:get_check ("regenerating_"..part) and 
					not affs:has ("blackout") 
						then
					sca:add (aff, val)
				end --if
			else
				sca:add (aff, val)
			end --if
		end --for
	end --if
	
	if
		not sca:has ("stun") and
		not sca:has ("unconscious") and
		not flags:get ("curing") and
		next (sca ["local_affs"])
			then
			--sleep first, can't do a thing while asleep
		if sca:has ("asleep") then
			act:wake ()
			return act:exec ()
		end --if
		if sca:has ("diag") and not sca:has ("blackout") then
			act:diag ()
			return act:exec ()
		end --if
--[[adding/removing afflictions as necessary]]--
			--if I want to keep the love defense up, then I don't try to cure love, duh
		if system:is_auto ("love") then
			sca:del ("love")
		end --if
			--I can't use truehearing in blanknote
		if sca:has ("blanknote") then
			sca:del ("no_truehearing")
		end--if
			--don't cure recklessness in bedeviled?
		if sca:has ("bedeviled") then
			sca:del ("recklessness")
		end --if
			--don't cure hemiplegy with collapsednerves
		if sca:has ("collapsednerve_rightarm") then
			sca:del ("hemiplegy_right")
		end --if
		if sca:has ("collapsednerve_leftarm") then
			sca:del ("hemiplegy_left")
		end --if
			--no stiff curing 
		if next (affs ["ootangk"]) then
			for k, v in pairs (affs ["ootangk"]) do
				sca:del ("stiff_"..k)
			end --for
		end --if
			--don't cure brokenchest while having a crushed chest
		if sca:has ("crushedchest") then
			sca:del ("brokenchest")
		end --if
			--don't cure jinx while mental
		if sca:has ("jinx") then
			if affs:is_mental () then
				sca:del ("jinx")
			end --if
		end --if
			--don't eat horehound in maestoso
		if sca:has ("maestoso") then
			for a, v in pairs (sca ["local_affs"]) do
				if (affs ["cures"] ["herb"] [a] or "nil")== "eat horehound" then
					sca:del (a)
				end --if
			end --for
		end --if
			--don't cure blindness with both eyes pecked out
		if sca:has ("peckedeye_left") and sca:has ("peckedeye_right")	then
			sca:del ("blindness")
		end --if
			--don't use mending on mangled/amputated limbs
		if affs:has ("mangled_leftleg") or affs:has ("amputated_leftleg") then
			sca:del ({"broken_leftleg", "twisted_leftleg"})
		end --if
		if affs:has ("mangled_rightleg") or affs:has ("amputated_rightleg") then
			sca:del ({"broken_rightleg", "twisted_rightleg"})
		end --if
		if affs:has ("mangled_leftarm") or affs:has ("amputated_leftarm") then
			sca:del ({"broken_leftarm", "twisted_leftarm"})
		end --if
		if affs:has ("mangled_rightarm") or affs:has ("amputated_rightarm") then
			sca:del ({"broken_rightarm", "twisted_rightarm"})
		end --if
--[[finished playing with the afflictions]]--

		sca ["cure_"..aff] (self)
		act:exec ()
	end --if
	
end --function


function sca:check (text, aff)
	
	if text then
		if text == "slowed" then
			if not aff then
				display.error ("DUMB FUCK, suppply an affliction name when getting the slowed message!")
				return
			else
				if not affs:has (aff) then
					affs:add (aff)
				else
					flags:add_check ("slowed", aff)
					fst:enable ("sca")
				end--if
			end--if
		elseif affs:has ("sap") or affs:has ("aeon") or affs:has ("choke") then
				--when I am sending a command to the mud
			flags:add ("curing", text)
			fst:enable ("sca")
		end --if
	else --this means a command got executed by the mud
			--if I wasn't slowed beforehand
		if not flags:get_check ("slowed") then
			for k, v in ipairs ({"sap", "choke", "aeon"}) do
				if affs:has (v) then
					display.system ("Illusion Detected")
					system:cured (v)
				end --if
			end --for
		elseif flags:get_check ("slowed")== "sap" then
			for k, v in ipairs ({"choke", "aeon"}) do
				if affs:has (aff) then
					system:cured (aff)
				end --if
			end --for
		end --if
		fst:disable ("sca")
		flags:del ("curing")
		flags:del_check ("slowed")
	end --if
	
end--check
	
	--to test refilling and lighting in sap
function sca:cure_sap ()
	
		--if I can cleanse I will cleanse
	if able:to ("cleanse") then
		act:cleanse ()
		return
	end --cleansing
	
		--if I need to powercure because I have too many affs, this is faster
	if affs:count ("powercure") >= 5 and able:to ("powercure") then
		act:powercure ()
		return
	end --powercuring because I have too many afflictions
	
		--if I am in some kind of lock
	if not able:to ("drink") and not able:to ("apply")
			then
			--if I am in a softlock curable by cleanse
		if not able:to ("smoke") and sca:has ("slickness") and able:to ("cleanse") then
			act:cleanse ()
			return
		end --if
			--if I am in a slitthroat lock
		if sca:has ("slitthroat") and sca:has ("slickness") and able:to ("cleanse") then
			act:cleanse ()
			return
		end --if
			--if I am in a hardlock; should I wait to regain balance fro sap or just go for powercure?
		if able:to ("powercure") then
			if	(not able:to ("smoke") or affs:has ("slitthroat")) and
				sca:has ("prone") and 
				not able:to ("springup")--making sure bal isn't preventing me from standing
					then
				act:powercure ()
				return
			end --if
		elseif able:to ("restore") and sca:has ("prone") then
			local can, why
			can, why = able:stand ()
			if 	not can and
				(why == "broken_leftleg" or why == "broken_rightleg")
					then
				act:restore ()
				return
			end --if
		end --if
	end --if
	
		--taking care of healing the afflictions in the queue
	for k, aff in ipairs (self ["sap_queue"]) do
		if sca:has (aff ["name"]) then
			if able:to (aff ["able"]) then
				if aff ["able"] == "writhe" or aff ["able"] == "writhe_impaled" then
					if able:to ("fastwrithe") and
						not system:is_enabled ("contort")
							then
						return act:fastwrithe ()
					elseif
						not flags:get ("writhing_start") and
						not flags:get ("writhing") 
							then
						return aff ["cure"] ()
					end--if
				elseif bals:has (aff ["bal"])	then
					return aff ["cure"] ()
				end --if
			else
				local aff, cure = sca:get_aff (aff ["able"])
				if aff then
					return cure ()
				end --if
			end --if
		end --if
	end --for
	
end --cure_sap

	--to test refilling and lighting in aeon
function sca:cure_aeon ()
			
		--if I can drink I will drink phlegmatic
	if able:to ("drink") and bals:has ("purg") then
		act:drink ("drink phlegmatic", "purg", "aeon")
		return
	end --if
		
		--if I can adrenaline then I use it
	if not able:to ("drink") and able:to ("adrenaline") then
		act:adrenaline ()
		return
	end --if
	
		--using soulwash, if available
	if	not able:to ("drink") and	able:to ("soulwash") then
		local also_cured = {"recklessness", "healthleech", "dissonance", "peace",
									"pacifism", "peace", "powersink",}
		local to_soulwash = true
		for k, a in ipairs (also_cured) do
			if sca:has (a) then
				to_soulwash = false
				break
			end--if
		end--for
		if to_soulwash then
			act:soulwash ()
			to_soulwash = nil
			return
		end--if
		to_soulwash = nil
	end --if
		
		--if I have too many afflictions, then I try to powercure
	if affs:count ("powercure") >= 5 and able:to ("powercure") then
		act:powercure ()
		return
	end --if
		
		--if I am in some kind of lock
	if not able:to ("drink") and not able:to ("apply")
			then
			--if I am in a softlock curable by cleanse
		if not able:to ("smoke") and sca:has ("slickness") and able:to ("cleanse") then
			act:cleanse ()
			return
		end --if
			--if I am in a slitthroat lock
		if sca:has ("slitthroat") and sca:has ("slickness") and able:to ("cleanse") then
			act:cleanse ()
			return
		end --if
			--if I am in a hardlock; should I wait to regain balance fro sap or just go for powercure?
		if able:to ("powercure") then
			if	(not able:to ("smoke") or affs:has ("slitthroat")) and
				sca:has ("prone") and 
				not able:to ("springup")--making sure bal isn't preventing me from standing
					then
				act:powercure ()
				return
			end --if
		elseif able:to ("restore") and sca:has ("prone") then
			local can, why
			can, why = able:stand ()
			if 	not can and
				(why == "broken_leftleg" or why == "broken_rightleg")
					then
				act:restore ()
				return
			end --if
		end --if
	end --if
	
		--taking care of healing the afflictions in the queue
	for k, aff in ipairs (self ["aeon_queue"]) do
		if sca:has (aff ["name"]) then
			if able:to (aff ["able"]) then
				if aff ["able"] == "writhe" or aff ["able"] == "writhe_impaled" then
					if 	able:to ("fastwrithe") and
						not system:is_enabled ("fastwrithe")
							then
						return act:fastwrithe ()
					elseif
						not flags:get ("writhing_start") and
						not flags:get ("writhing") 
							then
						return aff ["cure"] ()
					end--if
				elseif bals:has (aff ["bal"])	then
					return aff ["cure"] ()
				end --if
			else
				local aff, cure = sca:get_aff (aff ["able"])
				if aff then
					return cure ()
				end --if
			end --if
		end --if
	end --for
	
end --cure_aeon


function sca:cure_choke ()
		
		--if I have too many afflictions, then I try to powercure
	if affs:count ("powercure") >= 5 and able:to ("powercure") then
		act:powercure ()
		return
	end --if
		
		--if I am in some kind of lock
	if not able:to ("drink") and not able:to ("apply")
			then
			--if I am in a softlock curable by cleanse
		if not able:to ("smoke") and sca:has ("slickness") and able:to ("cleanse") then
			act:cleanse ()
			return
		end --if
			--if I am in a slitthroat lock
		if sca:has ("slitthroat") and sca:has ("slickness") and able:to ("cleanse") then
			act:cleanse ()
			return
		end --if
			--if I am in a hardlock; should I wait to regain balance fro sap or just go for powercure?
		if able:to ("powercure") then
			if	(not able:to ("smoke") or affs:has ("slitthroat")) and
				sca:has ("prone") and 
				not able:to ("springup")--making sure bal isn't preventing me from standing
					then
				act:powercure ()
				return
			end --if
		elseif able:to ("restore") and sca:has ("prone") then
			local can, why
			can, why = able:stand ()
			if 	not can and
				(why == "broken_leftleg" or why == "broken_rightleg")
					then
				act:restore ()
				return
			end --if
		end --if
	end --if
	
		--taking care of healing the afflictions in the queue
	local to_cure
	for k, aff in ipairs (self ["choke_queue"]) do
		if sca:has (aff ["name"]) then
			if able:to (aff ["able"]) then
				if aff ["able"] == "writhe" or aff ["able"] == "writhe_impaled" then
					if 	able:to ("fastwrithe") and
						not system:is_enabled ("fastwrithe")
							then
						return act:fastwrithe ()
					elseif
						not flags:get ("writhing_start") and
						not flags:get ("writhing") 
							then
						return aff ["cure"] ()
					end--if
				elseif bals:has (aff ["bal"])	then
					return aff ["cure"] ()
				end --if
			elseif not to_cure then
				local aff, to_cure = sca:get_aff (aff ["able"])
			end --if
		end --if
		if to_cure then return to_cure () end--if
	end --for
	
end --cure_aeon
	

function sca:get_aff (condition, checked)
	
	checked = checked or {}
	if self ["able"] [condition] then
		local not_able
		for k, v in ipairs (self ["able"] [condition]) do
			local aff = v ["name"]
			if not checked [aff] then
				if condition == "smoke myrtle" then
					if pipes:is_empty ("myrtle") then
						affs:add ("pipes_refill", "myrtle", "silent")
						sca:add ("pipes_refill", "myrtle")
					elseif not pipes:is_lit ("myrtle") then
						affs:add ("pipes_unlit", pipes ["current"] ["myrtle"] ["id"], "silent")
						sca:add ("pipes_unlit", pipes ["current"] ["myrtle"] ["id"])
					end --if
				elseif condition == "smoke coltsfoot" then
					if pipes:is_empty ("coltsfoot") then
						affs:add ("pipes_refill", "coltsfoot", "silent")
						sca:add ("pipes_refill", "coltsfoot")
					elseif not pipes:is_lit ("coltsfoot") then
						affs:add ("pipes_unlit", pipes ["current"] ["coltsfoot"] ["id"], "silent")
						sca:add ("pipes_unlit", pipes ["current"] ["coltsfoot"] ["id"])
					end --if
				end --if					
				if sca:has (aff) then
					if able:to (v ["able"]) and bals:has (v ["bal"]) then
						return aff, v ["cure"]
					elseif not not_able then
						not_able = v ["able"]
					end --if
					checked [aff] = true
				end --if
			end --if
		end --for
		if not_able then
			return self:get_aff (not_able, checked)
		end --if
	end --if
	
end --function


sca ["aeon_queue"] = {
	{	name = "aeon",
		cure = function () act:drink ("drink phlegmatic", "purg", "aeon") end,
		bal = "purg",
		able = "drink",},
	{	name = "no_metawake",
		cure = function () act:metawake () end,
		bal = "purg",
		able = "none",},
	{	name = "mana_critical",
		cure = function () act:drink ("drink mana", "elixir", "mana_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "mana_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "health_critical",
		cure = function () act:drink ("drink health", "elixir", "health_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "vessels_critical",
		cure = function () act:drink ("drink health", "elixir", "vessels_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "health_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "mana_low",
		cure = function () act:drink ("drink mana", "elixir", "mana_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "no_insomnia",
		cure = function () act:insomnia () end,
		bal = "none",
		able = "insomnia",},
	{	name = "mana_low",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "succumb",
		cure = function () act:eat ("eat reishi", "herb", "succumb") end,
		bal = "herb",
		able = "eat",},	
	{	name = "no_truehearing",
		cure = function () act:eat ("eat earwort", "herb", "no_truehearing") end,
		bal = "herb",
		able = "eat",},
	{	name = "ego_critical",
		cure = function () act:drink ("drink bromides", "elixir", "ego_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "ego_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "burstorgans",
		cure = function () act:drink ("apply regeneration to gut", "salve", "burstorgans") end,
		bal = "salve",
		able = "apply",},
	{	name = "disemboweled",
		cure = function () act:drink ("apply regeneration to gut", "salve", "disemboweled") end,
		bal = "salve",
		able = "apply",},
	{	name = "slickness",
		cure = function () act:eat ("eat calamus", "herb", "slickness") end,
		bal = "herb",
		able = "eat",},
	{	name = "stupidity",
		cure = function () act:focus ("focus mind", "focus", "stupidity") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "fracturedskull",
		cure = function () act:apply ("apply mending to head", "salve", "fracturedskull") end,
		bal = "salve",
		able = "apply",},
	{	name = "crucified",
		cure = function () act:writhe ("crucified") end,
		bal = "none",
		able = "writhe_impaled",},
	{	name = "pinleg",
		cure = function () act:writhe ("pinleg") end,
		bal = "none",
		able = "writhe_impaled",},
	{	name = "severedspine",
		cure = function () act:apply ("apply regeneration to gut", "salve", "severedspine") end,
		bal = "salve",
		able = "apply",},
	{	name = "no_kafe",
		cure = function () act:eat ("eat kafe", "herb", "no_kafe") end,
		bal = "herb",
		able = "eat",},
	{	name = "collapsedlungs",
		cure = function () act:apply ("apply regeneration to chest", "salve", "collapsedlungs") end,
		bal = "salve",
		able = "apply",},
	{	name = "asthma",
		cure = function () act:apply ("apply melancholic to chest", "salve", "asthma") end,
		bal = "salve",
		able = "apply",},
	{	name = "blacklung",
		cure = function () act:apply ("apply melancholic to chest", "salve", "blacklung") end,
		bal = "salve",
		able = "apply",},
	{	name = "no_insomnia",
		cure = function () act:eat ("eat merbloom", "herb", "no_insomnia") end,
		bal = "herb",
		able = "eat",},
	{	name = "paralysis",
		cure = function () act:focus ("focus mind", "focus", "paralysis") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "impatience",
		cure = function () act:focus ("focus mind", "focus", "impatience") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "impatience",
		cure = function () act:smoke ("smoke coltsfoot", "herb", "anorexia") end,
		bal = "herb",
		able = "smoke coltsfoot",},
	{	name = "mana_med",
		cure = function () act:drink ("drink mana", "elixir", "mana_med") end,
		bal = "elixir",
		able = "drink",},
	{	name = "mana_med",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "health_med",
		cure = function () act:drink ("drink health", "elixir", "health_med") end,
		bal = "elixir",
		able = "drink",},
	{	name = "vessels_med",
		cure = function () act:drink ("drink health", "elixir", "vessels_med") end,
		bal = "elixir",
		able = "drink",},
	{	name = "health_med",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "sunallergy_2",
		cure = function () act:apply ("apply liniment", "salve", "sunallergy_2") end,
		bal = "salve",
		able = "apply",},
	{	name = "ego_med",
		cure = function () act:drink ("drink bromides", "elixir", "ego_med") end,
		bal = "elixir",
		able = "drink",},
	{	name = "ego_med",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "lacerations_4",
		cure = function () act:eat ("eat yarrow", "herb", "lacerations_4") end,
		bal = "herb",
		able = "eat",},
	{	name = "artery_4",
		cure = function () act:eat ("eat yarrow", "herb", "artery_4") end,
		bal = "herb",
		able = "eat",},
}

sca ["sap_queue"] = {
	{	name = "sap",
		cure = function () act:cleanse () end,
		bal = "none",
		able = "cleanse",},
	{	name = "crotamine_4",
		cure = function () act:drink ("drink antidote", "elixir", "crotamine_4") end,
		bal = "purg",
		able = "drink",},
	{	name = "burstorgans",
		cure = function () act:drink ("apply regeneration to gut", "salve", "burstorgans") end,
		bal = "salve",
		able = "apply",},
	{	name = "disemboweled",
		cure = function () act:drink ("apply regeneration to gut", "salve", "disemboweled") end,
		bal = "salve",
		able = "apply",},
	{	name = "no_metawake",
		cure = function () act:metawake () end,
		bal = "purg",
		able = "none",},
	{	name = "anorexia",
		cure = function () act:smoke ("smoke coltsfoot", "herb", "anorexia") end,
		bal = "herb",
		able = "smoke coltsfoot",},
	{	name = "anorexia",
		cure = function () act:focus ("focus mind", "focus", "anorexia") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "slitthroat",
		cure = function () act:apply ("apply mending to head", "salve", "slitthroat") end,
		bal = "salve",
		able = "apply",},
	{	name = "windpipe",
		cure = function () act:smoke ("smoke myrtle", "herb", "windpipe") end,
		bal = "herb",
		able = "smoke myrtle",},
	{	name = "windpipe",
		cure = function () act:apply ("apply arnica to head", "herb", "windpipe") end,
		bal = "herb",
		able = "apply",},
	{	name = "throatlock",
		cure = function () act:focus ("focus body", "focus", "throatlock") end,
		bal = "focus",
		able = "focus body",},
	{	name = "mana_critical",
		cure = function () act:drink ("drink mana", "elixir", "mana_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "no_truehearing",
		cure = function () act:eat ("eat earwort", "herb", "no_truehearing") end,
		bal = "herb",
		able = "eat",},
	{	name = "mana_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "health_critical",
		cure = function () act:drink ("drink health", "elixir", "health_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "vessels_critical",
		cure = function () act:drink ("drink health", "elixir", "vessels_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "health_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "concussion",
		cure = function () act:apply ("apply regeneration to head", "salve", "concussion") end,
		bal = "salve",
		able = "apply",},
	{	name = "pinleg",
		cure = function () act:writhe ("pinleg") end,
		bal = "none",
		able = "writhe_impaled",},
	{	name = "crucified",
		cure = function () act:writhe ("crucified") end,
		bal = "none",
		able = "writhe_impaled",},
	{	name = "stupidity",
		cure = function () act:focus ("focus mind", "focus", "stupidity")end,
		bal = "focus",
		able = "focus mind",},
	{	name = "fracturedskull",
		cure = function () act:apply ("apply mending to head", "salve", "fracturedskull") end,
		bal = "salve",
		able = "apply",},
	{	name = "mana_low",
		cure = function () act:drink ("drink mana", "elixir", "mana_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "no_insomnia",
		cure = function () act:insomnia () end,
		bal = "none",
		able = "insomnia",},
	{	name = "mana_low",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "succumb",
		cure = function () act:eat ("eat reishi", "herb", "succumb") end,
		bal = "herb",
		able = "eat",},	
	{	name = "slickness",
		cure = function () act:eat ("eat calamus", "herb", "slickness") end,
		bal = "herb",
		able = "eat",},
	{	name = "ego_critical",
		cure = function () act:drink ("drink bromides", "elixir", "ego_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "ego_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "collapsedlungs",
		cure = function () act:apply ("apply regeneration to chest", "salve", "collapsedlungs") end,
		bal = "salve",
		able = "apply",},
	{	name = "asthma",
		cure = function () act:apply ("apply melancholic to chest", "salve", "asthma") end,
		bal = "salve",
		able = "apply",},
	{	name = "blacklung",
		cure = function () act:apply ("apply melancholic to chest", "salve", "blacklung") end,
		bal = "salve",
		able = "apply",},
	{	name = "impaled",
		cure = function () act:writhe ("impaled") end,
		bal = "none",
		able = "writhe_impaled",},
	{	name = "epilepsy",
		cure = function () act:focus ("focus mind", "focus", "epilepsy") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "sunallergy_2",
		cure = function () act:apply ("apply liniment", "salve", "sunallergy_2") end,
		bal = "salve",
		able = "apply",},
	{	name = "crotamine_3",
		cure = function () act:drink ("drink antidote", "elixir", "crotamine_3") end,
		bal = "purg",
		able = "drink",},
	{	name = "health_low",
		cure = function () act:drink ("drink health", "elixir", "health_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "vessels_low",
		cure = function () act:drink ("drink health", "elixir", "vessels_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "health_low",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "powersap",
		cure = function () act:drink ("drink antidote", "elixir", "powersap") end,
		bal = "purg",
		able = "drink",},
	{	name = "ego_low",
		cure = function () act:drink ("drink bromides", "elixir", "ego_low") end,
		bal = "elixir",
		able = "drink",},
	{	name = "ego_low",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "artery_5",
		cure = function () act:eat ("eat yarrow", "herb", "artery_5") end,
		bal = "herb",
		able = "eat",},
	{	name = "lacerations_4",
		cure = function () act:eat ("eat yarrow", "herb", "lacerations_4") end,
		bal = "herb",
		able = "eat",},
	{	name = "artery_4",
		cure = function () act:eat ("eat yarrow", "herb", "artery_4") end,
		bal = "herb",
		able = "eat",},
}

sca ["choke_queue"] = {
	{	name = "no_metawake",
		cure = function () act:metawake () end,
		bal = "purg",
		able = "none",},
	{	name = "mana_critical",
		cure = function () act:drink ("drink mana", "elixir", "mana_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "mana_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "crotamine_4",
		cure = function () act:drink ("drink antidote", "elixir", "crotamine_4") end,
		bal = "purg",
		able = "drink",},
	{	name = "crucified",
		cure = function () act:writhe ("crucified") end,
		bal = "none",
		able = "writhe_impaled",},
	{	name = "pinleg",
		cure = function () act:writhe ("pinleg") end,
		bal = "none",
		able = "writhe_impaled",},
	{	name = "health_critical",
		cure = function () act:drink ("drink health", "elixir", "health_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "vessels_critical",
		cure = function () act:drink ("drink health", "elixir", "vessels_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "health_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "mana_low",
		cure = function () act:drink ("drink mana", "elixir", "mana_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "no_insomnia",
		cure = function () act:insomnia () end,
		bal = "none",
		able = "insomnia",},
	{	name = "mana_low",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "succumb",
		cure = function () act:eat ("eat reishi", "herb", "succumb") end,
		bal = "herb",
		able = "eat",},	
	{	name = "impaled",
		cure = function () act:writhe ("impaled") end,
		bal = "none",
		able = "writhe_impaled",},
	{	name = "no_truehearing",
		cure = function () act:eat ("eat earwort", "herb", "no_truehearing") end,
		bal = "herb",
		able = "eat",},
	{	name = "anorexia",
		cure = function () act:smoke ("smoke coltsfoot", "herb", "anorexia") end,
		bal = "herb",
		able = "smoke coltsfoot",},
	{	name = "anorexia",
		cure = function () act:focus ("focus mind", "focus", "anorexia") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "slitthroat",
		cure = function () act:apply ("apply mending to head", "salve", "slitthroat") end,
		bal = "salve",
		able = "apply",},
	{	name = "windpipe",
		cure = function () act:smoke ("smoke myrtle", "herb", "windpipe") end,
		bal = "herb",
		able = "smoke myrtle",},
	{	name = "windpipe",
		cure = function () act:apply ("apply arnica to head", "herb", "windpipe") end,
		bal = "herb",
		able = "apply",},
	{	name = "throatlock",
		cure = function () act:focus ("focus body", "focus", "throatlock") end,
		bal = "focus",
		able = "focus body",},
	{	name = "ego_critical",
		cure = function () act:drink ("drink bromides", "elixir", "ego_critical") end,
		bal = "elixir",
		able = "drink",},
	{	name = "ego_critical",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "burstorgans",
		cure = function () act:drink ("apply regeneration to gut", "salve", "burstorgans") end,
		bal = "salve",
		able = "apply",},
	{	name = "disemboweled",
		cure = function () act:drink ("apply regeneration to gut", "salve", "disemboweled") end,
		bal = "salve",
		able = "apply",},
	{	name = "no_sixthsense",
		cure = function () act:eat ("eat faeleaf", "herb", "no_sixthsense") end,
		bal = "herb",
		able = "eat",},
	{	name = "slickness",
		cure = function () act:eat ("eat calamus", "herb", "slickness") end,
		bal = "herb",
		able = "eat",},
	{	name = "collapsedlungs",
		cure = function () act:apply ("apply regeneration to chest", "salve", "collapsedlungs") end,
		bal = "salve",
		able = "apply",},
	{	name = "stupidity",
		cure = function () act:focus ("focus mind", "focus", "stupidity") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "fracturedskull",
		cure = function () act:apply ("apply mending to head", "salve", "fracturedskull") end,
		bal = "salve",
		able = "apply",},
	{	name = "concussion",
		cure = function () act:apply ("apply regeneration to head", "salve", "concussion") end,
		bal = "salve",
		able = "apply",},
	{	name = "asthma",
		cure = function () act:apply ("apply melancholic to chest", "salve", "asthma") end,
		bal = "salve",
		able = "apply",},
	{	name = "blacklung",
		cure = function () act:apply ("apply melancholic to chest", "salve", "blacklung") end,
		bal = "salve",
		able = "apply",},
	{	name = "severedspine",
		cure = function () act:apply ("apply regeneration to gut", "salve", "severedspine") end,
		bal = "salve",
		able = "apply",},
	{	name = "entangled",
		cure = function () act:writhe ("entangled") end,
		bal = "none",
		able = "writhe",},
	{	name = "shackled",
		cure = function () act:writhe ("shackled") end,
		bal = "none",
		able = "writhe",},
	{	name = "transfixed",
		cure = function () act:writhe ("transfixed") end,
		bal = "none",
		able = "writhe",},
	{	name = "roped",
		cure = function () act:writhe ("roped") end,
		bal = "none",
		able = "writhe",},
	{	name = "trussed",
		cure = function () act:writhe ("trussed") end,
		bal = "none",
		able = "writhe",},
	{	name = "paralysis",
		cure = function () act:focus ("focus body", "focus", "paralysis") end,
		bal = "focus",
		able = "focus body",},
	{	name = "impatience",
		cure = function () act:focus ("focus mind", "focus", "impatience") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "impatience",
		cure = function () act:smoke ("smoke coltsfoot", "herb", "anorexia") end,
		bal = "herb",
		able = "smoke coltsfoot",},
	{	name = "tendon_rightleg",
		cure = function () act:apply ("apply regeneration to legs", "salve", "tendon_rightleg") end,
		bal = "salve",
		able = "apply",},
	{	name = "tendon_leftleg",
		cure = function () act:apply ("apply regeneration to legs", "salve", "tendon_leftleg") end,
		bal = "salve",
		able = "apply",},
	{	name = "amputated_leftleg",
		cure = function () act:apply ("apply regeneration to legs", "salve", "amputated_leftleg") end,
		bal = "salve",
		able = "apply",},
	{	name = "amputated_righftleg",
		cure = function () act:apply ("apply regeneration to legs", "salve", "amputated_rightleg") end,
		bal = "salve",
		able = "apply",},
	{	name = "mangled_leftleg",
		cure = function () act:apply ("apply regeneration to legs", "salve", "mangled_leftleg") end,
		bal = "salve",
		able = "apply",},
	{	name = "mangled_rightleg",
		cure = function () act:apply ("apply regeneration to legs", "salve", "mangled_rightleg") end,
		bal = "salve",
		able = "apply",},
	{	name = "shatteredankle_rightleg",
		cure = function () act:apply ("apply regeneration to legs", "salve", "shatteredankle_rightleg") end,
		bal = "salve",
		able = "apply",},
	{	name = "shatteredankle_leftleg",
		cure = function () act:apply ("apply regeneration to legs", "salve", "shatteredankle_leftleg") end,
		bal = "salve",
		able = "apply",},
	{ 	name = "hemiplegy_lower",
		cure = function () act:smoke ("smoke myrtle", "herb", "hemiplegy_lower") end,
		bal = "herb",
		able = "smoke myrtle",},
	{	name = "hemiplegy_left",
		cure = function () act:smoke ("smoke myrtle", "herb", "hemiplegy_left") end,
		bal = "herb",
		able = "smoke myrtle",},
	{	name = "hemiplegy_right",
		cure = function () act:smoke ("smoke myrtle", "herb", "hemiplegy_right") end,
		bal = "herb",
		able = "smoke myrtle",},
	{	name = "broken_leftleg",
		cure = function () act:apply ("apply mending to arms", "salve", "broken_rightarm") end,
		bal = "salve",
		able = "apply",},
	{  name = "broken_rightleg",
		cure = function () act:apply ("apply mending to arms", "salve", "broken_rightarm") end,
		bal = "salve",
		able = "apply",},
	{	name = "collapsednerve_rightarm",
		cure = function () act:apply ("apply regeneration to arms", "salve", "collapsednerve_rightarm") end,
		bal = "salve",
		able = "apply",},
	{	name = "collapsednerve_leftarm",
		cure = function () act:apply ("apply regeneration to arms", "salve", "collapsednerve_leftarm") end,
		bal = "salve",
		able = "apply",},
	{	name = "amputated_leftarm",
		cure = function () act:apply ("apply regeneration to arms", "salve", "amputated_leftarm") end,
		bal = "salve",
		able = "apply",},
	{	name = "amputated_righftarm",
		cure = function () act:apply ("apply regeneration to arms", "salve", "amputated_rightarm") end,
		bal = "salve",
		able = "apply",},
	{	name = "mangled_leftarm",
		cure = function () act:apply ("apply regeneration to arms", "salve", "mangled_leftarm") end,
		bal = "salve",
		able = "apply",},
	{	name = "mangled_rightarm",
		cure = function () act:apply ("apply regeneration to arms", "salve", "mangled_rightarm") end,
		bal = "salve",
		able = "apply",},
	{	name = "broken_leftarm",
		cure = function () act:apply ("apply mending to arms", "salve", "broken_rightarm") end,
		bal = "salve",
		able = "apply",},
	{  name = "broken_rightarm",
		cure = function () act:apply ("apply mending to arms", "salve", "broken_rightarm") end,
		bal = "salve",
		able = "apply",},
	{	name = "crotamine_3",
		cure = function () act:drink ("drink antidote", "elixir", "crotamine_4") end,
		bal = "purg",
		able = "drink",},
	{	name = "no_kafe",
		cure = function () act:eat ("eat kafe", "herb", "no_kafe") end,
		bal = "herb",
		able = "eat",},
	{	name = "no_insomnia",
		cure = function () act:eat ("eat merbloom", "herb", "no_insomnia") end,
		bal = "herb",
		able = "eat",},
	{	name = "mana_med",
		cure = function () act:drink ("drink mana", "elixir", "mana_med") end,
		bal = "elixir",
		able = "drink",},
	{	name = "mana_med",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "epilepsy",
		cure = function () act:focus ("focus mind", "focus", "epilepsy") end,
		bal = "focus",
		able = "focus mind",},
	{	name = "health_med",
		cure = function () act:drink ("drink health", "elixir", "health_med") end,
		bal = "elixir",
		able = "drink",},
	{	name = "vessels_med",
		cure = function () act:drink ("drink health", "elixir", "vessels_med") end,
		bal = "elixir",
		able = "drink",},
	{	name = "health_med",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "sunallergy_2",
		cure = function () act:apply ("apply liniment", "salve", "sunallergy_2") end,
		bal = "salve",
		able = "apply",},
	{	name = "artery_5",
		cure = function () act:eat ("eat yarrow", "herb", "artery_5") end,
		bal = "herb",
		able = "eat",},
	{	name = "ego_med",
		cure = function () act:drink ("drink bromides", "elixir", "ego_med") end,
		bal = "elixir",
		able = "drink",},
	{	name = "ego_med",
		cure = function () act:read ("healing") end,
		bal = "scroll",
		able = "read",},
	{	name = "lacerations_4",
		cure = function () act:eat ("eat yarrow", "herb", "lacerations_4") end,
		bal = "herb",
		able = "eat",},
	{	name = "artery_4",
		cure = function () act:eat ("eat yarrow", "herb", "artery_4") end,
		bal = "herb",
		able = "eat",},
}


sca ["able"] = {
	["cleanse"] = {
		{	name = "pinleg",
			cure = function () act:writhe ("pinleg") end,
			bal = "none",
			able = "writhe_impaled",},
		{	name = "transfixed",
			cure = function () act:writhe ("transfixed") end,
			bal = "none",
			able = "writhe",},
		{	name = "clamped_leftarm",
			cure = function () act:writhe ("clamped_leftarm") end,
			bal = "none",
			able = "writhe",},
		{	name = "clamped_rightarm",
			cure = function () act:writhe ("clamped_rightarm") end,
			bal = "none",
			able = "writhe",},
		{	name = "prone",
			cure = function () act:stand () end,
			bal = "none",
			able = "stand",},
		{	name = "disrupted",
			cure = function () act:concentrate () end,
			bal = "none",
			able = "concentrate",},
		{	name = "entangled",
			cure = function () act:writhe ("entangled") end,
			bal = "none",
			able = "writhe",},
		{	name = "paralysis",
			cure = function () act:focus ("focus body", "focus", "paralysis") end,
			bal = "focus",
			able = "focus body",},
		{	name = "roped",
			cure = function () act:writhe ("roped") end,
			bal = "none",
			able = "writhe",},
		{	name = "crucified",
			cure = function () act:writhe ("crucified") end,
			bal = "none",
			able = "writhe_impaled",},
		{	name = "shackled",
			cure = function () act:writhe ("shackled") end,
			bal = "none",
			able = "writhe",},
	},
	["stand"] = {
		{	name = "pinleg",
			cure = function () act:writhe ("pinleg") end,
			bal = "none",
			able = "writhe_impaled",},
		{	name = "impaled",
			cure = function () act:writhe ("impaled") end,
			bal = "none",
			able = "writhe_impaled",},
		{	name = "crucified",
			cure = function () act:writhe ("crucified") end,
			bal = "none",
			able = "writhe_impaled",},
		{	name = "entangled",
			cure = function () act:writhe ("entangled") end,
			bal = "none",
			able = "writhe",},
		{	name = "shackled",
			cure = function () act:writhe ("shackled") end,
			bal = "none",
			able = "writhe",},
		{	name = "transfixed",
			cure = function () act:writhe ("transfixed") end,
			bal = "none",
			able = "writhe",},
		{	name = "roped",
			cure = function () act:writhe ("roped") end,
			bal = "none",
			able = "writhe",},
		{	name = "trussed",
			cure = function () act:writhe ("trussed") end,
			bal = "none",
			able = "writhe",},
		{	name = "paralysis",
			cure = function () act:focus ("focus body", "focus", "paralysis") end,
			bal = "focus",
			able = "focus body",},
		{	name = "severedspine",
			cure = function () act:apply ("apply regeneration to gut", "salve", "severedspine") end,
			bal = "salve",
			able = "apply",},
		{	name = "tendon_rightleg",
			cure = function () act:apply ("apply regeneration to legs", "salve", "tendon_rightleg") end,
			bal = "salve",
			able = "apply",},
		{	name = "tendon_leftleg",
			cure = function () act:apply ("apply regeneration to legs", "salve", "tendon_leftleg") end,
			bal = "salve",
			able = "apply",},
		{	name = "amputated_leftleg",
			cure = function () act:apply ("apply regeneration to legs", "salve", "amputated_leftleg") end,
			bal = "salve",
			able = "apply",},
		{	name = "amputated_righftleg",
			cure = function () act:apply ("apply regeneration to legs", "salve", "amputated_rightleg") end,
			bal = "salve",
			able = "apply",},
		{	name = "mangled_leftleg",
			cure = function () act:apply ("apply regeneration to legs", "salve", "mangled_leftleg") end,
			bal = "salve",
			able = "apply",},
		{	name = "mangled_rightleg",
			cure = function () act:apply ("apply regeneration to legs", "salve", "mangled_rightleg") end,
			bal = "salve",
			able = "apply",},
		{	name = "shatteredankle_rightleg",
			cure = function () act:apply ("apply regeneration to legs", "salve", "shatteredankle_rightleg") end,
			bal = "salve",
			able = "apply",},
		{	name = "shatteredankle_leftleg",
			cure = function () act:apply ("apply regeneration to legs", "salve", "shatteredankle_leftleg") end,
			bal = "salve",
			able = "apply",},
		{	name = "broken_leftleg",
			cure = function () act:apply ("apply mending to legs", "salve", "broken_rightleg") end,
			bal = "salve",
			able = "apply",},
		{  name = "broken_rightleg",
			cure = function () act:apply ("apply mending to legs", "salve", "broken_rightleg") end,
			bal = "salve",
			able = "apply",},
		{ 	name = "hemiplegy_lower",
			cure = function () act:smoke ("smoke myrtle", "herb", "hemiplegy_lower") end,
			bal = "herb",
			able = "smoke myrtle",},
		{	name = "hemiplegy_left",
			cure = function () act:smoke ("smoke myrtle", "herb", "hemiplegy_left") end,
			bal = "herb",
			able = "smoke myrtle",},
		{	name = "hemiplegy_right",
			cure = function () act:smoke ("smoke myrtle", "herb", "hemiplegy_right") end,
			bal = "herb",
			able = "smoke myrtle",},
		{	name = "leglock",
			cure = function () act:focus ("focus body", "focus", "leglock") end,
			bal = "focus",
			able = "focus body",},
	},
	["concentrate"] = {
		{	name = "confusion",
			cure = function () act:drink ("drink sanguine", "purg", "confusion") end,
			bal = "purg",
			able = "drink",},
		{	name = "confusion",
			cure = function () act:focus ("focus mind", "focus", "confusion") end,
			bal = "focus",
			able = "focus mind",},
		{	name = "confusion",
			cure = function () act:eat ("eat pennyroyal", "herb", "confusion") end,
			bal = "herb",
			able = "eat",},
	},
	["apply"] = {
		{	name = "slickness",
			cure = function () act:eat ("eat calamus", "herb", "slickness") end,
			bal = "herb",
			able = "eat",},
				--[2] = {["crucified"] = "writhe_impaled"}, --I'm already taking care of this in the stand check
	},
	["focus body"] = {
		{	name = "impatience",
			cure = function () act:focus ("focus mind", "focus", "impatience") end,
			bal = "focus",
			able = "focus mind",},
		{	name = "impatience",
			cure = function () act:smoke ("smoke coltsfoot", "herb", "anorexia") end,
			bal = "herb",
			able = "smoke coltsfoot",},
		{	name = "mana_critical",
			cure = function () act:read ("healing") end,
			bal = "scroll",
			able = "read",},
		{	name = "mana_critical",
			cure = function () act:drink ("drink mana", "elixir", "mana_critical") end,
			bal = "elixir",
			able = "drink",},
	},
	["smoke myrtle"] = {
		{	name = "asthma",
			cure = function () act:apply ("apply melancholic to chest", "salve", "asthma") end,
			bal = "salve",
			able = "apply",},
		{	name = "collapsedlungs",
			cure = function () act:apply ("apply regeneration to chest", "salve", "collapsedlungs") end,
			bal = "salve",
			able = "apply",},
		{	name = "blacklung",
			cure = function () act:apply ("apply melancholic to chest", "salve", "blacklung") end,
			bal = "salve",
			able = "apply",},
		{	name = "pipes_unlit",
			cure = function () act:light () end,
			bal = "none",
			able = "pipes light",},
		{	name = "pipes_refill",
			cure = function () act:refill () end,
			bal = "none",
			able = "pipes refill",},
	},
	["drink"] = {
		{	name = "anorexia",
			cure = function () act:smoke ("smoke coltsfoot", "herb", "anorexia") end,
			bal = "herb",
			able = "smoke coltsfoot",},
		{	name = "anorexia",
			cure = function () act:focus ("focus mind", "focus", "anorexia") end,
			bal = "focus",
			able = "focus mind",},
		{	name = "slitthroat",
			cure = function () act:apply ("apply mending to head", "salve", "slitthroat") end,
			bal = "salve",
			able = "apply",},
		{	name = "windpipe",
			cure = function () act:smoke ("smoke myrtle", "herb", "windpipe") end,
			bal = "herb",
			able = "smoke myrtle",},
		{	name = "windpipe",
			cure = function () act:apply ("apply arnica to head", "herb", "windpipe") end,
			bal = "herb",
			able = "apply",},
		{	name = "throatlock",
			cure = function () act:focus ("focus body", "focus", "throatlock") end,
			bal = "focus",
			able = "focus body",},
	},
	["focus mind"] = {
		{	name = "mana_critical",
			cure = function () act:read ("healing") end,
			bal = "scroll",
			able = "read",},
		{	name = "mana_critical",
			cure = function () act:drink ("drink mana", "elixir", "mana_critical") end,
			bal = "elixir",
			able = "drink",},
		{	name = "crucified",
			cure = function () act:writhe ("crucified") end,
			bal = "none",
			able = "writhe_impaled",},
	},
	["eat"] = {
		{	name = "anorexia",
			cure = function () act:smoke ("smoke coltsfoot", "herb", "anorexia") end,
			bal = "herb",
			able = "smoke coltsfoot",},
		{	name = "anorexia",
			cure = function () act:focus ("focus mind", "focus", "anorexia") end,
			bal = "focus",
			able = "focus mind",},
		{	name = "slitthroat",
			cure = function () act:apply ("apply mending to head", "salve", "slitthroat") end,
			bal = "salve",
			able = "apply",},
		{	name = "windpipe",
			cure = function () act:smoke ("smoke myrtle", "herb", "windpipe") end,
			bal = "herb",
			able = "smoke myrtle",},
		{	name = "windpipe",
			cure = function () act:apply ("apply arnica to head", "herb", "windpipe") end,
			bal = "herb",
			able = "apply",},
		{	name = "throatlock",
			cure = function () act:focus ("focus body", "focus", "throatlock") end,
			bal = "focus",
			able = "focus body",},
	},
	["smoke coltsfoot"] = {
		{	name = "asthma",
			cure = function () act:apply ("apply melancholic to chest", "salve", "asthma") end,
			bal = "salve",
			able = "apply",},
		{	name = "collapsedlungs",
			cure = function () act:apply ("apply regeneration to chest", "salve", "collapsedlungs") end,
			bal = "salve",
			able = "apply",},
		{	name = "blacklung",
			cure = function () act:apply ("apply melancholic to chest", "salve", "blacklung") end,
			bal = "salve",
			able = "apply",},
		{	name = "pipes_unlit",
			cure = function () act:light () end,
			bal = "none",
			able = "pipes light",},
		{	name = "pipes_refill",
			cure = function () act:refill () end,
			bal = "none",
			able = "pipes refill",},
	},
	["pipes_refill"] = {
		{	name = "amputated_leftarm",
			cure = function () act:apply ("apply regeneration to arms", "salve", "amputated_leftarm") end,
			bal = "salve",
			able = "apply",},
		{	name = "amputated_rightarm",
			cure = function () act:apply ("apply regeneration to arms", "salve", "amputated_rightarm") end,
			bal = "salve",
			able = "apply",},
		{	name = "mangled_leftarm",
			cure = function () act:apply ("apply regeneration to arms", "salve", "mangled_leftarm") end,
			bal = "salve",
			able = "apply",},
		{	name = "mangled_rightarm",
			cure = function () act:apply ("apply regeneration to arms", "salve", "mangled_rightarm") end,
			bal = "salve",
			able = "apply",},
		{	name = "broken_leftarm",
			cure = function () act:apply ("apply mending to arms", "salve", "broken_leftarm") end,
			bal = "salve",
			able = "apply",},
		{	name = "broken_rightarm",
			cure = function () act:apply ("apply mending to arms", "salve", "broken_rightarm") end,
			bal = "salve",
			able = "apply",},
		{	name = "hemiplegy_right",
			cure = function () act:smoke ("smoke myrtle", "herb", "hemiplegy_left") end,
			bal = "herb",
			able = "smoke myrtle",},
		{	name = "hemiplegy_left",
			cure = function () act:smoke ("smoke myrtle", "herb", "hemiplegy_right") end,
			bal = "herb",
			able = "smoke myrtle",},
	},
	["read"] = {
		{	name = "blindness",
			cure = function () act:eat ("eat myrtle", "herb", "blindness") end,
			bal = "herb",
			able = "eat",},
		{	name = "no_sixthsense",
			cure = function () act:eat ("eat faeleaf", "herb", "no_sixthsense") end,
			bal = "herb",
			able = "eat",},
		{	name = "peckedeye_left",
			cure = function () act:apply ("apply regeneration to head", "salve", "peckedeye_left") end,
			bal = "salve",
			able = "apply",},
		{	name = "peckedeye_right",
			cure = function () act:apply ("apply regeneration to head", "salve", "peckedeye_right") end,
			bal = "salve",
			able = "apply",},
	},
	["insomnia"] = {
		{	name = "narcolepsy",
			cure = function () act:eat ("eat kafe", "herb", "narcolepsy") end,
			bal = "herb",
			able = "eat",},
		{	name = "narcolepsy",
			cure = function () act:drink ("drink allheale", "ah", "narcolepsy") end,
			bal = "ah",
			able = "drink",},
		{	name = "hypersomnia",
			cure = function () act:eat ("eat kafe", "herb", "hypersomnia") end,
			bal = "herb",
			able = "eat",},
		{	name = "hypersomnia",
			cure = function () act:drink ("drink allheale", "ah", "hypersomnia") end,
			bal = "ah",
			able = "drink",},
		{	name = "pinleg",
			cure = function () act:writhe ("pinleg") end,
			bal = "none",
			able = "writhe_impaled",},
		{	name = "crucified",
			cure = function () act:writhe ("crucified") end,
			bal = "none",
			able = "writhe_impaled",},
	},
}


return sca