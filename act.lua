--[[
	COMMANDS USED BY THE SYSTEM
	
]]--


require "display"
require "flags"
require "affs"
require "nocure"
require "fst"

if not act then
	act = {
		["inv_herbs"] = {},
		["commands"] = {},
	}
end --if


function act:queue (com)

	table.insert (act ["commands"], com)
	
end --function


function act:exec ()

	if next (act ["commands"]) then
		ColourTell ("lightgrey", "", "(")
		for k, com in ipairs (act ["commands"]) do
			if k==1 then
				ColourTell ("lightgrey", "", com)
			else
				ColourTell ("lightgrey", "", "|"..com)
			end--if
		end--for
		ColourNote ("lightgrey", "", ")")
		for k, com in ipairs (act ["commands"]) do
			SendNoEcho (com)
		end--for
		act ["commands"] = {}
	end--if
	
end --function


function act:is_in_inv (herb)

	return self ["inv_herbs"] [herb]
	
end --is_in_inv


function act:add_inv (herb, quantity)

	self ["inv_herbs"] [herb] = (self ["inv_herbs"] [herb] or 0) + quantity
	sca:check ()
	
end --add_inv


function act:del_inv (herb, quantity)

	self ["inv_herbs"] [herb] = (self ["inv_herbs"] [herb] or 0)-(quantity or 1)
	if self ["inv_herbs"] [herb] <= 0 then
		self ["inv_herbs"] [herb] = nil
	end --if
	
end --del_inv


function act:reset_inv ()

	self ["inv_herbs"] = {}
	display.system ("Inventory Herbs RESET")
	
end --function


function act:wield ()

	flags:add ("unwield")
	fst:enable ("unwield")
	act:queue ("wield "..affs ["unwielded"] [1])
	
end--wield
	


function act:compose ()

	flags:add ("fear", "compose")
	fst:enable ("fear")
	act:queue ("compose")
	
end--compose

function act:sting ()

	flags:add ("no_sting")
	fst:enable ("no_sting")
	act:queue ("sting "..GetVariable ("system_target"))
	
end --sting
		

function act:insomnia ()
	
	sca:check ("no_insomnia")
	fst:enable ("no_insomnia")
	flags:add ("no_insomnia", "insomnia")
	act:queue ("insomnia")
	
end --insomnia


function act:selfishness ()
	
	flags:add ("no_selfishness")
	flags:add ("bal")
	fst:enable ("no_selfishness")
	sca:check ("no_selfishness")
	act:queue ("selfishness")

end --selfishness


function act:waterbreathe ()
	
	flags:add ("no_waterbreathe")
	flags:add ("bal")
	fst:enable ("no_waterbreathe")
	sca:check ("no_waterbreathe")
	if skills:is_available ("waterbreathe") then
		act:queue ("cast waterbreathe")
	else
		magic:use ("waterbreathe")
	end--if

end --waterbreathe


function act:waterwalk ()
	
	flags:add ("no_waterwalk")
	flags:add ("bal")
	fst:enable ("no_waterwalk")
	sca:check ("no_waterwalk")
	if skills:is_available ("waterwalk") then
		act:queue ("abjure waterwalk")
	else
		magic:use ("waterwalk")
	end--if

end --selfishness


function act:metawake ()
	
	flags:add ("no_metawake")
	fst:enable ("no_metawake")
	sca:check ("no_metawake")
	act:queue ("metawake on")
	
end --function


function act:ignite ()

	flags:add ("ignite")
	fst:enable ("ignite")
	magic:use ("ignite", "me")
	
end --if


function act:outr (herb)

	EnableTrigger ("outrifting", true)
	act:queue ("outr "..herb)
	display.deb ("ACT:OUTR -> "..herb)
	sca:check ("outrifting")
	
end --function


function act:transmute ()

	flags:add ("transmute", affs:has ("transmute"))
	fst:enable ("transmute")
	act:queue ("transmute "..tostring (affs:has ("transmute")).." mana")
	display.deb ("ACT:TRANSMUTE")
	
end --function


function act:diag ()

	act:queue ("diag")
	flags:add ("diag")
	flags:add ("bal")
	fst:enable ("diag")
	EnableTrigger ("diag_start", true)
	display.deb ("ACT:DIAG")
	sca:check ("diag")
	
end --function


function act:reject (name)

	flags:add ("reject", name)
	flags:add ("bal")
	fst:enable ("reject")
	act:queue ("reject "..name)
	display.deb ("ACT:REJECT")
	
end --function


function act:read (spell)

	if spell == "healing" then
		EnableTrigger ("readhealing", true)
		flags:add ("healing", "healing")
		bals:try ("scroll")
	elseif spell == "protection" then
		EnableTrigger ("readprotection", true)
		fst:enable ("no_protection")
		flags:add ("no_protection", "protection")
		flags:add ("bal")
	end --if
	sca:check ("read")
	display.deb ("ACT:READ -> "..spell)
	magic:use (spell)
	
end --function


function act:adrenaline ()

	act:queue ("adrenaline")
	if not affs:has ("aeon") then
		flags:add ("no_speed", "adrenaline")
		fst:enable ("speed")
	end--if
	sca:check ("adrenaline")
	display.deb ("ACT:ADRENALINE")
	
end --function


function act:soulwash ()

	act:queue ("abjure soulwash")
	sca:check ("soulwash")
	display.deb ("Act:soulwash")
	
end --soulwash

---NOTE IN BLACKOUT
function act:orgpotion ()

	local potion = system:get_settings ("orgpotion")
	flags:add ("orgpotion", "potion")
	fst:enable ("orgpotion")
	potion = string.gsub (potion, "_", " ")
	act:queue ("drink "..potion)
	display.deb ("ACT:ORGPOTION")
	
end --function

---IN BLACKOUT
function act:tea ()

	local is_tea = system:get_settings ("tea")
	if not is_tea then
		return display.warning ("You Must Set a Tea to Drink!")
	end --if
	flags:add ("brew", "drink tea")
	bals:try ("brew")
	act:queue ("drink "..is_tea)
	
	display.deb ("ACT:TEA")
	
end --function
	
---NOT IN BLACKOUT
function act:restore ()

	act:queue ("restore")
	flags:add ("restore", "locked")
	flags:add ("bal")
	fst:enable ("restore")
	display.deb ("ACT:RESTORE")
	sca:check ("restore")
	
end --function

--NOT IN BLACKOUT, BUT IT COULD WORK IN THEORY
function act:concentrate ()
	--in blackout I don't see the message, but I would try concentrating again and I would see it
	sca:check ("disrupted")
	--but if I have sca, I would send concentrate twice, that might screw me over
	act:queue ("concentrate")
	flags:add ("disrupted", "concentrate")
	fst:enable ("disrupted")
	
end --function	

--NOT IN BLACKOUT, it works, but I can't see it
function act:cleanse ()
	
	sca:check ("cleanse")	
	fst:enable ("cleanse")
	flags:add ("cleanse", "affliction")
	flags:add ("bal")
	
	magic:use ("cleanse")
	
end --function

--IN BLACKOUT
function act:stand ()

	if system:is_enabled ("springup") then
		flags:add ("prone", "springup")
		sca:check ("springup")
		act:queue ("springup")
	else
		sca:check ("prone")	
		flags:add ("prone", "stand")
		act:queue ("stand")
	end --if
	fst:enable ("prone")

end --function

--CURES BLACKOUT. YAY
function act:powercure ()

	local cure = "full"
	if not system:is_enabled ("full") then
		if system:is_enabled ("green") then
			cure = "green"
			act:queue ("invoke green")
		else
			cure = "gedulah"
			act:queue ("evoke gedulah")
		end--if
	else
		act:queue ("moondance full")
	end --if
	sca:check ("powercure")
	flags:add ("powercure", cure)
	fst:enable ("powercure")
	
end --function

--Maybe I should just send the command and consider asleep cured?
--If I don't have kafe, it might take a while to wake up. I would fail all the other cures
function act:wake ()

	sca:check ("asleep")
	EnableTriggerGroup ("System_Awaken", true)
	
	flags:add ("asleep", "wake")
	fst:enable ("asleep")
	
	act:queue ("wake")
	
end --function


function act:climb (direction)

	flags:add ("climbing", direction)
	if affs:has ("pit") and direction == "up" then
		flags:add ("bal")
	end--if
	fst:enable ("climbing")
	sca:check ("climb")
	act:queue ("climb "..direction)
	
end --function

function act:rockclimb ()

	flags:add ("climbing", "up")
	fst:enable ("climbing")
	sca:check ("rockclimb")
	act:queue ("climb rocks")
	
end--rockclimb

	--Works in blackout
function act:light ()
	
	act:queue ("light "..affs:has ("pipes_unlit"))
	fst:enable ("pipes_unlit")
	flags:add ("pipes_unlit", affs:has ("pipes_unlit"))
	sca:check ("pipes_unlit")
	
end --function

	--Works in blackout
function act:refill ()
	
	if 
		affs:has ("aeon") or
		affs:has ("sap") or
		affs:has ("choke")
			then
		if (flags:get_check ("outrifted") or "nil") == affs:has ("pipes_refill") then
			EnableTrigger ("pipesfilled", true)
			EnableTrigger ("pipesfull", true)
			flags:add ("pipes_refill", affs:has ("pipes_refill"))
			fst:enable ("pipes_refill")
			act:queue ("put "..affs:has ("pipes_refill").." in "..pipes ["current"] [affs:has ("pipes_refill")] ["id"])
		else
			act:outrift (affs:has ("pipes_refill"))
		end --if
		sca:check ("refill")
	else
		EnableTrigger ("pipesfilled", true)
		EnableTrigger ("pipesfull", true)
		act:queue ("outr "..affs:has ("pipes_refill"))
		flags:add ("pipes_refill", affs:has ("pipes_refill"))
		fst:enable ("pipes_refill")
		act:queue ("put "..affs:has ("pipes_refill").." in "..pipes ["current"] [affs:has ("pipes_refill")] ["id"])
	end --if
	
end --refill

	--Works in blackout
function act:focus (sCure, sBal, sAff)
	
	display.deb ("ACT:FOCUS -> for "..(sAff or "userinput"))
	EnableTriggerGroup ("System_Focus", true)
	
	if sAff then
		system:queue_cure (sCure)
		flags:add (sAff, sCure)
		bals:try ("focus")--fst is enabled/reset here
	else
		flags:add (string.gsub (sCure, " ", "_"), string.gsub (sCure, " ", "_"))
	end --if
	sca:check (sAff or "user")
	
	act:queue (sCure)

end --function

	--Doesn't work in blackout. DON'T TRY IT.
function act:smoke (sCure, sBal, sAff) --to make it somehow interact with manual smoking
	
		--debug
	display.deb ("ACT:SMOKE -> for "..(sAff or "userinput"))
	
	EnableTrigger ("smoking_phrenic", true)
	EnableTrigger ("smoking_empty", true)
	EnableTrigger ("smoking_pipesunlit", true)
	
	sca:check (sAff or "user")
	if sAff then
		flags:add (sAff, sCure)
		system:queue_cure (sCure)
		bals:try (sBal)
	end --if
	flags:add ("smoking", string.sub (sCure,7))	
	act:queue (sCure)
	
end --function


function act:apply (sCure, sBal, sAff) --scure is "health to legs", or "melancholic to chest"

		--debug
	display.deb ("ACT:APPLY -> "..sCure.." FOR "..(sAff or "userinput"))
	
	--checking what I am applying
	if string.find (sCure, "arnica") then
			--I handle the outrifting of arnica separately... so not elegant
		if affs:has ("sap") or affs:has ("aeon") or affs:has ("choke") then
			if not act:is_in_inv ("arnica") then
				return act:outr ("arnica")
			else--if I have arnicai in my inv
				EnableTriggerGroup ("System_Eating", true)
				flags:add (sAff, sCure)
				bals:try (sBal)
				system:queue_cure (sCure)
				act:queue (sCure)
					--in blackout I only see the no effect line
				if affs:has ("blackout") then
					local part = string.sub (sCure, 17)
					EnableTrigger ("nocure_apply_arnica_to_"..part)
				end --if
				sca:check (sCure or "user")
			end --if
		else
				--in blackout I only see the no effect line
			if affs:has ("blackout") then
				local part = string.sub (sCure, 17)
				EnableTrigger ("nocure_apply_arnica_to_"..part)
			end --if
			EnableTriggerGroup ("System_Eating", true)
			flags:add (sAff, sCure)
			bals:try ("herb")
			system:queue_cure (sCure)
			act:queue ("outr arnica")
			act:queue (sCure)
		end
	else
		if string.find (sCure, "health") then
			if affs:has ("blackout") then
				local part = string.sub (sCure, 17)
				EnableTrigger ("nocure_apply_health_to_"..part)
			end --if
			bals:try ("elixir")
			EnableTrigger ("applying_health", true)
			EnableTrigger ("applying_healthfail", true)
		else
			bals:try ("salve")
			EnableTrigger ("applying_salve", true)
		end --if
		flags:add (sAff, sCure)
		flags:add ("applying", sCure)
		sca:check (sAff or "user")
		act:queue (sCure)
	end --if

end --function


function act:applying_salve (part) --I always call the function with the trigger line

	affs:del ({"stun", "unconscious",})
	fst:disable ("stun")
	system:cured ("blackout")
	
	system:cures_on ()
	local cure = flags:get ("applying")
	if cure then
		if string.find (cure, "apply_regeneration_to_") then
			prompt:queue (function ()
				fst:enable (cure) --the fst for regen calls the nocure
				bals:offbal ("salve", "silent")
				local part = string.sub (cure, 23)
				flags:add_check ("regenerating_"..part)
				if part == "legs" then
					affs:del_custom ("apply_regeneration_to_legs")
				end --if
			end, "apply_regeneration_to_"..part, true)
				--I delete regeneration from the queue if I have blackout
			if affs:has ("blackout") then
				system:del_cure (cure)
			end --if
		else
			system:add_cure (cure)
		end --if
	end --if
	flags:del ("applying")
	
	display.deb ("ACT:APPLYING_SALVE")

end --function


	--When I apply health to cure deepwounds/numbs
function act:applying_health (part) --to keep track of the triggers I need to deactivate
	
	affs:del ({"stun", "unconscious",})
	fst:disable ("stun")
	system:cured_blackout ()
	
	system:cures_on ()
	display.deb ("ACT:APPLYING_HEALTH -> "..(flags:get ("applying") or "nil"))
		
	local is_applying = flags:get ("applying")
	if is_applying then
		system:add_cure (is_applying)
		flags:del ("applying")
	end --if
	EnableTrigger ("nocure_apply_health_to_"..part, true)
	prompt:queue (function () EnableTrigger ("nocure_apply_health_to_"..part, false) end, "applying_health", true)

end --applying_health

	--Works in blackout
function act:writhe (sAff)--I don't need sBal

		--debug
	display.deb ("ACT:WRITHE -> "..(sAff or "impaled"))
	
	--[[
	EnableTriggerGroup ("System_WStart", true)
	EnableTriggerGroup ("System_WNocure", true)
	EnableTriggerGroup ("System_WContinue", false)
	]]--
	
	sca:check (sAff or "user")	

	local cure = affs:get_cure ("writhe", sAff)
	if system:is_enabled ("contort") and able:to ("contort") then
		cure = string.gsub (cure, "writhe", "contort")
	end--if
	if sAff then
		sca:check ("impaled")	
		flags:add ("writhing_start", sAff) 
	else
		flags:add ("writhing_start", "user") 
	end --if
	fst:enable ("writhing")
	flags:add ("bal")
	act:queue (cure)

end --writhe

	--Doesn't work in blackout
function act:fastwrithe ()

	display.deb ("ACT:FASTWRITHE")
	
	if system:is_enabled ("summer") then
		act:queue ("invoke summer")
		flags:add ("fastwrithe", "summer")
	elseif system:is_enabled ("tipheret") then
		act:queue ("evoke tipheret")
		flags:add ("fastwrithe", "tipheret")
	end --if
	flags:add ("bal")
	sca:check ("fastwrithe")
	fst:enable ("fastwrithe")
	
end --fastwrithe

	
	--WHEN I START WRITHING
function act:writhing_start ()
	
	--[[
	EnableTriggerGroup ("System_WStart", false)
	EnableTriggerGroup ("System_WNocure", false)
	EnableTriggerGroup ("System_WContinue", true)
	]]--
	
	sca:check ()
	
	affs:del ({"stun", "unconscious",})
	fst:disable ("stun")
	flags:add ("writhing", flags:get ("writhing_start"))
	flags:del ({"writhing_start", "bal"})
	fst:enable ("writhing")
	display.system ("Starting Writhing...")
	
	display.deb ("ACT:WRITHE_START")
	
end --writhing_start

	
	--WHEN I CONTINUE WRITHING
function act:writhing () --I can cure aeon/sap as soon as I start writhing, I don't need to wait to finish

	fst:enable ("writhing")
	display.system ("<<- WRITHING ->>")
	
	display.deb ("ACT:WRITHING")

end --writhing

	--eat
function act:eat (sCure, sBal, sAff) 

		--debug
	display.deb ("ACT:EAT "..sCure.." FOR "..(sAff or "userinput"))
		--curing when slowed, I first need to outrift the herb
	if affs:has ("sap") or affs:has ("aeon") or affs:has ("choke") then
		local herb = string.sub (sCure, 5)
		if not act:is_in_inv (herb) then
			return act:outr (herb)
		else
			EnableTriggerGroup ("System_Eating", true)
			flags:add (sAff, sCure)
			bals:try (sBal)
			system:queue_cure (sCure)
			act:queue (sCure)
		end--if
		sca:check (sAff or "user")	
	else
		EnableTriggerGroup ("System_Eating", true)
		if sAff then
			if sAff ~= "sparklies" then system:queue_cure (sCure) end
			flags:add (sAff, sCure)
			bals:try (sBal)
		else
			flags:add (string.gsub (sCure, " ", "_"), string.gsub (sCure, " ", "_"))
		end --if
		if sAff == "sparklies" then
			sCure = "eat "..(system:get_settings ("sparklies") or "sparkleberry")
		end--if
		act:queue ("outr "..string.sub (sCure, 5)) --sCure will be eat galingale, for example
		act:queue (sCure)
	end --if
	
end --function


	--drink
function act:drink (sCure, sBal, sAff)

		--debug
	display.deb ("ACT:DRINK "..sCure.." FOR "..(sAff or "user"))
	
	if sAff then
			--I don't use speed in blackout, I cannot see when I'm drinking
			--I could directly activate the ondef_speed failsafe... hm
		if affs:has ("blackout") and sCure == "drink quicksilver" then
			bals:offbal ("speed", "silent")
			fst:enable ("ondef_speed")
		end --if
		if sCure ~= "drink_quicksilver" then
			system:queue_cure (sCure)
		end --if
			--I use allheale in paralel for a fixed affliction. For a custom one, I don't
		if sCure ~= "drink allheale" and not string.find (sAff, "custom_") then
			flags:add (sAff, sCure)
		end --if
		bals:try (sBal)
	elseif (affs:get_bal (sCure)) then
		flags:add (string.gsub (sCure, " ", "_"), string.gsub (sCure, " ", "_"))
	end --if
	sca:check (sAff or "user")
	
	act:queue (sCure)
	
end --function


function act:drinking (sLine)
	
	affs:del ({"stun", "unconscious",})
	fst:disable ("stun")
	system:cured ("blackout")

	system:cures_on ()
	system:poisons_on ()

	if (flags:get ("no_speed") or "nil") == "drink_quicksilver" then
		bals:offbal ("speed", "silent")
		fst:disable ("speed")
		fst:enable ("ondef_speed")
		flags:del ("no_speed")
	else
		for aff, cure in pairs (flags ["current"]) do
				--allheale is taken care of in its specific message line
			if string.find (cure, "drink_") and cure ~= "drink_allheale" then
				system:add_cure (cure)
				break
			end--if
		end --for
	end --if

	display.deb ("ACT:DRINKING")
	
end --function


function act:clot (amnt)

	EnableTrigger ("clotcontinue", true)
	EnableTrigger ("clotstop", true)
	
	fst:enable ("clotting")
	flags:add ("clotting", amnt)
	
	act:queue ("clot")
	
end --function

	--I can see it during blackout
function act:offbal_elixir () --it will only get called when "...flows down the throat without effect"
	
	local bal
	local aff
	local cure
	for a, c in pairs (flags.current) do
		if affs:get_bal (c) == "purg" then
			bal = "purg"
			aff = a
			cure = c
			break
		elseif affs:get_bal (c) == "elixir" then
			bal = "elixir"
			aff = a
			cure = c
			break
		end --if
	end --for
		
	if bal then--if I am trying to use either an elixir or purgative
		system:unqueue_cure (cure)
		flags:del (aff)
		bals:offbal (bal) --it will reset the timer here; also display the offbalance message
		system:del_cure ()
	end --if
	sca:check ()

end --function


	--OFF SALVE BALANCE
function act:offbal_salve () --offmedbag points to this, REDO!
	
	local cure = flags:get ("applying")
	local aff = flags:is_sent (cure)--the key is always the cure with flags table entries
	if string.find ((cure or "nil"), "apply_regeneration_to_") then
		local part = string.sub (cure, 23)
		flags:del ("regenerating_"..part)
		fst:disable ("apply_regeneration_to_"..part)
	end --if
	if aff then
		--[[
		if string.find (cure, "mending") then
				--then I need regen for that bodypart, and I create an affliction to apply regen
			affs:add_custom ("unknown", "salve", string.gsub (cure, "mending", "regeneration"))
		end --]]
		
		system:unqueue_cure (cure)
		flags:del (aff)
		bals:offbal ("salve") --the timer is disabled here; it will display the offbal message
		display.deb ("ACT:OFF_SALVE -> "..(flags:get ("applying") or "nil").." FOR "..aff)
	end --if
	sca:check ()
	flags:del ("applying")
	system:del_cure ()
		
end --function


function act:applying_healthfail ()

	local aff, cure = flags:bals_try ("elixir")
	if cure then
		flags:del (aff)
		bals:offbal ("elixir") --it will disable the timer here
		display.deb ("ACT:OFF_SALVE -> "..cure.." FOR "..aff)
	end --if
	sca:check ()
	flags:del ("applying")
	system:del_cure ()
	
end--function

	--I see it in blackout
function act:offbal_herb ()
		
	local aff, cure = flags:bals_try ("herb")
	if cure then
		system:unqueue_cure (cure)
		flags:del (aff)
		if string.find (cure, "smoke_") then
			flags:del ("smoking")
		end --if
	end --for
	sca:check ()
	bals:offbal ("herb")
	system:del_cure ()

end --function

	--I dont see the eating line in blackout
function act:eating (sHerb, sLine)
	
	affs:del ({"stun", "unconscious",})
	fst:disable ("stun")
	system:cured ("blackout")
	
	if sHerb ~= "sparkleberry" then
		EnableTriggerGroup ("System_Eating", false)
		system:add_cure ("eat_"..sHerb)
		act:del_inv (sHerb)
	end --if
	system:cures_on ()
	
	display.deb ("ACT:EATING")
	
		--WTF IS THIS?!?!
	--[[if
		flag.puncturedaura ~= "reishi"
			then
		flag.lc = flag.lc or {}
		flag.lc [wildcards [1]]--[[ = 1
	else
		SetVariable ("herb", "0")
		EnableTimer ("fst_herb", false)
		EnableTimer ("fst_puncturedaura", true)
		ResetTimer ("fst_puncturedaura")
	end --if]]--
	
end --function
	

return act



	
	
	
	