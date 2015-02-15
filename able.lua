--[[  
	Able checks
	
--]]

require "affs"
require "display"
require "pipes"
require "magic"

if not able then
	able = {
		["focus_cost"] = {
			["mind"] = 250,
			["body"] = 250,
		},
		["contort_cost"] = 250,
	}
end --if


function able:to (sAction)
	
	--display.deb (sAction)
	
	result = false
	
	if sAction then
		sAction = string.gsub (sAction, " ", "_")
		local fn = able [sAction]
		if not (fn) then--if no such action, return true
				
			display.deb ("ABLE:TO -> no such action!")
			
			return true
		end --if
		result = fn ()
	else
		result = able:general () --defaulting to able:general
	end --if
	
	return result
	
end --function


	--CHECKING IF I CAN SMOKE FROM MY PIPES
function able:smoke ()
		
		--defaulting to true
	local result = true
	
	if
		affs:has ("asthma") or
		affs:has ("collapsedlungs") or 
		affs:has ("blacklung") or 
		affs:has ("homeostasis") or
		affs:has ("crucified") or
		affs:has ("pinleg")
			then
		result = false
	end --if
	return result

end --function


	--CHECKING IF I CAN SMOKE MYRTLE
function able:smoke_myrtle ()
	
	if not able:smoke () then
		return false
	end --if
	
	if
		not pipes:is_empty ("myrtle") and
		pipes:is_lit ("myrtle")
			then
		return true
	end --if
	
end --function.

	
	--CHECKING IF I CAN SMOKE COLTSFOOT
function able:smoke_coltsfoot ()
	
	if not able:smoke () then
		return false
	end --if
	
	if
		not pipes:is_empty ("coltsfoot") and
		pipes:is_lit ("coltsfoot")
			then
		return true
	end --if
	
end --function


	--CHECKING IF I CAN SMOKE FAELEAF
function able:smoke_faeleaf ()

	if not able:smoke () then
		return false
	end --if
	
	if
		not pipes:is_empty ("faeleaf") and
		pipes:is_lit ("faeleaf")
			then
		return true
	end --if
	
end --function


	--CHECKING IF I CAN LIGHT MY PIPES
function able:pipes_light()
	
	local result = true
	
	if
		not system:is_auto ("pipes_light") or
		affs:has ("pipes_refill") or
		affs:has ("pinleg") or
		affs:has ("crucified")
			then
		result = false
	end --if
	return result

end --function


	--CHECKING IF I CAN REFILL PIPES
function able:pipes_refill ()
	
	local result = true
	
	if
		not bals:has ("bal") or
		not bals:has ("eq") or
		affs:has ("pinleg") or
		affs:has ("crucified") or
		affs:has ("paralysis") or
		((affs:has ("amputated_leftarm") or affs:has ("mangled_leftarm") or affs:has ("broken_leftarm")) and 
		(affs:has ("amputated_rightarm") or affs:has ("mangled_rightarm") or affs:has ("broken_rightarm"))) or
		(affs:has ("hemiplegy_left") and affs:has ("hemiplegy_right"))
			then
		result = false
	end --if
	return result
	
end --function

	--copied to slowed prompts
	--CHECKING IF I CAN STAND
function able:stand () --missing conditions?!
	
		--I hold body
	if
		affs:has ("grappled") and
		next (affs ["hold"])
			then
		return false, "grappled"
	end --if
	local aff = {"pinleg", "impaled", "crucified", "entangled", "shackled",
					"transfixed", "roped", "trussed", "paralysis", "severedspine", "tendon_leftleg",
					"tendon_rightleg", "amputated_leftleg", "mangled_leftleg", "amputated_rightleg",
					"mangled_rightleg", "hemiplegy_left", "hemiplegy_right", "hemiplegy_lower", 
					"leglock", "crushedfoot_leftleg", "crushedfoot_rightleg", "broken_leftleg", "broken_rightleg",
			}
	for k, a in ipairs (aff) do
		if affs:has (a) then
			return false, a
		end --if
	end --for
	
	if not system:is_enabled ("springup") then
		if not bals:has ("eq") then
			return false, "eq"
		end --if
		if not bals:has ("bal") then
			return false, "bal"
		end --if
	
		if affs:has ("blackout") then
			return false, "blackout"
		end --if
	end --if
	
	return true
	
end --function


	--CHECKING IF I CAN USE ADRENALINE INSTEAD OF SIPPING QUICKSILVER
function able:adrenaline ()
	
	if
		not system:is_enabled ("adrenaline") or
		not bals:has ("bal") or
		not bals:has ("eq") or
		affs:has ("paralysis")
			then
		return false
	end --if
	return true
	
end --function

function able:soulwash ()

	if 	not system:is_enabled ("soulwash") or
		not bals:has ("bal") or
		not bals:has ("eq") or
		prompt ["vitals"] ["c_mana"]<100 or
		affs:is_prone ()
			then
		return false
	end--if
	return true
	
end --soulwash
		

function able:writhe ()

	return true

end --if


function able:writhe_impaled ()

	if not bals:has ("bal") or affs:has ("blackout") then
		return false
	end --if
	
	return true

end --if


function able:fastwrithe ()

	if 
		(system:is_enabled ("summer") or system:is_enabled ("tipheret")) and
		prompt ["vitals"] ["c_mana"] > 50 and
		bals:has ("eq") and
		bals:has ("bal") and
		(affs:has ("trussed") or affs:has ("entangled") or affs:has ("roped") or affs:has ("shackled")) and
		not affs:has ("blackout")
			then
		return true
	end --if
	
	return false

end --if
		
		
	--maybe I need to be holded to not be able to climb?
function able:climb ()--missing conditions?!
	
	local result = true
	
	if
		bals:get ("bal") ~= 1 or
		bals:get ("eq") ~= 1 or
		affs:has ("pinleg") or --!!! not in iasmos'
		affs:has ("crucified") or --!!! not in iasmos'
		affs:has ("prone") or
		affs:has ("entangled") or
		affs:has ("shackled") or
		affs:has ("transfixed") or
		affs:has ("roped") or
		affs:has ("paralysis") or
		affs:has ("transfixed") or 
		affs:has ("trussed") or --!!! not in iasmos'
		affs:has ("clamped_rightarm") or
		affs:has ("clamped_leftarm") or 
		next (affs ["grapples"]) or
		affs:has ("amputated_leftleg") or affs:has ("mangled_leftleg") or affs:has ("broken_leftleg") or 
		affs:has ("amputated_rightleg") or affs:has ("mangled_rightleg") or affs:has ("broken_rightleg") or
		affs:has ("amputated_leftarm") or affs:has ("mangled_leftarm") or affs:has ("broken_leftarm") or 
		affs:has ("amputated_rightarm") or affs:has ("mangled_rightarm") or affs:has ("broken_rightarm") or
		affs:has ("hemiplegy_lower") or --!!! not in iasmos'
		affs:has ("hemiplegy_upper") or --!!! not in iasmos'
		(affs:has ("hemiplegy_left") and affs:has ("hemiplegy_right"))
			then
		result = false
	end --if
	return result
	
end --function

	--checking if i can use a cleanse enchantment
function able:cleanse () --wtf?!
		--the afflictions are grouped in the order I am going to try and cure them in sap/aeon
	if
		not system:is_enabled ("cleanse") or
		not magic:is_available ("cleanse")
			then
		display.warning ("Out of Cleanse Charges")
		display.system ("Start Praying")
		return false, "cleanse not available"
	end--if
	
	local aff = {"prone", "pinleg", "transfixed", "clamped_rightarm", "clamped_leftarm",
					"entangled", "paralysis", "stun", "roped", "crucified", "shackled",}
	for k, a in ipairs (aff) do
		if affs:has (a) then
			return false, a
		end --if
	end --for
	
	if not bals:has ("eq") then
		return false, "eq"
	end --if
	if not bals:has ("bal") then
		return false, "bal"
	end --if
	
	if affs:has ("blackout") then
		return false, "blackout"
	end --if
	
	return true
	
end --function


	--CHECKING IF I CAN REJECT ENEMY
function able:reject ()--NOT IMPLEMENTED!!!
	
	if not bals:has ("bal") or not bals:get ("eq") then
		return false
	end --if
	
	return true
	
end --function


	--CHECKING IF I CAN APPLY SALVE
function able:apply () --DON'T check for balances here, you might elixir balance, not salve
	
	local result = true
	
	if
		affs:has ("slickness") or
		affs:has ("homeostasis") or
		(affs:has ("amputated_leftarm") and affs:has ("amputated_rightarm")) or
		affs:has ("crucified")
			then
		result = false
	end --if
	return result
	
end --function


	--CHECKING IF I CAN DRINK
function able:drink () 
	
	local result = true
	
	if 
		affs:has ("anorexia") or
		affs:has ("windpipe") or
		affs:has ("scarab") or
		affs:has ("slitthroat") or
		affs:has ("throatlock") or
		affs:has ("scarab") or
		affs:has ("homeostasis") or
		affs:has ("crucified") or
		(affs:has ("amputated_leftarm") and affs:has ("amputated_rightarm")) --not in Iasmos'system
			then
		result = false
	end --if
	return result

end-- function
		
		

	--CHECKING IF I CAN CLOT
function able:clot () --TO BE REDONE ONCE I IMPROVE THE CLOTTING SCRIPTS
	
	local result = true
	
	if 
		not system:is_auto ("clot") or
		prompt ["vitals"] ["c_mana"] < system:get_settings ("clot_cost") or --if I don't have enough mana to clot
		affs:has ("hemophilia") or
		affs:has ("pinleg") or
		affs:has ("manabarbs")
			then
		result = false
	end --if
	return result
	
end --function


	--CHECKING IF I CAN EAT
function able:eat ()
	
	if
		affs:has ("anorexia") or
		affs:has ("windpipe") or
		affs:has ("scarab") or
		affs:has ("slitthroat") or
		affs:has ("throatlock") or
		affs:has ("scarab") or
		affs:has ("homeostasis") or
		affs:has ("crucified") or
		(affs:has ("amputated_leftarm") and affs:has ("amputated_rightarm")) --not in Iasmos'system
			then
		return false
	end --if
	return true

end --function


	--CHECKING IF I CAN USE MEDBAG
function able:medbag ()
	
	local result = true
	
	if
		not system:is_auto ("medbag") or
		system:get_settings ("medbag_uses") == 0 or
		affs:has ("pinleg") or
		affs:has ("impaled") or
		affs:has ("severedspine") or
		affs:has ("paralysis") or 
		affs:has ("entangled")  or
		(affs:has ("amputated_leftarm") or affs:has ("mangled_leftarm") or affs:has ("broken_leftarm")) and
		(affs:has ("amputated_rightarm") or affs:has ("mangled_rightarm") or affs:has ("broken_rightarm"))
			then
		result = false
	end --if
	return result

end --function


	--CHECKING IF I CAN PARRY
function able:parry () --also check for asleep, stun, inconscious?! depends where I put the parry scan
	
	local result = true
	
	if
		not bals:has ("bal") or
		not bals:has ("eq") or
		affs:has ("pinleg") or --not verified
		(affs:has ("hemiplegy_left") and affs:has ("hemiplegy_right")) or
		affs:has ("elbow_rightarm") or
		affs:has ("elbow_leftarm")
			then
		result = false
	end --if
	return result

end --function


	--CHECKING IF I CAN STANCE-- NOT IMPLEMENTED !!!
function able:stance ()
	
	local result = true
	
	if
		not bals:has ("bal") or
		not bals:has ("eq") or
		affs:has ("paralysis") or
		affs:has ("impaled") or
		affs:has ("pinleg") or
		affs:has ("entangled") or
		affs:has ("shackled") or		
		affs:has ("transfixed") or 
		affs:has ("roped") or
		affs:has ("trussed") or
		affs:has ("paralysis") or
		affs:has ("prone") or
		affs:has ("kneecap_leftleg") or affs:has ("kneecap_rightleg") or --this might be somewhat wrong, I can stance?
		affs:has ("amputated_leftleg") or affs:has ("mangled_leftleg") or affs:has ("broken_leftleg") or 
		affs:has ("amputated_rightleg") or affs:has ("mangled_rightleg") or affs:has ("broken_rightleg") or
		affs:has ("amputated_leftarm") or affs:has ("mangled_leftarm") or affs:has ("broken_leftarm") or 
		affs:has ("amputated_rightarm") or affs:has ("mangled_rightarm") or affs:has ("broken_rightarm")
			then
		result = false
	end --if
	return result

end --function



	--CHECKING IF I CAN READ PROTECTION-- NOT IMPLEMENTED !!!
function able:read_protection () --need balance
	
	if
		not magic:is_available ("protection") or
		not bals:get ("bal") or
		not bals:get ("eq") or
		not able:read ()
			then
		return false
	end --if
	
	return true

end --function


function able:read_healing ()

	if
		not system:is_auto ("healing") or
		not magic:is_available ("healing") or
		not bals:has ("scroll") or
		not able:read ()
			then
		return false
	end --if
	return true
	
end --function


	--CHECKING IF I CAN READ A NORMAL SCROLL
function able:read ()
	
	local result = true
	
	if
		(affs:has ("blindness") and not defs:has ("sixthsense")) or
		(affs:has ("peckedeye_left") and affs:has ("peckedeye_right")) or
		affs:has ("impaled") or
		affs:has ("pinleg")
			then
		result = false
	end --if
	return result

end --function


	--CHECKING IF I CAN FOCUS BODY-
function able:focus_body () --not in settings, everyone can focus body
	
	local result = true
	
	if
		affs:has ("impatience") or
		prompt ["vitals"] ["c_mana"] <  able ["focus_cost"] ["body"]
			then
		result = false
	end --if
	return result

end --function
	
		--checking if I can focus mind
function able:focus_mind ()
	
	if	
		not system:is_enabled ("focus_mind") or
		affs:has ("crucified") or
		(affs:has ("bad_luck") and affs:count ()<system:get_settings ("badluck")and not affs:has ("sap") and not affs:has ("aeon") and not affs:has ("choke")) or
		prompt ["vitals"] ["c_mana"] <= able ["focus_cost"] ["mind"] or
		((affs:has ("deadened") or affs:has ("manabarbs")) and not (affs:has ("anorexia") and not affs:has ("sap") and not affs:has ("aeon") and not affs:has ("choke")))
			then
		return false
	end --if
	return true
	
end --function
	
		
		--checking if I can focus spirit -- I'm not using it right now
function able:focus_spirit ()
		
	local result = false
	
	if
		not system:is_enabled ("focus_spirit") or
		prompt ["vitals"] ["c_mana"] < able ["focus_cost"] ["mind"] or
		prompt ["vitals"] ["c_mana"] < prompt ["vitals"] ["max_mana"] / 4 or
		affs:has ("deadened") or 
		affs:has ("manabarbs") or
		affs:has ("impatience") or
		affs:has ("maestoso")
			then
		result = false
	end --if
	return result

end --function


--checking if I can contort
function able:contort ()
	
	if	
		not system:is_enabled ("contort") or
		prompt ["vitals"] ["c_mana"] <= able ["contort_cost"] or
		(system ["hme_priority"] == "mana" and 
		prompt ["vitals"] ["c_mana"] <= 0.5*prompt ["vitals"] ["max_mana"])
			then
		return false
	end --if
	return true

end --function


	--CHECKING IF I CAN USE INSOMNIA
function able:insomnia ()
	
	local result = true
	
	if
		not system:is_auto ("insomnia") or
		affs:has ("narcolepsy") or
		affs:has ("hypersomnia") or
		affs:has ("pinleg") or
		affs:has ("crucified") or
		prompt ["vitals"] ["c_mana"] < 100
			then
		result = false
	end --if
	return result

end --function


function able:restore ()

	if
		affs:has ("blackout") or
		not system:is_enabled ("restore") or
		not bals:has ("bal") or
		not bals:has ("eq") or
		prompt ["vitals"] ["c_mana"] < 100
			then
		return false
	end --if	
	return true
	
end --function


	--checking if i am stunned, asleep, inconscious
function able:general ()
	
	local result = true
	
	if
		affs:has ("asleep") or
		affs:has ("stun") or
		affs:has ("unconscious")
			then
		result = false
	end --if
	return result

end --function


function able:powercure ()
	
	if
		(system:is_enabled ("full") or system:is_enabled ("gedulah") or system:is_enabled ("green")) and
		bals:has ("bal") and bals:has ("eq") and		
		prompt ["vitals"] ["c_mana"] >= 80 
			then
		if system:is_enabled ("full") then
			if prompt ["vitals"] ["c_power"] >= 4 then
				return true
			end--if
		elseif prompt ["vitals"] ["c_power"] >=3 then
			return true
		end--if		
	end--if
	
	return false
	
end --function


function able:wield ()

	if 	not bals:has ("eq") or not bals:has ("bal") or
		affs:has ("blackout") or--I cannot see wielding/unwielding in blackout
		affs:is_prone () or
		affs:has ("transfixed") or
		affs:condition ("leftarm") == "unhealthy" or
		affs:condition ("rightarm") == "unhealthy"
			then
		return false
	end--if
	
	return true

end--wield


function able:transmute ()
	
	if 
		affs:is_prone () or
		affs:has ("transfixed") or
		not bals:has ("bal") or
		not bals:has ("eq")
			then
		return false
	end --if
	
	return true
	
end --transmute


function able:concentrate ()
	
	if affs:has ("confusion") then
		return false
	end --if
	
	return true
	
end --concentrate

function able:sting ()
	
	if 	not defs:has ("barbedtail") or
		affs:is_prone () or
		not bals:has ("tail")
			then
		return false
	end--if
	return true
	
end --sting

function able:rockclimb ()
	
	if 	skills:is_available ("rockclimbing") and
		bals:has ("bal") and bals:has ("eq") and
		prompt.vitals.c_power >= 3 
			then
		return true
	end--if
	
	return false
	
end--rockclimb

function able:syphon ()

	return false--I'm going to use syphon manually

end--syphon
	
	

return able
















