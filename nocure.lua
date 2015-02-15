--[[
	WHEN THERE ISN'T ANYTHING FOR A PARTICULAR CURE TO CURE
	---AFFS:IMPATIENCE AND AFFS:SLICKNESS COPIED HERE
]]--


if
	not nocure
		then
	nocure = {
		["bedeviled"] = {
			["confirmed"] = false,
			["eat_myrtle"] = function () affs:add ("hypochondria") end,
			["eat_yarrow"] = function () affs:impatience () end,
			["eat horehound"] = function () affs:add ("recklessness") end,
			["eat_reishi"] = function () affs:add ("brokennose") end,
			["smoke_coltsfoot"] = function () affs:add ("hemophilia") end,
			["eat_galingale"] = function () affs:slickness () end,
			["eat_pennyroyal"] = function () affs:add ("confusion") end,
			["eat_marjoram"] = function () affs:add ("broken_leftleg") end,
			["eat_wormwood"] = function () affs:add ("sensitivity") end,
			["eat_calamus"] = function () affs:add ("depression") end,
			["apply_liniment"] = function () affs:add ("stupidity") end,
		},
	}
end --if


function nocure:found (sCure, silent)
	
	if sCure then
		sCure = string.gsub (sCure, " ", "_")
		local fn = nocure [sCure]
		if fn then
			fn ()
			if sCure ~= "smoke_faeleaf" and not silent then
				display.nocure (sCure)
			end --if
			sca:check ()
		else
			return display.error ("Nocure function not defined for "..sCure)
		end --if
	end --if
	
end --function


function	nocure:find (sBal, sCure)
			
	display.deb ("NOCURE:FIND -> "..sCure.." WITH "..sBal)
	
	sCure = string.gsub (sCure, "_", " ")
			
	local local_affs = {}
	if sCure == "drink allheale" then
		for k, aff in ipairs (affs ["ah"]) do
			local_affs [#local_affs + 1] = aff
		end --for
	else
		for aff, cure in pairs (affs ["cures"] [sBal]) do
			if cure == sCure then
				local_affs [#local_affs + 1] = aff
			end --if
		end --for
	end --if
	
	if
		next (prompt ["queued"] ["current"]) and
		next (local_affs)
			then
		for k, aff in ipairs (local_affs) do --unqueueing affs
			if prompt ["queued"] ["ids"] ["affs_add_"..aff] then
				prompt:unqueue ("affs_add_"..aff)
			end--if
		end --for
	end --if
			
	return local_affs
			
end --function

	--If I used a cure that didn't cure anything, or I triggered the bedeviled afflictions
function nocure:check (cure) --only one cure in the check, I can only do one action before the prompt
	
	if nocure ["bedeviled"] ["confirmed"] then
		if nocure ["bedeviled"] [cure] then
			nocure ["bedeviled"] [cure] ()
		end--if
	else
		nocure:found (cure)
	end --if
	system:del_cure ()

end --function


function nocure:bedeviled_confirmed ()
	
	nocure ["bedeviled"] ["confirmed"] = true
	
end --confirm_bedeviled

		
function nocure:focus_body ()
	
	system:unqueue_cure ("focus_body")
	affs:del (nocure:find ("focus", "focus_body"))
	bals:onbal ("focus", "silent")
	
end --function


function nocure:focus_mind ()--there was a check for dementia and reality in Treant
	
	system:unqueue_cure ("focus_mind")
	if affs:has ("stupidity") then
		affs:add ("fracturedskull")
	end --if
	affs:del (nocure:find ("focus", "focus_mind"))
	bals:offbal ("focus", "silent")
	
end --function
 

function nocure:focus_spirit ()
	
	system:unqueue_cure ("focus_spirit")
	EnableTriggerGroup ("Focus", false)
	EnableTriggerGroup ("No_focus", false)
	
	affs:del (nocure:find ("focus", "focus spirit"))
	bals:onbal ("focus", "silent")

end --function
	
	
function nocure:apply_arnica_to_arms ()
	
	system:unqueue_cure ("apply_arnica_to_arms")
	affs:del (nocure:find ("herb", "apply_arnica_to_arms"))
	bals:onbal ("herb", "silent")
	
		--in blackout, I get this when I don't have anything to cure with antidote
		--if I am in sca, I need to remove the curing flag
	if affs:has ("blackout") and flags:get ("curing") then
		sca:check ()
	end --if
	
end --function


function nocure:apply_arnica_to_chest ()
	
	system:unqueue_cure ("apply_arnica_to_chest")
	affs:del (nocure:find ("herb", "apply_arnica_to_chest"))
	bals:onbal ("herb", "silent")

end --function


function nocure:apply_arnica_to_head ()
	
	system:unqueue_cure ("apply_arnica_to_head")
	affs:del (nocure:find ("herb", "apply_arnica_to_head"))
	bals:onbal ("herb", "silent")

end --function


function nocure:apply_arnica_to_legs ()
	
	system:unqueue_cure ("apply_arnica_to_legs")
	affs:del (nocure:find ("herb", "apply_arnica_to_legs"))
	bals:onbal ("herb", "silent")

end --function


function nocure:eat_calamus ()
	
	system:unqueue_cure ("eat_calamus")
	affs:del (nocure:find ("herb", "eat_calamus"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_chervil ()

	system:unqueue_cure ("eat_chervil")
	affs:del (nocure:find ("herb", "eat_chervil"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_earwort ()

	system:unqueue_cure ("eat_earwort")
	affs:del (nocure:find ("herb", "eat_earwort"))
	bals:offbal ("herb", "silent")
	affs:del ("no_truehearing")
	defs:ondef ("truehearing")

end --function
	

function nocure:eat_faeleaf ()

	system:unqueue_cure ("eat_faeleaf")
	affs:del (nocure:find ("herb", "eat_faeleaf"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_merbloom ()
	
	system:unqueue_cure ("eat_merbloom")
	affs:del ("no_insomnia")
	bals:offbal ("herb", "silent")
	defs:ondef ("insomnia")

end --function


function nocure:eat_galingale ()

	system:unqueue_cure ("eat_galingale")
	affs:del (nocure:find ("herb", "eat_galingale"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_horehound ()
	
	system:unqueue_cure ("eat_horehound")
	if affs:has ("recklessness") then
		affs:del (system ["hme_priority"].."_low")
	end --if
	
	affs:del (nocure:find ("herb", "eat_horehound"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_kafe ()

	system:unqueue_cure ("eat_kafe")
	affs:del (nocure:find ("herb", "eat_kafe"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_kombu ()

	system:unqueue_cure ("eat_kombu")
	affs:del (nocure:find ("herb", "eat_kombu"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_marjoram ()

	system:unqueue_cure ("eat_marjoram")
	affs:del (nocure:find ("herb", "eat_marjoram"))
	bals:offbal ("herb", "silent")
	
	for k, bpart in pairs ({"chest", "gut", "head", "leftarm", "rightarm"}) do
		if not affs ["ootangk"] [bpart] then
			affs:del ("stiff_"..bpart)
		end --if
	end --deleting stiff afflictions, ONLY if they aren't in an ootangk grapple

end --function


function nocure:eat_myrtle ()

	system:unqueue_cure ("eat_myrtle")
	if affs:has ("blindness") then
		defs:ondef ("sixthsense")
		affs:del ("no_sixthsense")
	end --if
	
	if affs:has ("deafness") then
		defs:ondef ("truehearing")
		affs:del ("no_truehearing")
	end --if
	
	affs:del (nocure:find ("herb", "eat_myrtle"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_pennyroyal ()

	system:unqueue_cure ("eat_pennyroyal")
	if affs:has ("stupidity") then
		affs:add ("fracturedskull")
	end --if
	affs:del (nocure:find ("herb", "eat_pennyroyal"))
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_reishi ()
	
	system:unqueue_cure ("eat_reishi")
	affs:del (nocure:find ("herb", "eat_reishi"))--Iasmos has something about jinx, to inquire about it
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_wormwood ()

	system:unqueue_cure ("eat_wormwood")
	affs:del (nocure:find ("herb", "eat_wormwood"))--Iasmos has something about jinx, to inquire about it
	bals:offbal ("herb", "silent")

end --function


function nocure:eat_yarrow ()

	system:unqueue_cure ("eat_yarrow")
	affs:del (nocure:find ("herb", "eat_yarrow"))--Iasmos has something about jinx, to inquire about it
	affs:artery ()
	affs:lacerated ()
	bals:offbal ("herb", "silent")

end --function


function nocure:drink_health ()

	system:unqueue_cure ("drink_health")
	
end--drink_health


function nocure:drink_mana ()

	system:unqueue_cure ("drink_health")

end --drink mana


function nocure:drink_ego ()

	system:unqueue_cure ("drink_ego")

end --drink ego


function nocure:drink_antidote ()
	
	system:unqueue_cure ("drink_antidote")
	affs:del (nocure:find ("elixir", "drink_antidote"))
	bals:offbal ("purg", "silent")
	
		--in blackout, I get this when I don't have anything to cure with antidote
		--if I am in sca, I need to remove the curing flag
	if affs:has ("blackout") and flags:get ("curing") then
		sca:check ()
	end --if

end --function


function nocure:drink_choleric ()

	system:unqueue_cure ("drink_choleric")
	affs:del (nocure:find ("elixir", "drink_choleric"))
	bals:offbal ("purg", "silent")

end --function


function nocure:drink_love ()

	system:unqueue_cure ("drink_love")
	affs:del (nocure:find ("elixir", "drink_love"))
	bals:offbal ("purg", "silent")
	affs:add ("love")
	
end --function


function nocure:drink_fire ()

	system:unqueue_cure ("drink_fire")
	affs:del (nocure:find ("elixir", "drink_fire"))
	bals:offbal ("purg", "silent")
	defs:ondef ("fire")

end --function


function nocure:drink_frost ()

	system:unqueue_cure ("drink_frost")
	affs:del (nocure:find ("elixir", "drink_frost"))
	bals:offbal ("purg", "silent")
	defs:ondef ("frost")

end --function


function nocure:drink_galvanism ()

	system:unqueue_cure ("drink_galvanism")
	affs:del (nocure:find ("elixir", "drink_galvanism"))
	bals:offbal ("purg", "silent")
	defs:ondef ("galvanism")

end --function


function nocure:drink_phlegmatic ()

	EnableTrigger ("aeon_prompt", false)
	system:unqueue_cure ("drink_phlegmatic")
	affs:del (nocure:find ("elixir", "drink_phlegmatic"))
	flags:del ("action")
	bals:offbal ("purg", "silent")

end --function


function nocure:drink_sanguine ()
	
	system:unqueue_cure ("drink_sanguine")
	affs:del (nocure:find ("elixir", "drink_sanguine"))
	bals:offbal ("purg", "silent")

end --function


function nocure:apply_liniment ()

	system:unqueue_cure ("drink_liniment")
	affs:del (nocure:find ("salve", "apply_liniment"))
	flags:del ("applying")
	bals:offbal ("salve", "silent")

end --function


function nocure:apply_melancholic_to_head () --WTF, SALVE 0 SAU 1???

	system:unqueue_cure ("apply_melancholic_to_head")
	affs:del (nocure:find ("salve", "apply_melancholic_to_head"))
	flags:del ("applying") --just a failsafe, I've already deleted when I tried to apply
	bals:offbal ("salve", "silent")

end --function


function nocure:apply_melancholic_to_chest () --WTF, SALVE 0 SAU 1???

	system:unqueue_cure ("apply_melancholic_to_chest")
	affs:del (nocure:find ("salve", "apply_melancholic_to_chest"))
	flags:del ("applying") --just a failsafe, I've already deleted when I tried to apply
	bals:onbal ("salve", "silent")

end --function


function nocure:apply_mending_to_arms () --WTF, SALVE 0 SAU 1???
	
	system:unqueue_cure ("apply_mending_to_arms")
	affs:del (nocure:find ("salve", "apply_mending_to_arms"))
	flags:del ("applying") --just a failsafe, I've already deleted when I tried to apply
	bals:onbal ("salve", "silent")

end --function


function nocure:apply_mending_to_head () --WTF, SALVE 0 SAU 1???

	system:unqueue_cure ("apply_mending_to_head")
	affs:del (nocure:find ("salve", "apply_mending_to_head"))
	flags:del ("applying") --just a failsafe, I've already deleted when I tried to apply
	bals:onbal ("salve", "silent")

end --function


function nocure:apply_mending_to_legs () --WTF, SALVE 0 SAU 1???
	
	system:unqueue_cure ("apply_mending_to_legs")
	affs:del (nocure:find ("salve", "apply_mending_to_legs"))
	flags:del ("applying") --just a failsafe, I've already deleted when I tried to apply
	bals:onbal ("salve", "silent")

end --function


function nocure:apply_regeneration_to_arms ()
	
		--I don't regenerate in blackout, but I still keep track of regeneration when I apply
	system:unqueue_cure ("apply_regeneration_to_arms")
	if
		affs:has ("amputated_leftarm") or
		affs:has ("mangled_leftarm")
			then
		affs:add ("broken_leftarm")
	end --if
	
	if
		affs:has ("amputated_rightarm") or
		affs:has ("mangled_rightarm")
			then
		affs:add ("broken_rightarm")
	end --if
	flags:del_check ("regenerating_arms")
	affs:del (nocure:find ("salve", "apply_regeneration_to_arms"))

end --function


function nocure:apply_regeneration_to_chest ()
	
	system:unqueue_cure ("apply_regeneration_to_chest")
	flags:del_check ("regenerating_chest")
	affs:del (nocure:find ("salve", "apply_regeneration_to_chest"))

end --function


function nocure:apply_regeneration_to_gut ()

	system:unqueue_cure ("apply_regeneration_to_gut")
	flags:del_check ("regenerating_gut")
	affs:del (nocure:find ("salve", "apply_regeneration_to_gut"))

end --function


function nocure:apply_regeneration_to_head ()

	system:unqueue_cure ("apply_regeneration_to_head")
	flags:del_check ("regenerating_head")
	affs:del (nocure:find ("salve", "apply_regeneration_to_head"))

end --function


function nocure:apply_regeneration_to_legs ()

	system:unqueue_cure ("apply_regeneration_to_legs")
	if
		affs:has ("amputated_leftleg") or
		affs:has ("mangled_leftleg")
			then
		affs:add ("broken_leftleg")
	end --if
	
	if
		affs:has ("amputated_rightleg") or
		affs:has ("mangled_rightleg")
			then
		affs:add ("broken_rightleg")
	end --if
	flags:del_check ("regenerating_legs")
	affs:del (nocure:find ("salve", "apply_regeneration_to_legs"))

end --functionsh


function nocure:apply_health_to_skin ()---SOMETHING HERE ABOUT NUMB

	flags:del ("applying")
	bals:onbal ("elixir", "silent")

	for k, bpart in pairs ({"chest", "gut", "head", "leftarm", "leftleg", "rightarm", "rightleg"}) do
		wounds:set (bpart, 0)
	end --for
	wounds:scan () --I also delete the flag for any wounds I was trying to cure

end --function


function nocure:apply_health_to_head ()

	system:unqueue_cure ("apply_health_to_head")
	flags:del ("applying")
	bals:onbal ("elixir", "silent")
	
	affs:numb ("head", nil, true)
	wounds:set ("head", 0)
	wounds:scan ()

end --function


function nocure:apply_health_to_chest ()

	system:unqueue_cure ("apply_health_to_chest")
	flags:del ("applying")
	bals:onbal ("elixir", "silent")
	
	affs:numb ("chest", nil, true)
	wounds:set ("chest", 0)
	wounds:scan ()

end --function


function nocure:apply_health_to_gut ()
	
	system:unqueue_cure ("apply_health_to_gut")
	flags:del ("applying")
	bals:onbal ("elixir", "silent")
	
	affs:numb ("gut", nil, true)
	wounds:set ("gut", 0)
	wounds:scan ()

end --function


function nocure:apply_health_to_arms ()

	system:unqueue_cure ("apply_health_to_arms")
	flags:del ("applying")
	bals:onbal ("elixir", "silent")
	
	affs:numb ("leftarm", nil, true)
	affs:numb ("rightarm", nil, true)
	wounds:set ("leftarm", 0)
	wounds:set ("rightarm", 0)
	wounds:scan ()

end --function


function nocure:apply_health_to_legs ()

	system:unqueue_cure ("apply_health_to_legs")
	flags:del ("applying")
	bals:onbal ("elixir", "silent")
	
	affs:numb ("leftleg", nil, true)
	affs:numb ("rightleg", nil, true)
	wounds:set ("leftleg", 0)
	wounds:set ("rightleg", 0)
	wounds:scan ()

end --function


function nocure:smoke_coltsfoot (silent)

	system:unqueue_cure ("smoke_coltsfoot")
	affs:del (nocure:find ("herb", "smoke_coltsfoot"))
	bals:offbal ("herb", "silent")
	defs:lostdef ("insomnia")
	
end --function


function nocure:smoke_myrtle ()

	system:unqueue_cure ("smoke_myrtle")
	affs:del({"hemiplegy_lower", "windpipe", "pierced_leftarm", "pierced_leftleg", "pierced_rightarm", "pierced_rightleg"})
	bals:offbal ("herb", "silent")
	affs:del_custom ("smoke_myrtle")
	
	if not affs:has ("collapsednerve_left") then
		affs:del ("hemiplegy_left")
	end --if
	
	if not affs:has ("collapsednerve_right") then
		affs:del ("hemiplegy_right")
	end --if

end --function


function nocure:smoke_faeleaf ()

	system:unqueue_cure ("smoke_faeleaf")
	affs:add ("coil", 0)
	fst:disable ("herb")
	bals:onbal ("herb", "silent")
	fst:enable ("ondef_rebound")
	
end --function


function nocure:drink_allheale ()

	system:unqueue_cure ("drink_allheale")
	local aff, cure = flags:bals_try ("ah")
	if string.find ((aff or "nil"), "custom_") then
		affs:del_custom ("drink_allheale")
	end--i
	affs:del (nocure:find ("ah", "drink_allheale"))
	affs ["unknown"] = 0
	bals:offbal ("ah", "silent")

end --function


function nocure:totem ()

	system:unqueue_cure ("totem")
	affs:del (nocure:find ("ah", "drink allheale"))

end


function nocure:phial ()
	
	system:unqueue_cure ("phial")
	affs:del (nocure:find ("ah", "drink allheale"))

end


function nocure:beast_body ()

	system:unqueue_cure ("beast_body")
	affs:del({"brokenchest", "brokennose", "fractured_leftarm", "fractured_rightarm", "snappedrib"})

end --function


function nocure:beast_mind ()

	system:unqueue_cure ("beast_mind")
	affs:del (nocure:find ("focus", "focus mind"))

end --function


function nocure:beast_spirit ()

	system:unqueue_cure ("beast_spirit")
	affs:del (nocure:find ("herb", "eat horehound"))
	affs:del (nocure:find ("herb", "eat reishi"))

end --function


function nocure:restore ()

	system:unqueue_cure ("restore")
	affs:del (nocure:find ("salve", "apply mending to legs"))
	affs:del (nocure:find ("salve", "apply mending to arms"))

end --function


function nocure:writhe (aff)
	
	fst:disable ("writhing")
	flags:del ({"writhing_start", "writhing"})
	sca:check ()
	if not aff then
		affs:del (affs ["writhe"])
		affs:grappled ()
		affs:del ("crucified")
		affs:impaled (0)
		affs:pinleg (0)
	else
		affs:pinleg (0)--this is the first one to writhe out of. If you don't have a specific affliction to writhe out of, you don't have pinleg
		if type (aff) == "table" then
			affs:del (aff)
		else
			affs:del (aff)
			if
				aff == "pinleg" or--pingleg is first to writhe out from
				aff == "crucified" or--crucified the second
				aff == "impaled"--impaled the third
					then
				affs:impaled (0)--I have no impales, obviously
				affs:del (affs ["writhe"])
			else
				if aff~="pinleg" then -- I am assuming here that pinleg is the very first writhe, crucified second, impaled third
					affs:del ("crucified")
				end --if
				if aff == "grappled" then
					affs:grappled ()
				end--if
			end --if
		end --if
	end --if
	affs:scan_grappled ()
	
end --function


function nocure:powercure ()

	affs:del (nocure:find ("ah", "drink_allheale"))
	flags:del ("curing")
	fst:disable ("curing")
	
end --powercure


function nocure:westwind ()

	affs:del (nocure:find ("ah", "drink_allheale"))
	
end --westwind


return nocure

	