--[[
	FAILSAFES FOR WHEN SOMETHING GOES WRONG WITH THE CURING

]]--


require "flags"
require "affs"
require "display"


if
	not fst
		then
	fst = {
		["timers"] = {
			["brew"] = 2,
			["arena"] = 50,
			["elixir"] = 2,
			["orgpotion"] = 2,
			["purg"] = 2,
			["ah"] = 2,
			["herb"] = 1.5,
			["salve"] = 2,
			["sparklies"] = 2,
			["focus"] = 2,
			["prone"] = 1,
			["scroll"] = 2,
			["sca"] = 2,
			["gn_ah"] = 25,
			["gn_elixir"] = 7,
			["gn_focus"] = 4,
			["gn_herb"] = 3,
			["gn_brew"] = 60,
			["gn_purg"] = 3,
			["gn_salve"] = 2,
			["gn_sparklies"] = 9,
			["gn_focus"] = 5,
			["gn_scroll"] = 9,
			["gn_tail"] = 10,
			["apply_regeneration_to_legs"] = 4,
			["apply_regeneration_to_arms"] = 4,
			["apply_regeneration_to_head"] = 4,
			["apply_regeneration_to_chest"] = 4,
			["apply_regeneration_to_gut"] = 4,
			["deffing"] = 2,
			["diag"] = 2,
			["reject"] = 2,
			["writhing"] = 3,
			["unwield"] = 2,
			["fastwrithe"] = 2,
			["pipes_unlit"] = 2,
			["pipes_refill"] = 2,
			["fear"] = 1,
			["disrupted"] = 2,
			["pit"] = 7,
			["woundstatus"] = 6,
			["maestoso"] = 15,
			["madfly"] = 120,
			["parry"] = 2,
			["stance"] = 2,
			["demesne"] = 9,
			["illusory_wounds"] = 60,
			["speed"] = 2,
			["climbing"] = 1,
			["clotting"] = 2,
			["asleep"] = 2,
			["cleanse"] = 2,
			["todo_free"] = 2,
			["todo_bal"] = 2,
			["ignite"] = 2,
			["restore"] = 2,
			["score"] = 2,
			["blanknote"] = 10,
			["rainbow_patterns"] = 90,
			["darkseed"] = 30,
			["displacement"] = 2,
			["stun"] = 1.5,
			["powercure"] = 2,
			["transmute"] = 2,
				--delayed defenses
			["ondef_speed"] = 7,
			["ondef_sixthsense"] = 7,
			["ondef_protection"] = 10,
			["ondef_rebound"] = 7,
			["ondef_orgpotion"] = 35,
				--pseudo-afflictions
			["no_protection"] = 2,
			["no_metawake"] = 1.5,
			["no_insomnia"] = 1.5,
			["no_waterwalk"] = 2,
			["no_waterbreathe"] = 2,
			["no_sting"] = 2,
			["no_selfishness"] = 2,},
				--autofiring failsafes
		["firing"] = {"no_protection", "scroll", "elixir", "herb", "purg", "ah", "herb", "salve", "focus",
			"sparklies", "prone", "healing", "parry", "stance", "speed", "fear", "disrupted",
			"pipes_refill", "pipes_unlit", "no_insomnia", "climbing", "clotting", "cleanse",
			"todo_free", "todo_bal", "ignite", "restore", "orgpotion", "sca", "no_waterwalk",
			"no_waterbreathe", "no_selfishness", "unwield"},
				--silent failsafes (the messages are shown by something else
		["silent"] = {	["apply_regeneration_to_legs"] = true,
							["apply_regeneration_to_arms"] = true,
							["apply_regeneration_to_chest"] = true,
							["apply_regeneration_to_gut"] = true,
							["apply_regeneration_to_head"] = true,
							["ondef_speed"] = true,
							["ondef_sixthsense"] = true,
							["ondef_protection"] = true,
							["ondef_rebound"] = true,
							["ondef_orgpotion"] = true,
							["demesne"] = true,
							["illusory_wounds"] =true,
							["pit"] = true,},
	}
end --if


function fst:reset (silent)

	for n, t in pairs (fst ["timers"]) do
		EnableTimer ("fst_"..t, false)
	end --for
	
	if not silent then
		display.system ("Failsafe Timers RESET")
	end --if
	
end --function


function fst:fire (sName, immediate, silent)

	if sName then
		sName = string.gsub (sName, " ", "_") --making sure I don't have any spaces
		local fn = fst [sName]
		if fn then
			if immediate then 
				fn ()
				if not silent and not self ["silent"] [sName] then
					display.fst (sName)
				end--if
			else
				prompt:queue (function () 
					fn () 
					if not silent and not fst ["silent"] [sName] then
						display.fst (sName) 
					end--if
				end, "fst_"..sName) --what if I have lag, I cure, failsafe triggers, then prompt?
				if not sca:is_slowed () then
					Send ("")
				end--if
			end --if
			fst:disable (sName)
		else
			display.system ("Fst:fire "..sName.." -> no such failsafe!")
		end --if
	else
		display.system ("Fst:fire -> no name specified!")
	end --if
	
end --function


function fst:autofire ()

	for k, name in ipairs (self ["firing"]) do
		if
			IsTimer ("fst_"..name) and
			GetTimerInfo ("fst_"..name, 6)
				then
			fst:fire (name, true)
		end --if
	end --for
	if flags:get ("writhing_start") then
		fst:writhing (nil, "start")
	end--if
	
end --function

function fst:enable (name)

	if not name then
		return display.warning ("fst:enable -> no name specified!")
	end --if
	name = string.gsub (name, " ", "_")
	if not fst ["timers"] [name] then
		return
	end --if
	
	if IsTimer (name) ~= 0 then
		local minutes = math.floor(fst ["timers"] [name]/60)
		local seconds = fst ["timers"] [name]%60
		if not string.find (name, "gn_") then
			ImportXML([[<timers>
<timer
name="]].."fst_"..name..[["
minute="]] .. minutes .. [["
second="]] .. seconds .. [["
offset_second="0.00"
send_to="12"
group="System_Fst" >
<send>fst:fire("]] ..name.. [[")</send>
</timer>
</timers>]])
		else
			ImportXML([[<timers>
<timer
name="]] .."fst_"..name..[["
minute="]]..minutes..[["
second="]] .. seconds .. [["
offset_second="0.00"
send_to="12"
group="System_Fst" >
<send>fst:gain("]] ..string.sub (name, 4).. [[")</send>
</timer>
</timers>]])
		end --if
	else
		SetTimerOption (name, "second", fst ["timers"] [name])
	end --if
	EnableTimer ("fst_"..name, true)
	ResetTimer ("fst_"..name)
	
	if name == "sca" then
		if IsTimer ("fst_sca") ~= 0 then
			local minutes = math.floor(fst ["timers"] [name]/60)
			local seconds = fst ["timers"] [name]%60
			ImportXML([[<timers>
<timer
name="fst_sca"
minute="]] .. minutes .. [["
second="]] .. seconds .. [["
offset_second="0.00"
send_to="12"
group="System_Fst" >
<send>fst:fire("sca")</send>
</timer>
</timers>]])
		else
			SetTimerOption ("fst_sca", "second", fst ["timers"] ["sca"])
		end --if
		EnableTimer ("fst_sca", true)
		ResetTimer ("fst_sca")
	end --if
	
	
end --function


function fst:disable (name)

	if not name then
		return
	end --if
	
	name = string.gsub (name, " ", "_")	
	EnableTimer ("fst_"..name, false)
	
end --function	


function fst:gain (sBal)

	fst:disable ("gn_"..sBal)--fst_gn_herb
	bals:onbal (sBal, "silent")--maybe this is all?
	display.gn (sBal)
	
end --function


function fst:elixir ()

	bals:onbal ("elixir", "silent")--fst disabled here too
	local aff, cure = flags:bals_try ("elixir")
	
	if cure then
		system:unqueue_cure (cure)
		flags:del (aff)
		if string.find (cure, "apply_health") then
			flags:del ("applying")
		end --if
	end --if
	
end --function


function fst:purg ()

	bals:onbal ("purg", "silent")
	local aff, cure = flags:bals_try ("purg")
	
	if cure then
		system:unqueue_cure (cure)
		flags:del (aff)
	end --if
	
end --function


function fst:ah ()

	bals:onbal ("ah", "silent")
	local aff, cure = flags:bals_try ("ah")
	
	if cure then
		system:unqueue_cure (cure)
		flags:del (aff)
	end --if
	
end --function


function fst:herb ()--I CAN USE IT FOR SMOKING TOO!!!!!!

	bals:onbal ("herb", "silent")
	flags:del ({	"no_rebound", "coils_1", "coils_2", "coils_3", "coils_4",
					"coils_5", "coils_6", "coils_7", "coils_8"})
	local aff, cure = flags:bals_try ("herb")
	
	if cure then
		system:unqueue_cure (cure)
		flags:del (aff)
		if string.find (cure, "apply_arnica_to_") then
			flags:del ("applying")
		end --if
		flags:del ("smoking")
	end --if

end --function


function fst:salve ()

	bals:onbal ("salve", "silent")
		--fst:salve was called when I failed applying because of ninshi/hidden slickness
	for k, part in ipairs ({"head", "chest", "gut", "legs", "arms"}) do
		if prompt:is_queued ("apply_regeneration_to_"..part) then--regen sets the balance to 0
			prompt:unqueue ("apply_regeneration_to_"..part)--so the latter can't apply
			break
		end--if
	end--for

	local aff, cure = flags:bals_try ("salve")
	if cure then
		system:unqueue_cure (cure)
		flags:del (aff)
		flags:del ("applying")
	end --if

end --function


function fst:sparklies ()

	bals:onbal ("sparklies", "silent")
	flags:del ("sparklies")		
	
end --function

	--note to self: this will show two messages, one for the fst and one for the nocure
function fst:apply_regeneration_to_legs () 

	nocure:found ("apply_regeneration_to_legs")	
	
end --function.


function fst:apply_regeneration_to_arms () 

	nocure:found ("apply_regeneration_to_arms")	
	
end --function


function fst:apply_regeneration_to_head ()

	nocure:found ("apply_regeneration_to_head")	
	
end --function


function fst:apply_regeneration_to_chest ()

	nocure:found ("apply_regeneration_to_chest")	
	
end --function


function fst:apply_regeneration_to_gut ()

	nocure:found ("apply_regeneration_to_gut")	
	
end --function


function fst:focus ()

	bals:onbal ("focus", "silent")
	local aff, cure = flags:bals_try ("focus")
	
	if cure then
		system:unqueue_cure (cure)
		flags:del (aff)
	end --if

end --function


function fst:brew ()

	flags:del ("brew")
	bals:onbal ("brew", "silent")
	
end --function


function fst:orgpotion ()

	flags:del ("orgpotion")
	
end --function


function fst:prone ()

	fst:disable ("prone")
	flags:del ("prone")
	
end --function


function fst:scroll ()

	bals:onbal ("scroll", "silent")	
	flags:del ("healing")--healing is the only affliction that uses the scroll bal, for now
	
end --function

function fst:no_protection ()

	flags:del ({"no_protection", "bal"}) --the flag for reading scroll is scroll, to keep that in mind
	
end --function


function fst:deffing (silent)

	if flags:get ("waiting_for_def") then
		EnableTriggerGroup ("System_Def", false)
		EnableTrigger ("defstart", false)
		flags:del ("waiting_for_def")
	end --if
	flags:del ({"deffing", "bal"})--somewhat wrong, it could fire on a free action, it's harmless though
	
end --function


function fst:reject ()

	fst:disable ("reject")
	flags:del ({"reject", "bal"})
	
end --function


function fst:writhing (silent, start)
	
	fst:disable ("writhing")
	if not start then
		flags:del ("writhing")
	end--if
	flags:del ({"writhing_start", "bal"})
	
end --function
		

function fst:pipes_unlit ()

	fst:disable ("pipes_unlit")
	affs:del ("pipes_unlit")
	pipes:scan ()
	
end --function


function fst:pipes_refill ()

	fst:disable ("pipes_refill")
	affs:del ("pipes_refill")
	pipes:scan ()
	
end --function


function fst:fear ()

	fst:disable ("fear")
	flags:del ("fear")
	
end --function


function fst:disrupted ()

	fst:disable ("disrupted")
	flags:del ("disrupted")
	
end --function


function fst:ondef_rebound ()
	
	affs:del ("no_rebound")
	defs:ondef ("rebound")
	
end --function

	--CAN USE IT IN BLACKOUT?!
function fst:parry ()

	if flags:get ("waiting_for_parry") then
		EnableTriggerGroup ("System_Parry_Check", false)
		flags:del ("waiting_for_parry")
	end --if
	
	if flags:get ("parry") then --if it fires because of lag, and I receive the parry line just before the prompt, it won't execute
		parry:reset ("silent")
	end --if
	
	parry:init ()
	
end --function

function fst:stance ()
	
	if flags:get ("stance") then
		stance:reset ("silent")
	end --if
	flags:del ("bal")
	
	stance:init ()
	
end --function


function fst:demesne ()

	fst:disable ("demesne")
	ColourNote ("magenta", "", "DEMESNE GOING TO HIT! DEMESNE DEMESNE DEMESNE DEMESNE DEMESNE DEMESNE")
	
end --function


function fst:illusory_wounds ()

	fst:disable ("illusory_wounds")
	affs:del ("illusory_wounds")
	display.system ("Illusory Wounds Timed Out")
	
end --function

--don't drink speed in blackout
function fst:speed ()

	bals:onbal ("speed", "silent")	
	flags:del ("no_speed")
	
end --function


function fst:ondef_speed ()
	
	affs:del ("no_speed")
	system:cured ("no_speed", "silent")	
	defs:ondef ("speed")
	
end --function
	

function fst:ondef_protection ()
	
	defs:ondef ("protection")
	
end --function


function fst:ondef_orgpotion ()

	flags:del ("ondef_orgpotion")
	local potion = system:get_settings ("orgpotion")
	defs:ondef ("orgpotion", potion)
	
end --functino


function fst:no_insomnia ()
	
	if flags:get ("no_insomnia") == "insomnia" then
		flags:del ("no_insomnia")
	end --if
	
end --function


function fst:climbing (silent)--both for climbing down and up; enabled when you send the command, reset when you begin climbing, disabled when you finish climbing
	
	flags:del ("climbing")
	
end --function


function fst:pit ()
	
	flags:del ("pit")
	flags:del ("climbing")
	fst:disable ("climbing")
	EnableTrigger ("pit_climbedout", false)
	affs:del ("pit")
	display.cured ("pit")
	display.free ()

end --function
	


function fst:ondef_sixthsense ()

	affs:del ("no_sixthsense")
	
end --function


function fst:clotting ()

	fst:disable ("clotting")
	flags:del ("clotting")
	
end --function


function fst:asleep ()

	fst:disable ("asleep")
	flags:del ("asleep")
	
end --function


function fst:cleanse ()
	
	fst:disable ("cleanse")
	flags:del ({"cleanse", "bal"})
	
end --function


function fst:todo_free ()

	fst:disable ("todo_free")
	flags:del ("todo_free")
	
end --function


function fst:todo_bal ()

	fst:disable ("todo_bal")
	flags:del ({"todo_bal", "bal"})
	
end --function


function fst:ignite ()

	fst:disable ("ignite")
	flags:del ("ignite")
		
end --function


function fst:restore ()

	fst:disable ("restore")
	flags:del ({"restore", "bal"})
	
end --function


function fst:score (silent)

	EnableTrigger ("oldscore", false)
	EnableTrigger ("score_vitals", false)
	EnableTrigger ("qsc", false)
	EnableTrigger ("qsc_demi", false)
	fst:disable ("score")
	
end--function


function fst:arena (silent)

	EnableAlias ("arena_accept", false)
	EnableTriggerGroup ("System_Arena", true)
	
end --function


function fst:woundstatus ()

	EnableTriggerGroup ("")
	
end --function


function fst:rainbow_patterns ()

	EnableTriggerGroup ("System_Rainbows", false)
	affs:del ("rainbow_patterns")
	fst:disable ("rainbow_patterns")
	
end --function


function fst:maestoso ()

	fst:disable ("maestoso")
	affs:del ("maestoso")

end --function


function fst:displacement ()

	affs:del ("displacement")
	
end --function


function fst:stun ()

	system:cured ("stun", "silent")
	
end --function


function fst:powercure ()

	flags:del ("powercure")
	fst:disable ("powercure")
	
end --function


function fst:fastwrithe ()

	flags:del ({"fastwrithe", "bal"})
	fst:disable ("fastwrithe")
	
end --function


function fst:sca ()

	flags:del ("curing")
	
end --function


function fst:diag ()
	
	flags:del ({"diag", "bal"})
	fst:disable ("diag")
	
end --function


function fst:transmute ()

	flags:del ("transmute")
	fst:disable ("transmute")
	
end --transmute


function fst:metawake ()

	flags:del ("metawake")
	fst:disable ("metawake")

end --function


function fst:no_waterbreathe ()

	flags:del ({"no_waterbreathe", "bal"})
	
end --no_waterbreathe


function fst:no_waterwalk ()

	flags:del ({"no_waterwalk", "bal"})
	
end --no_waterbreathe


function fst:no_selfishness ()

	flags:del ({"no_selfishness", "bal"})
	
end --no_waterbreathe

function fst:no_sting ()

	flags:del ("no_sting")
	
end--no_sting


function fst:unwield ()

	flags:del ("unwield")
	
end--unwield


function fst:madfly ()
	
	flags:del_check ("madfly")
	
end--madfly

return fst
	
		
		