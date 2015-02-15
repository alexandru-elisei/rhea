--[[
	DEALS WITH  AFFLICTION CURING
]]--

	
require "able"
require "affs"
require "flags"
require "act"
require "display"
	
if not scan then
	scan = {}
end --if

	--checking if i am locked
function scan.is_locked ()

	if
		(not able:to ("smoke") and
		not able:to ("eat") and --identical to able:to ("eat")
		not able:to ("apply")) or
		(affs:has ("slitthroat") and affs:has ("slickness"))
			then
		return true
	end--if
	
	return false
	
end --function

	
	--checking if I need to cure asthma in aeon or sap
function scan.tocure_asthma (sca)

	if sca == "aeon" then
		if
			affs:has ("windpipe") or
			affs:has ("anorexia") or
			(affs:has ("throatlock") and affs:has ("impatience"))
				then
			if not pipes:is_lit ("myrtle") then
				return "myrtle unlit"
			elseif pipes:is_empty ("myrtle") then
				return "myrtle empty"
			else
				return "smoking needed"
			end --if
		end --if
	end --if
	
	return "smoking not needed"
	
end --function


	--checking if I need to cure slickness in aeon or sap
function scan.tocure_slickness (sca)

	if sca == "aeon" then
		if 
			(affs:has ("windpipe") and not able:to ("apply") and not able:to ("smoke myrtle")) or
			affs:has ("slitthroat") or
			(affs:has ("asthma") and scan.tocure_asthma (sca) == "smoking needed")
				then
			return true
		end --if
	end --if
	
	return false
	
end --function

	--checking if I need to powercure in aeon, sap, choke
function scan.tocure_powercure (sca)

	if sca == "sap" then
		local cs, ws = able:to ("stand")
		if 
			(affs:has ("disrupted") and affs:has ("confusion") and not able:to ("drink") and not able:to ("focus mind")) or
			(ws and affs ["cures"] ["salve"] [ws] and scan.is_locked ()) or
			(affs:has ("paralysys") and affs:has ("impatience") and not able:to ("focus mind") and not able:to ("smoke coltsfoot"))
				then
			return true
		end--if
	end --if
	
	return false

end --tocure_powercure

	--checking if I need to use restore to get out of sticky situations
function scan.tocure_restore (sca)

	if sca == "sap" then
		local cs, ws = able:to ("stand")
		if
			affs:has ("prone") and
			ws and (ws == "broken_leftleg" or ws == "broken_rightleg") and
			scan.is_locked ()
				then
			return true
		end --if
	end --if
	
	return false
	
end --function

	--curing health, mana or ego, if needed
function scan.healing ()
	
	if affs:has ("blackout") then
		if 	flags:get_check ("reset_hme") and
			system:is_auto ("hme") and
			bals:has ("elixir")
				then
			if 	not affs:has ("health_critical") and
				not affs:has ("health_low") and
				not affs:has ("health_med") and
				not affs:has ("mana_critical") and
				not affs:has ("mana_low") and
				not affs:has ("mana_med") and
				not affs:has ("ego_critical") and
				not affs:has ("ego_low") and
				not affs:has ("ego_med")
					then
				affs:add (system ["hme_priority"].."_med", true, "silent")
			end --if
			flags:del_check ("reset_hme")
		end --if
		affs:del ({"eat_sparklies", "read_healing"})
		if able:to ("read healing") and not flags:get ("healing") then
			affs:add ("read_healing", true, "silent")
		end --if
		if
			system:is_auto ("sparklies") and
			bals:has ("sparklies") and
			able:to ("eat") and
			not sca:is_slowed ()
				then
			affs:add ("eat_sparklies", true, "silent")
		end --if
		return
	end --if

		--resetting scans
	affs:del ({"eat_sparklies", "read_healing"})
		
		--health reduction coefficient
	local hr = 1
	if affs:has ("illusory_wounds") then
		hr = 2/3
	end--if
		
		--for ease of use
	local max_stats = {}
	max_stats ["health"] = prompt ["vitals"] ["max_health"]*hr
	max_stats ["ego"] = prompt ["vitals"] ["max_ego"]*hr
	max_stats ["mana"] = prompt ["vitals"] ["max_mana"]*hr
	local stats = {}
	stats ["health"] = prompt ["vitals"] ["c_health"]
	stats ["mana"] = prompt ["vitals"] ["c_mana"]
	stats ["ego"] = prompt ["vitals"] ["c_ego"]
		
		--no need for further curing if there isn't any damage to stats
	if 
		stats ["health"]>=max_stats ["health"] and
		stats ["mana"]>=max_stats ["mana"] and
		stats ["ego"]>=max_stats ["ego"] and
		not affs:has ("recklessness")
			then
		if bals:has ("elixir") then
			affs:del ({"health_critical", "health_med", "health_low", "mana_critical", "mana_med", "mana_low", "ego_critical", "ego_med", "ego_low",})
		end--if
		return
	end --if	
		
		--scroll of healing first
	if 
		able:to ("read healing") and
		not flags:get ("healing")
			then
		if affs:has ("recklessness") then
			affs:add_simple ("read_healing", true, "silent")
		else
			for s, v in pairs (stats) do
				if v+max_stats[s]*.10<=max_stats[s] then
					affs:add_simple ("read_healing", true, "silent")
					stats ["health"] = stats ["health"]+max_stats ["health"]*.10
					stats ["mana"] = stats ["mana"]+max_stats ["mana"]*.10
					stats ["ego"] = stats ["ego"]+max_stats ["ego"]*.10
					break
				end--if
			end --for
		end --if
	end --if
		
		--sparklies second; I don't eat sparklies in sca
	if 
		system:is_auto ("sparklies") and
		bals:has ("sparklies") and
		able:to ("eat") and
		not sca:is_slowed ()
			then
		if affs:has ("vessels_critical") or affs:has ("vessels_low") or affs:has ("vessels_med") then
			affs:add_simple ("eat_sparklies", true, "silent")
		elseif affs:has ("recklessness") then
			affs:add_simple ("eat_sparklies", true, "silent")
		else
			for s, v in pairs (stats) do
				if v+max_stats [s]*.10<=max_stats[s] then
					affs:add_simple ("eat_sparklies", true, "silent")
					stats ["health"] = stats ["health"]+max_stats ["health"]*.10
					stats ["mana"] = stats ["mana"]+max_stats ["mana"]*.10
					stats ["ego"] = stats ["ego"]+max_stats ["ego"]*.10
					break
				end--if
			end --for
		end --if
	end --if
			
		--health
	if
		system:is_auto ("hme") and
		bals:has ("elixir")
			then
		if not affs:has ("recklessness") then
			affs:del ({"health_critical", "health_med", "health_low", "mana_critical", "mana_med", "mana_low", "ego_critical", "ego_med", "ego_low",})
			i = 1
			repeat
				for k, stat in ipairs (system ["hme_queues"] [system ["hme_priority"]]) do
					if 
						stats [stat] < max_stats [stat] * system ["hme_threshold"] [i] then
						affs:add (stat.."_"..tostring (system ["hme_afflictions"] [i]), true, "silent")
						i = 3
						display.deb ("SCAN.HEALING -> queuing "..stat..tostring (system ["hme_afflictions"] [i]))
						break
					end --if
				end --for
				i = i +1
			until i>3
				--autohealing if I have recklessness
		elseif not affs:has ("health_critical") and
			not affs:has ("health_low") and
			not affs:has ("health_med") and
			not affs:has ("mana_critical") and
			not affs:has ("mana_low") and
			not affs:has ("mana_med") and
			not affs:has ("ego_critical") and
			not affs:has ("ego_low") and
			not affs:has ("ego_med")
				then
			affs:add (system ["hme_priority"].."_med", true, "silent")
		end --if
	end --if
	
	--[[
		--need to check in what queue to add transmutting
	if system:is_enabled ("transmute") then
		affs:del ("transmute")
		if
			prompt ["vitals"] ["c_health"] <= max_stats ["health"]*system ["hme_threshold"] [1] and
			system ["hme_priority"] ~= "mana" and
			prompt ["vitals"] ["c_mana"] >= able ["focus_cost"] ["mind"] and
			able:to ("transmute") and
			not flags:get ("transmute")
				then
			local to_transmute = 1000
			if prompt ["vitals"] ["c_mana"]-able ["focus_cost"] ["mind"] < to_transmute then
				to_transmute = prompt ["vitals"] ["c_mana"]-able ["focus_cost"] ["mind"]
			end --if
			affs:add ("transmute", to_transmute, "silent")
		end --if
	end --if
	--]]

end --scan.healing
	
	--elixir curing, health/mana/ego, purgative, ah, speed, moonwater and tea
function scan.elixir ()
	
	if system:is_auto ("fire") and not defs:has ("fire") then
		affs:add ("no_fire", true, "silent")
	end --if
	
	if system:is_auto ("frost") and not defs:has ("frost") then
		affs:add ("no_frost", 1, "silent")
	end --if
		
	if system:is_auto ("galvanism") and not defs:has ("galvanism") then
		affs:add ("no_galvanism", 1, "silent")
	end --if
	
	if system:is_auto ("speed") and not defs:has ("speed") then
		affs:add_simple ("no_speed", true, "silent")
	end --if
	
	if system:is_auto ("love") and not affs:has ("love") then
		affs:add_simple ("no_love", true, "silent")
	end --if
	
	if sca:is_slowed () then
		return
	end --if

		--creating a local list of afflictions
	local local_affs= affs:copy ("elixir")
	
	if affs:has ("no_speed") and able:to ("adrenaline") then
		local_affs ["no_speed"] = nil
	end --if
			--maybe make something similar for choke?
	if
		next (affs ["ninshi"]) and
		next (local_affs) and
		wounds:get ()
			then
		for aff, c in pairs (local_affs) do
			local cure = (affs:get_cure ("elixir", aff) or "nil")
			if
				string.find (cure, "apply") and
				not string.find (cure, "critical") and
				not string.find (cure, "extra_heavy") and
				(affs ["ninshi"] [string.sub (cure, 17)] or
				(string.sub (aff, 17) == "legs" and (affs ["ninshi"] ["rightleg"] or affs ["ninshi"] ["leftleg"])) or
				(string.sub (aff, 17) == "arms" and (affs ["ninshi"] ["rightarm"] or affs ["ninshi"] ["leftarm"])))
					then
				local_affs [aff] = nil
			end --if
		end --for
	end --if	
				
	if system:is_auto ("love") then
		local_affs ["love"] = nil
	end --if
	
	local is_drinking = false
	if
		bals:get ("elixir") == 0.5 and not string.find ((flags:get ("applying") or "nil"), "apply_health_to_") or
		bals:get ("purg") == 0.5 or
		bals:get ("speed") == 0.5 or
		bals:get ("ah") == 0.5 or
		bals:get ("brew") == 0.5 or
		flags:get ("orgpotion")
			then
		is_drinking = true
	end --if
	
	if next (local_affs) then		
		for k, aff in ipairs (affs ["elixir"]) do
			if
				local_affs [aff] and
				not flags:get (aff)
					then
				local cure = affs:get_cure ("elixir", aff)
				if string.find (cure, "apply") then
					if
						bals:has ("elixir") and
						able:to ("apply") and
						not flags:get ("applying")
							then							
						if able:to ("medbag") then--if I can apply medbag
							medbag.apply (string.sub (local_affs [aff], 11)) --medbag_apply ("legs"); local_affs ["wounds_critical"] = "health to legs"; affs ["wounds_critical"] = "apply health to legs", it will be added when you add wounds
						else
							act:apply (cure, "elixir", aff)
							return
						end --if
					end--if
				else
					local bal = affs:get_bal (affs:get_cure ("elixir", aff))
					if bals:has (bal) and able:to ("eat") then--if I am not trying to cure wounds
						if bal == "elixir" and able:to ("medbag") then
							medbag.use (aff)
							return
						elseif not is_drinking then --else I either drink health/mana/ego, or the cure for the affliction (purgative or speed balance)
							act:drink (affs:get_cure ("elixir", aff), bal, aff)
							is_drinking = true
							return
						end --if			
					end--if
				end --if
			end --if
		end --for
	end --if
	
	if
		not is_drinking and
		system:is_auto ("orgpotion") and
		not defs:has ("orgpotion") and
		not flags:get ("orgpotion") and
		not flags:get ("ondef_orgpotion") and
		not affs:has ("blackout")
			then
		act:orgpotion ()
		return
	end --if
	
	if
		not is_drinking and
		system:is_auto ("tea") and
		not defs:has ("tea") and
		not flags:get ("brew") and
		bals:has ("brew")
			then
		act:tea ()
		return
	end --if
	
end --function
	
	--herb curing
function scan.herb ()
	
	if system:is_auto ("sixthsense") and not defs:has ("sixthsense") then
		affs:add ("no_sixthsense", true, "silent")
	end --if
	
	if system:is_auto ("truehearing") and not defs:has ("truehearing") then
		affs:add ("no_truehearing", true, "silent")
	end --if
	
	if system:is_auto ("rebound") and not defs:has ("rebound") then
		affs:add ("no_rebound", true, "silent")
	end --if
	
	if system:is_auto ("kafe") and not defs:has ("kafe") then
		affs:add ("no_kafe", true, "silent")
	end --if
	
	if sca:is_slowed () then
		return
	end --if
	

		--if I have herb balance 
	if bals:has ("herb") then
			--first I deal with windpipe, can do little while windpipe
		if affs:has ("windpipe") then
			if not flags:get ("windpipe") then
				if able:to ("apply") then
					act:apply ("apply arnica to head", "herb", "windpipe")
				elseif able:to ("smoke myrtle") and not flags:get ("smoking") then
					act:smoke ("smoke myrtle", "herb", "windpipe")
				end --if
			end --if
		else
		
				--I create a copy of the afflictions to play with
			local local_affs = affs:copy ("herb")
			if 	affs:has ("no_truehearing") and
				affs:has ("blanknote")
					then
				local_affs ["no_truehearing"] = nil
			end--if
				--healers can use the neurosis auro on you to force you insomnia?
			if able:to ("insomnia") then --I can not use insomnia instead of eating merbloom
				local_affs ["no_insomnia"] = nil
			end --if
			--[[
				--will cure stupidity with focus mind
			if
				local_affs ["stupidity"] and
				not flags:get ("stupidity") and
				system ["hme_priority"] ~= "mana" and
				able:to ("focus mind") and
				bals:has ("focus") and
				not affs:has ("mana_critical")
					then
				local_affs ["stupidity"] = nil
			end --if]]--
			
			if  local_affs then
				
					--removing/adding afflictions to the herb affliction list as necessary
				if affs:has ("bedeviled") then
					local_affs ["recklessness"] = nil
				end --if
				if affs:has ("collapsednerve_rightarm") then
					local_affs ["hemiplegy_right"] = nil
				end --if
				if affs:has ("collapsednerve_leftarm") then
					local_affs ["hemiplegy_left"] = nil
				end --if
					-- Don't try to cure stiff body parts while still grappled with Ootangk
				if next (affs ["ootangk"]) then
					for k, v in pairs (affs ["ootangk"]) do
						local_affs ["stiff_"..k] = nil
					end --for
				end --if
				if affs:has ("crushedchest") then
					local_affs ["brokenchest"] = nil
				end --if
				if affs:has ("jinx") then
					if affs:is_mental () then
						local_affs ["jinx"] = nil
					end --if
				end --if
					--don't eat horehound while in maestoso
				if affs:has ("maestoso") then
					for a, v in pairs (local_affs) do
						if (affs ["cures"] ["herb"] [a] or "nil")== "eat horehound" then
							local_affs [a] = nil
							affs:add_custom ("maestoso", "elixir", "drink allheale", nil, true)
						end --if
					end --for
				end --if
				if
					affs:has ("peckedeye_left") and
					affs:has ("peckedeye_right")
						then
					local_affs ["blindness"] = nil
				end --if
				
					--taking care of the actual curing
				for k, aff in ipairs (affs ["herb"]) do
					if
						local_affs [aff] and 
						not flags:get (aff) -- IF I tried to smoke, or apply arnica and the cure didn't go through do to something bad, I will reset the flags: I won't be able:to apply or smoke, but I will eat.
							then
						if
							string.find (affs:get_cure ("herb", aff), "smoke") and
							able:to (affs:get_cure ("herb", aff)) and--able:to ("smoke myrtle")
							not flags:get ("smoking")	
								then
							act:smoke (affs:get_cure ("herb", aff), "herb", aff) --maybe make all events get the cure for themselves by specifying only the balance?
							break
						elseif 
							affs:is_cure ("arnica", "herb", aff) and
							able:to ("apply")
								then
							act:apply (affs:get_cure ("herb", aff), "herb", aff)
							break
						elseif 
							able:to ("eat") and
							not affs:is_cure ("smoke", "herb", aff) and --very bad, what if I have an eating cure for the herb?
							not affs:is_cure ("arnica", "herb", aff)
								then
							act:eat (affs:get_cure ("herb", aff), "herb", aff) --make all actions like actions:eat ("balance", "affliction")
							break
						end --if
					end --if
				end -- for
			end --if
		end --if
	end --if
	
end --function


	--salve curing
function scan.salve () --
	
	if sca:is_slowed () then
		return
	end --if
	
	if 
		bals:has ("salve") and
		able:to ("apply") and 
		not flags:get ("applying")
			then
			
			--creating a local list of afflictions to play with
		local local_affs= affs:copy ("salve")
		if next (local_affs) then
			
				--dealing with regen, i cannot apply two regens to the same body part
			for aff, val in pairs (local_affs) do
				if not next (local_affs) then
					break
				end --if
				local cure = affs:get_cure ("salve", aff)
				if string.find (cure, "regeneration") then
					local part = string.sub (cure, 23)
					if flags:get_check ("regenerating_"..part) or affs:has ("blackout") then
						local_affs [aff] = nil --then I don't try to cure the affliction
					end --for
				end --if
			end --for
				--I cannot apply mending to mangled/amputated bodyparts
			if affs:has ("mangled_leftleg") or affs:has ("amputated_leftleg") then
				local_affs ["broken_leftleg"] = nil
				local_affs ["twisted_leftleg"] = nil
			end --if
			if affs:has ("mangled_rightleg") or affs:has ("amputated_rightleg") then
				local_affs ["broken_rightleg"] = nil
				local_affs ["twisted_rightleg"] = nil
			end --if
			if affs:has ("mangled_leftarm") or affs:has ("amputated_leftarm") then
				local_affs ["broken_leftarm"] = nil
				local_affs ["twisted_leftarm"] = nil
			end --if
			if affs:has ("mangled_rightarm") or affs:has ("amputated_rightarm") then
				local_affs ["broken_rightarm"] = nil
				local_affs ["twisted_rightarm"] = nil
			end --if
				--dealing with nishied bodyparts
			local ninshi_removed = {}
			if next (affs ["ninshi"]) then
				for k, part in ipairs (wounds ["bpart_priority"]) do
					if affs ["ninshi"] [part] then
						if
							part == "leftleg" or
							part == "rightleg"
								then
							part = "legs"
						elseif
							part == "leftarm" or
							part == "rightarm"
								then
							part = "arms"
						end --if
						for a, v in pairs (local_affs) do
								--if the afflictions is on the top of the salve queue, then I try to cure it either way
							if string.find (affs ["cures"] ["salve"] [a], part) and system:getkey (affs ["salve"], a)>22 then
								local_affs [a] = nil
								ninshi_removed [#ninshi_removed+1] = a
							end --if
						end --for
					end --if
				end --for
			end --if
			if affs:has ("mangled_leftleg") or affs:has ("amputated_leftleg") then
				local_affs ["broken_leftleg"] = nil
				local_affs ["twisted_leftleg"] = nil
			end --if
			if affs:has ("mangled_rightleg") or affs:has ("amputated_rightleg") then
				local_affs ["broken_rightleg"] = nil
				local_affs ["twisted_rightleg"] = nil
			end --if
			if affs:has ("mangled_leftarm") or affs:has ("amputated_leftarm") then
				local_affs ["broken_leftarm"] = nil
				local_affs ["twisted_leftarm"] = nil
			end --if
			if affs:has ("mangled_rightarm") or affs:has ("amputated_rightarm") then
				local_affs ["broken_rightarm"] = nil
				local_affs ["twisted_rightarm"] = nil
			end --if
				--dealing with curing
			if next (local_affs) then
				for k, aff in ipairs (affs ["salve"]) do
					if
						local_affs [aff]  and
						not flags:get (aff)
							then
						act:apply (affs:get_cure ("salve",aff), "salve", aff)
						break
					end --if
				end --for
			end --if
			
				--dealing with ninshied bodyparts, if I haven't found anything else to cure
			if
				not flags:get ("applying") and--I am not applying
				next (ninshi_removed)
					then
				for k, aff in ipairs (ninshi_removed) do
					if not flags:get (aff) then
						act:apply (affs:get_cure ("salve", aff), "salve", aff)
					end --if
				end --for
			end --if				
		end --if
	end --if
	
end --function


	--focus curing
function scan.focus ()

	if sca:is_slowed () then
		return
	end --if
	
		--nothing I can do if I don't have focus balance
	if bals:has ("focus") then --it seems that I don't need a local affs table, maybe right, maybe wrong, we will see
		for k, aff in ipairs (affs ["focus"]) do
			if 
				affs:has (aff) and
				not flags:get (aff) and
				affs:get_cure ("focus", aff) and
				able:to (affs:get_cure ("focus", aff))
					then
				act:focus (affs:get_cure ("focus", aff), "focus", aff)
				break
			end --if
		end --for
	end --if

end --function


function scan.bleeding ()
	
	if sca:is_slowed () then
		return
	end --if
	
	if
		next (affs ["current"]) and
		not flags:get ("clotting") and
		able:to ("clot")
			then
		
		local aff
		local amnt --I store the amount in the affs ["bleeding_5"] table entry
		local to_clot = 1
		
		for a, val in pairs (affs ["current"]) do
			if string.find (a, "bleeding_") then
				aff = a
				amnt = val
				break
			end --if
		end --for
		
			--various checks to make sure I don't waste mana to clot
		if aff then
			if system ["hme_priority"] == "mana" and
				amnt< prompt ["vitals"] ["maxhealth"]*0.10
					then
				return
			end --if
			if affs:has ("health_critical") then--if I have health critical I always clot
				to_clot = -1 --I always clot, no matter the mana, when health is critical
			else
				to_clot = prompt ["vitals"] ["c_health"]/prompt ["vitals"] ["max_health"]-amnt/1000-(prompt ["vitals"]["c_mana"]-system:get_settings ("clot_cost"))/prompt ["vitals"] ["max_mana"]
			end --if
		end-- if
		
		if 
			aff and
			to_clot <= 0
				then
			act:clot (amnt)
		end --if
	end --if
	
end --function


function scan.sparklies ()
	
	if sca:is_slowed () then
		return
	end --if
	
	if affs:has ("eat_sparklies") then
		act:eat ("eat sparkleberry", "sparklies", "sparklies")
	end --if
	
end --function
			
--all of these work in blackout
function scan.free ()
	
	if system:is_auto ("insomnia") and not defs:has ("insomnia") then
		affs:add ("no_insomnia", true, "silent")
	end --if
	
	if system:is_auto ("metawake") and not defs:has ("metawake") then
		affs:add ("no_metawake", true, "silent")
	end --if
	
	if 	system:is_auto ("sting") and
		not sca:is_slowed ()
			then
		affs:add ("no_sting", true, true)
	end--if
	
		--I take care of curing in sca, I only needed the pseudo-afflictions
	if sca:is_slowed () then
		return
	end --if
	
	if affs:has ("asleep") then
		--Note ("asleep")
		if not flags:get ("asleep") then
			act:wake ()
		end --if
	elseif 
		affs:has ("no_metawake") and
		not flags:get ("no_metawake")
			then
		--Note ("metawake")
		act:metawake ()
	elseif
		affs:has ("pipes_unlit") and
		not flags:get ("pipes_unlit") and
		system:is_auto ("pipes_light") and
		able:to ()
			then
		--Note ("pipes_unlit")
		act:light ()
	elseif
		affs:has ("no_insomnia") and
		not flags:get ("no_insomnia") and
		able:to ("insomnia")
			then
		act:insomnia ()
	--elseif affs:has ("transmute") and not flags:get ("transmute") then
		--act:transmute ()
	elseif
		affs:has ("fear") and
		not flags:get ("fear")
			then
		act:compose ()
	elseif
		affs:has ("disrupted") and
		able:to ("concentrate") and
		not flags:get ("disrupted")
			then
		act:concentrate ()
	elseif 
		affs:has ("no_sting") and
		not flags:get ("no_sting") and
		able:to ("sting")
			then
		act:sting ()
	elseif defs:to_def ("free") then
		defs:scan ("free")
	elseif todo:to_do ("free") then
		todo:scan ("free")
	end --if
	
end --function


function scan.bal ()

	if system:is_auto ("protection") and not defs:has ("protection") then
		affs:add ("no_protection", true, "silent")
	end --if
	if system:is_auto ("waterwalk") and not defs:has ("waterwalk") then
		affs:add ("no_waterwalk", true, "silent")
	end --if
	if system:is_auto ("waterbreathe") and not defs:has ("waterbreathe") then
		affs:add ("no_waterbreathe", true, "silent")
	end --if
	if system:is_auto ("selfishness") and not defs:has ("selfishness") then
		affs:add ("no_selfishness", true, "silent")
	end --if
	if 	system:is_auto ("parry") and 
		not next (parry ["current"]) and
		not flags:get ("parry") and
		not parry.needed
			then
		parry:init ()
	end--if
	if 	system:is_auto ("stance") and 
		not stance ["current"] and
		not flags:get ("stance") and
		not stance.needed
			then
		stance:init ()
	end--if
	
	if sca:is_slowed () then
		return
	end --if
		--I wonder if I can see ignite in Blackout. Probably not
	local ignite = nil
	if 
		not flags:get ("ignite") and 
		system:is_enabled ("ignite") and
		able:to ("cleanse") and
		not flags:get ("bal")
			then
		local lashes = 0
		for k, v in ipairs ({"lashed_leftarm", "lashed_rightarm", "lashed_leftleg", "lashed_rightleg"}) do
			if affs:has (v) then lashes = lashes+1	end --if
		end --for
		if lashes>= system:get_settings ("ignite") then ignite = true end --if
	end --if
	
	if
		not affs:has ("blackout") and
		system:is_auto ("sharpness") and 
		offense and 
		next (offense ["current"]) and
		(defs:has ("sharpness") or 0)< #offense ["current"] and
		not flags:get_check ("sharpness")
			then	
		for k, id in ipairs (offense ["current"]) do
			todo:add ("bal", "sharpness", "coat "..id.." with sharpness", nil, true)
		end --for
		flags:add_check ("sharpness")
	end --if
		
		--can do very little while impaled, I don't writhe impaled in blackout, unfortunately
	if --raised the bal flag, deleted at fst, nocure and writhing_start
		(affs:has ("impaled") or affs:has ("pinleg") or affs:has ("crucified")) and
		(flags:get ("writhing") or "nil") ~= "impaled" and
		(flags:get ("writhing_start") or "nil") ~= "impaled" and
		able:to ("writhe_impaled")
			then
		act:writhe ("impaled")
		return
	end --if
	
	if --requires both bal and eq, I'm going to use one flag (bal)
		affs:has ("diag") and 
		not flags:get ("diag") and 
		not flags:get ("bal") and
		bals:has ("bal") and
		bals:has ("eq") and
		not affs:has ("blackout")
			then
		act:diag ()
		return
	end --if
	
		--being prone very dangerous, extremely dangerous, trying to cure this asap
	if affs:has ("prone") and able:to ("stand") and not flags:get ("prone") then
		act:stand ()
		return
	end --if
	
		--if I am in some kind of lock
	if 	not able:to ("drink") and 
		not able:to ("apply")
			then
		if able:to ("cleanse") and not flags:get ("cleanse") and not flags:get ("bal") then
				--if I am in a softlock curable by cleanse
			if 	not able:to ("smoke") and 
				affs:has ("slickness")
					then
				act:cleanse ()
				return
			end --if
				--if I am in a slitlock
			if 	affs:has ("slitthroat") and 
				affs:has ("slickness")
					then
				act:cleanse ()
				return
			end --if
		end --if
			--if I am in a hardlock
		if 	able:to ("powercure") or able:to ("syphon") then 
			if
				(not able:to ("smoke") or affs:has ("slitthroat")) and
				affs:has ("prone") and
				not able:to ("springup")--making sure balance isn't preventing me from standing
					then
				if able:to ("powercure") and
					not flags:get ("powercure")
						then
					act:powercure ()
					return
				elseif not able:to ("powercure") and
					able:to ("syphon") and--I'm going to use syphon manually
					not flags:get ("syphon")
						then
					act:syphon ()--not coded
					return
				end--if
			end--if
			--if I am in a hardlock that I can get out of by using restore
		elseif affs:has ("prone") and 
			able:to ("restore") and 
			not flags:get ("restore") and
			not flags:get ("bal")
				then
			local can, why
			if system:is_enabled ("springup") then
				can, why = able:springup ()
			else
				can, why = able:stand ()
			end --if
			if 	not can and
				(why == "broken_leftleg" or why == "broken_rightleg")
					then
				act:restore ()
				return
			end --if
		end --if
	end --if
	
		--taking care of the tahtetso prone lock
	if 	affs:has ("prone") and 
		(affs:has ("shatteredankle_leftleg") or affs:has ("shatteredankle_rightleg"))
			then
		local no=0
		for k, v in ipairs ({"mangled_leftleg", "mangled_rightleg", "amputated_leftleg",
"amputated_rightleg", "tendon_leftleg",
"tendon_rightleg"}) do
			if affs:has (v) then
				no = no+1
			end --if
		end --for
			--if I have too many regen affliction to legs or I simply have two and cannot powercure
		if no>=2 or (no>=1 and not able:to ("powercure")) then
			affs:add_custom ("tahtetso_insta", "salve", "apply regeneration to chest", 4)
		end --if
		if no>=1 then
			if able:to ("powercure") and not flags:get ("powercure") then
				act:powercure ()
				return
			end
		end --if
	end --if				
		
	if affs:has ("pipes_refill") and
		not flags:get ("pipes_refill") and
		able:to ("pipes_refill") and
		not flags:get ("bal")
			then
		act:refill ()
		return
	end --if
	
	--[[
	if
		affs:has ("no_speed") and
		not flags:get ("no_speed") and
		able:to ("adrenaline") and
		not flags:get ("bal")
			then
		act:adrenaline ()
		return
	end --if]]
	
	if
		affs:has ("pit") and
		not flags:get ("climbing") and
		not flags:get ("bal")
			then
		if able:to ("climb") then
			act:climb ("up")
		elseif able:to ("rockclimb") then
			act:rockclimb ()
		end--if
	end --if
	
	if
		affs:has ("intrees") and
		not flags:get ("climbing") and
		able:to ("climb") and
		not flags:get ("bal")
			then
		act:climb ("down")		
	end --if
	
	
	if able:to ("fastwrithe") and 
		not flags:get ("fastwrithe") and
		not system:is_enabled ("contort") and
		not flags:get ("bal")
			then
		act:fastwrithe ()
		return
	end --if
	
	if ignite then act:ignite () end --if
	
		---this i can do in blackout, the chances for both eq and bal to be offbal
	if
		not flags:get ("writhing") and 
		not flags:get ("writhing_start") and
		not flags:get ("fastwrithe") and
		not affs:has ("impaled") and
		not affs:has ("pinleg") and
		not affs:has ("crucified")
			then
		for k, aff in pairs (affs ["writhe"]) do
			if affs:has (aff) and not (string.find (aff, "lashed_") and flags:get ("ignite"))then
				act:writhe (aff)
				return
			end --if
		end --for
	end --if
		
	if affs:has ("read_healing") then act:read ("healing") end --if
		
	if affs:has ("unwield") and
		able:to ("wield") and
		not flags:get ("unwield")
			then
		act:wield ()
	end--if unwield
	
	if
		(affs:has ("ectoplasm") or
		affs:has ("mucous") or
		affs:has ("muddy") or
		affs:has ("gunk") or
		(affs:has ("deathmark") or 0) >= system:get_settings ("deathmark")) and
		not flags:get ("cleanse") and
		able:to ("cleanse") and
		not flags:get ("bal")
			then
		act:cleanse ()
		return
	end --if
	
		---I can do this in blackout
	if parry:is_needed ()==true then	parry:scan () end --if
	if stance:is_needed ()==true then stance:scan () end --if
	
	if 
		affs:has ("no_selfishness") and 
		not flags:get ("no_selfishness") and
		not affs:has ("blackout") and
		bals:has ("bal") and bals:has ("eq") and
		not flags:get ("bal")
			then		
		act:selfishness ()
		return
	end --if
	
	if bals:has ("bal") and bals:has ("eq") and	not affs:is_prone () and not affs:has ("blackout") and not flags:get ("bal") then
		if affs:has ("no_waterbreathe") and not flags:get ("no_waterbreathe") then
			act:waterbreathe ()
			return
		end--if
		if affs:has ("no_waterwalk") and not flags:get ("no_waterwalk") then
			act:waterwalk ()
			return
		end --if
	end --if
		--can't do in blackout
	if defs:to_def ("bal")==true and not flags:get ("bal") then
		defs:scan ("bal")
		return
	end --if
	
	if system:is_auto ("bashing") and able:to ("stand") and not affs:has ("prone") then
		todo:add ("bal", "bash", "symbol strike "..GetVariable ("system_target"))	
	end --if
	
		--not in blackout
	if todo:to_do ("bal")==true and not flags:get ("bal") then
		todo:scan ("bal")
		return
	end --if
	
	if 
		affs:has ("no_protection") and
		able:to ("read protection") and
		not flags:get ("no_protection")
			then
		act:read ("protection")
		return
	end --if
	
	if
		affs:has ("lust") and
		able:to ("reject") and
		not flags:get ("reject")
			then
		act:reject (affs:has ("lust"))
		return
	end --if
		
	
end --function


return scan


