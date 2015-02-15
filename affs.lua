--[[
	IT WILL EVENTUALLY CONTAIN ALL THE AFFLICTION RELATED STUFF
	
]]--

require "flags"
--require "system"

if
	not affs
		then
	affs = {
		["cures"] = {},
		["current"] = {},
		["ninshi"] = {},
		["ootangk"] = {},
		["grapples"] = {},
		["hold"] = {}, --this is prevent standing
		["numbed"] = {},
		["lusts"] = {},
		["bleeding_levels"] = {150, 225, 300, 400, 550},
		["clots"] = {
			["number"] = 0,
		},
		["lacerations"] = {},
		["arteries"] = {},
		["affs_mental"] = {
			"addiction", "anorexia", "confusion", "dementia", "depression",
			"epilepsy", "generosity", "gluttony", "hallucinations", "hypersomnia", 
			"impatience", "loneliness", "lovers", "masochism", "paranoia", 
			"scrambled", "shyness", "stupidity", "void",},
		["impales"] = 0,
		["pinlegs"] = 0,
		["vessels"] = 0,
		["coils"] = 0,
		["custom"] = {},
		["insanity"] = {
			["none"] = 0,
			["slight"] = 1,
			["moderate"] = 15,
			["major"] = 30,
			["massive"] = 50,
			["number"] = 0,
		},
		["timewarped"] = {
			["none"] = 0,
			["slight"] = 1,
			["moderate"] = 15,
			["major"] = 30,
			["massive"] = 50,
			["number"] = 0, 
		},
		["unwielded"] = {},
		["unknown"] = 0,
		["number"] = 0,
	}
end --if

	
	--RESETS ALL AFFLICTIONS
function affs:reset ()
	
	self ["current"] = {}
	self ["ninshi"] = {}
	self ["ootangk"] = {}
	self ["grapples"] = {}
	self ["hold"] = {}
	self ["numbed"] = {}
	self ["clots"] = {
		number = 0,
	}
	self ["lacerations"] = {}
	self ["arteries"] = {}
	self ["unwielded"] = {}
	self ["vessels"] = 0
	self ["coils"] = 0
	self ["lusts"] = {}
	self ["impales"] = 0
	self ["pinlegs"] = 0
	self ["number"] = 0

	display.system ("Afflictions RESET")
	
end --function

	
	--COPIES A SET OF CURRENT AFFLICTIONS BASED ON A BALANCE
function affs:copy (sBal) --working; tested

	local my_affs = {}
	
	if type (sBal) == "table" then--if I pass a table of balances
		for k, b in ipairs (sBal) do --I parse it
			if
				next (self ["current"]) and
				self [b] --if there is such a balance in the stored affliction tables
					then
				for aff, no in pairs (self ["current"]) do
					if system:getkey (self [b], aff) then
						my_affs [aff] = self ["current"] [aff]
					end --if
				end --for
			end --if
		end --for
	else
		if 
			next (self ["current"]) and --if I have any afflictions
			self [sBal] --and there is such a balance stored in the affs table
				then
			for aff, v in pairs (self ["current"]) do --I go through all the afflictions that I have
				if system:getkey (self [sBal], aff) then--and if one of them is in the balance passed
					my_affs [aff] = self ["current"] [aff]
				end --if
			end --for
		end --if
	end --if
	
	return my_affs

end --function


	--main function to add afflictions
function affs:add (sAff, arg1, arg2, arg3, arg4, arg5)
	
	if type (sAff) == "table" then
		for k, v in ipairs (sAff) do
			affs:add (v, arg1, arg2, arg3)
		end --for
	else
		if affs [sAff] then
			affs [sAff] (self, arg1, arg2, arg3, arg4, arg5)
		else
			affs:add_simple (sAff, arg1, arg2)
		end --if
	end --function

end --function


function affs:add_simple (sAff, val, silent)
	
	if not val then
		val = true
	end --if
	
	if not self ["current"] [sAff] then		
		if sAff == "stun" then
			if not flags:get_check ("stun_immunity") then
				fst:enable ("stun")
				self ["current"] [sAff] = val
			end--if
		else
			self ["current"] [sAff] = val
			self ["number"] = self ["number"] + 1
		end--if
			--disrupted also gets detected based on the system time, so I might actually send a cure just before I add it
	elseif val ~= affs:has (sAff) then
		self ["current"] [sAff] = val
	end --if
	if not silent	then
		display.affs (sAff)
	end --if
	
end --function


	--stores an affliction in the queue; it will be unqueued if I reject it
function affs:add_queue (name, arg1, arg2, arg3, arg4, arg5)
	
	if type (name) == "table" then
		for k, a in ipairs (name) do
			prompt:queue (function () affs:add (a, arg1, arg2, arg3, arg4, arg5)end, "affs_add_"..a, true)
		end --for
	else
		prompt:queue (function () affs:add (name, arg1, arg2, arg3, arg4, arg5)end, "affs_add_"..name, true)
	end --if
	
	affs:reject_try ()

end --function


	--DELETES AN AFFLICTION FROM THE QUEUE
function affs:del_queue (name)
	local id
	if type (name) == "table" then
		id = tostring (os.time ())
	else
		id = name
	end --if
	prompt:queue (function () affs:del (name)end, "affs_del_"..id, true)
	
end --function

	
	--CREATES AND AFFLICTION; SNAME = affliction name, string; SQ = queue name, string; SCURE = cure, WITH SPACES, string; ODP = position in the queue, optional, digit
function affs:add_custom (sName, sQ, sCure, odP, duplicate) --creates an affliction;--I NEED TO ADD A CHECK FOR THIS IN THE CURED FUNCTION SOMETHING LIKE IF THERE ISN'T ANY FLAG FOR THE AFFLICTION, BUT THE CURE IS THE SAME AS THE ONE FOR NEW AFFLICTION, THEN I DELETE THE NEW AFFLICTION

	if not duplicate then
		sName = "custom_"..string.gsub (sName, " ", "_")..tostring (os.time ()) --making sure I have no spaces in the name
	else
		sName = "custom_"..string.gsub (sName, "  ", "_")
	end --if
	
	if not system:getkey (affs [sQ], sName) then--if I don't have already such an affliction stored
		if sCure ~= "drink_allheale" then--I treat allheale differently
			local tag = {}
			tag ["name"] = sName
			tag ["queue"] = sQ
			tag ["cure"] = string.gsub (sCure, " ", "_")
			tag ["duplicate"] = duplicate
			table.insert (affs ["custom"], tag)
		end --if
		if odP then--position
			if odP >= #self [sQ] then
				table.insert (affs [sQ], sName)
			else
				table.insert (self [sQ], odP, sName) --created the affliction in the sQ queue, at the specified place
			end --if
		else --if I don't specify a position
			table.insert (self [sQ], sName)
		end --if
		self ["cures"] [sQ]  [sName] = sCure --adds the cure
	end --if
	
	affs:add (sName, true, "silent")
	
end --function


function affs:del_custom (sCure)
	
	sCure = string.gsub (sCure, " ", "_")
	if sCure == "drink_allheale" then -- I can queue allheale multiple times
		for k, aff in ipairs (affs ["elixir"]) do--I have used allheale for the topmost affliction
			if affs ["cures"] ["elixir"] [aff] == "drink allheale" then
				affs:del (aff)
				table.remove (affs ["elixir"], k)--I remove the affliction from the queue
				affs ["cures"] ["elixir"] [aff] = nil--and from the cure list
			end --if
		end --for
	elseif next (affs ["custom"]) then--if I am tracking something else
		local aff = flags:is_sent (sCure)--what I was trying to cure with the cure
		if
			aff and
			string.find (aff, "custom_")
				then--if it was a custom affliction
			i=1
			repeat
				local tag = affs ["custom"] [i]
				if  tag ["name"] == aff then--if I found the custom affliction
					table.remove (affs [tag ["queue"]],system:getkey (affs [tag ["queue"]], aff))
					affs ["cures"] [tag ["queue"]] [aff] = nil
					table.remove (affs ["custom"], i)
					if not tag ["duplicate"] then
						i=#affs ["custom"]+1
					end --if
				else
					i=i+1
				end --if
			until i>#affs ["custom"]
			affs:del (aff)
		end --if
	end --if

end --function

	--getting the number of afflictions, not counting defenses
function affs:count (pcure)

	if affs ["number"] == 0 then
		return 0
	end --if
	
	local no = affs ["number"]
	if defs:has ("sixthsense") and affs:has ("blindness") then
		no = no-1
	end --if
	if affs:has ("love") and system:is_auto ("love") then
		no = no-1
	end --if
	if defs:has ("truehearing") and affs:has ("deafness") then
		no = no-1
	end --if
	if system:is_auto ("insomnia") and affs:has ("insomnia") then
		no = no-1
	end --if
	if affs:has ("rewield") then
		no=no-1
	end--if
	if pcure then
		local not_curable = {"prone", "mangled_leftleg", "mangled_rightleg", "amputated_rightleg", "amputated_leftleg",
"tendon_leftleg", "tendon_rightleg", "mangled_leftarm", "mangled_rightarm", "amputated_leftam",
"amputated_rightarm", "collapsednerve_rightarm", "collapsednerve_leftarm",}
		for k, aff in ipairs (not_curable) do
			if affs:has (aff) then
				no=no-1
			end --if
		end --for
		for k, v in ipairs ({"unconscious", "asleep"}) do
			if affs:has (v) then no=no-1 end --if
		end --for
	end--if
	return no
	
end --function

	--starting diagnose
function affs:diag_start ()

	prompt:queue (function () affs:diag_end () end, "affs_diag_end")
		--I treat the sluggish affliction like a normal alert on the prompt, since I can't do a thing about it
	prompt:queue (function () prompt:del_alert ("sluggish") end, "del_sluggish")
	affs:del ("diag")
	fst:disable ("diag")
	EnableTriggerGroup ("System_Diag", true)
	
	if affs:has ("pit") then flags:add_check ("pit") end
	if affs:has ("unwield") then flags:add_check ("unwield") end
	if next (affs.current) then
		for n, v in pairs (affs.current) do
			if string.find (n, "no_") then
				flags:add_check ("n", "aff")
			end--if
		end--for
	end--if
	
	for i=1,4 do
		if affs:has ("crotamine_"..tostring (i)) then
			flags:add_check ("crotamine", tostring (i))
			break
		end --if
	end --for
	
	for i=1,2 do
		if affs:has ("sunallergy_"..tostring (i)) then
			flags:add_check ("sunallergy", tostring (i))
			break
		end --if
	end --for
	
	if affs:has ("deathmark") then
		flags:add_check ("deathmark", affs:has ("deathmark"))
	end--if
	
	defs:lostdef ("insomnia", "silent")
	flags:add_check ("impales", 0)
	flags:add_check ("pinlegs", 0)
	affs ["current"] = {}
	affs ["clots"] = {number = 0,}
	affs ["numbed"] = {}
	affs ["lacerations"] = {}
	affs ["arteries"] = {}
	affs ["vessels"] = 0
	affs ["coils"] = 0
	affs ["unknown"] = 0
	fst:disable ("sca")
	flags:del ("curing")

	EnableTrigger ("prompt_sap", false)
	EnableTrigger ("prompt_aeon", false)
	EnableTrigger ("prompt_choke", false)
	
end --function

	--ending diag
function affs:diag_end ()

	if 
		flags:get_check ("impales") == 1 and
		affs ["impales"] ==0 
			then
		affs:impaled ()
	end --if
		--useless, since you cannot diag while pinleg
	if
		flags:get_check ("pinlegs")>0 and
		affs ["pinlegs"]<flags:get_check ("pinlegs")
			then
		affs:pinleg (flags:get_check ("pinlegs"))
	end--if
	if flags:get_check ("pit") then affs:add ("pit", true, true) end
	if flags:get_check ("unwield") then affs:add_simple ("unwield") end
	if next (flags.checking) then
		for k, v in pairs (flags.checking) do
			if v=="aff" then
				affs:add_simple (v)
				flags:del_check (k)
			end--if
		end--for
	end--if
	
	flags:del_check ({"pit", "pinlegs", "impales", "sunallergy", "crotamine", "deathmark"})
		
	EnableTriggerGroup ("System_Diag", false)
	affs:scan_lusted ()
	wounds:scan ()--here is where I parry
	
end --function

	--CHECKS IF I HAVE A CERTAIN AFFLICTION
function affs:has (sAff)
		
	local result = false
	
	if
		sAff and --if I actually passed an argument
		next (self ["current"]) --and if I have any afflictions
			then
		result = self ["current"] [sAff]
	
	end --if
	return result

end --function


	--DELETES AN AFFLICTION, OR A TABLE OF AFFLICTIONS, AS WELL AS ALL THE FLAGS FOR IT, IF ANY
function affs:del (sAff, cured) --track - I'm still tracking its progress

	if type (sAff) == "table" then--if I'm passing a table of afflictions
		for k, aff in pairs (sAff) do --it will be a vector of afflictions
			affs:del (aff, cured) --I'm calling the function for each value of the table
		end --for
	elseif sAff then
		if
			self ["current"] [sAff] and
			self ["number"] >0
				then
			display.deb ("AFFS:DEL -> "..tostring (sAff))
			self ["number"] = self ["number"] -1
		elseif 
			(not self ["current"] [sAff] or string.find (sAff, "custom_"))
			and cured and 
			not string.find (sAff, "no_") 
				then
			affs:masked (-1)
			display.deb ("AFFS:DEL -> affliction "..tostring (sAff).." previously not known")
		end --if
		self ["current"] [sAff] = nil
		flags:del (sAff)
	end --if

end --function


	--CHECKS IF A PARTICULAR CURE IS A CURE FOR THE AFFLICTION, WITH THE BALANCE SUPPLIED
function affs:is_cure (sCure, sBal, sAff)
	
	sCure = string.gsub (sCure, " ","_")
	if sBal == "purg" or sBal == "speed" then
		sBal = "elixir"
	end --if
	if sCure == "drink_allheale" then
		return (system:getkey (self ["ah"], sAff) or false)
	elseif self ["cures"] [sBal] [sAff] then
		if sCure == "eat_faeleaf" and sBal == "herb" and sAff == "blindness" then
			return true
		elseif sCure == "eat_earwort" and sBal == "herb" and sAff == "deafness" then
			return true
		else
			local cure = string.gsub (self ["cures"]  [sBal] [sAff], " ", "_")
			return (string.find (cure, sCure))
		end--if
	else
		return false
	end --if

end --function

	--if I have mental afflictions, for dealing with jinx
function affs:is_mental ()
	
	for k, aff in ipairs (self.affs_mental) do
		if affs:has (aff) then
			return true
		end--if
	end
	return false
	
end
	
	--RETURNS THE CURE OF A PARTICULAR AFFLICTION, WITH THE BALANCE SUPPLIED
function affs:get_cure (sBal, sAff) --the balance for the affliction, sAff the affliction
	
	return self ["cures"] [sBal] [sAff]
		
end --function


	--RETURNS THE BALANCE FOR A CERTAIN CURE
function affs:get_bal (sCure)

	if sCure then	
		sCure = string.gsub (sCure, " ", "_")
		return self ["balances"] [sCure]
	else
		display.deb ("AFFS:GET_BAL -> no cure passed")
	end --if
	
end --function

	
--[[
		SPECIAL FUNCTIONS TO ADD SOME VERY NASTY AFFLICTIONS
	
	]]--
	
	--tracking of unknown afflictions and diagnosing when necessary
function affs:masked (number)

	if not number then
		number = 1
	end --if
	
	Note ("AFFS:MASKED -> adding "..tostring (number).." affs to an existent "..tostring (affs ["unknown"]))
	affs ["unknown"] = affs ["unknown"] + number
	if affs ["unknown"] < 0 then
		affs ["unknown"] = 0
	end--if
	if 	system:is_enabled ("diag") then
		if affs ["unknown"] >= system:get_settings ("masked") then
			affs:add_simple ("diag", true, "silent")
		else 
			affs:del ("diag")
		end
	end--if
	
	local allheale_number = (system:get_settings ("allheale") or 0)
	if 	allheale_number >0 and
		affs ["unknown"] >= allheale_number and
		bals:has ("ah") and
		able:to ("drink")
			then
		local no_ah = true
		for k, v in pairs (affs ["current"]) do
			if affs:get_cure ("elixir", v) == "drink allheale" then
				no_ah = nil
				break
			end--if
		end--for
		if no_ah then
			affs:add_custom ("masked", "elixir", "drink allheale")
		end--if
	end--if
	
end --function

	--tracking of aeon and speed stripping
function affs:aeon (now)
	
	if defs:has ("speed") and not now then
		defs:del_queue ("speed")
	else
		affs:add_simple ("aeon")
		flags:add_check ("reset_bals")
		EnableTrigger ("prompt_aeon", true)
	end --if
	
end --function


function affs:sap ()
	
	affs:add_simple ("sap")
	flags:add_check ("reset_bals")
	EnableTrigger ("prompt_sap", true)
	
end --function
	
	
function affs:prone (aff)	
	
	if type (aff) == "table" then
		for k, a in ipairs (aff) do
			affs:prone (a)
		end--for
	elseif aff then
		if affs:has (aff) then 
			return
		end --if
		prompt:queue (function () table.insert (flags ["checking"] ["prone"], aff)end, "affs_add_"..aff, true)
	else
		if affs:has ("prone") then
			return
		end--if
		prompt:queue (function () table.insert (flags ["checking"] ["prone"], "prone")end, "affs_add_prone", true)
	end--if

end --function


function affs:bal (aff)

	if type (aff) == "table" then
		for k, a in ipairs (aff) do
			affs:bal (a)
		end--for
	elseif aff then
		if affs:has (aff) then 
			return
		end --if
		prompt:queue (function () table.insert (flags ["checking"] ["bal"], aff)end, "affs_add_"..aff, true)
	end--if
	
end --function


function affs:asleep ()

	EnableTriggerGroup ("System_Awaken", true)
	if defs:has ("insomnia") then
		defs:lostdef ("insomnia")
	end--if
	affs:add_simple ("asleep")
	
end --function

	--getting hit by a hex, assuming it is a whammy or double whammy
function affs:hex ()

	flags:add_check ("recklessness")
	flags:add_check ("vapors")
	flags:add_check ("hex", (flags:get_check ("hex") or 0)+1)
	affs:add ("blackout")
	system:poisons_on ()

end --function

	--detecting a hex
function affs:del_hex ()

	local hn = flags:get_check ("hex") --if I got hit by a hex
	if hn then
		if hn==1 then --only once before getting the affliction
			flags:del_check ({"hex", "recklessness"})--I have detected all the hex attacks
		else
			flags:add_check ("hex", 1)--I still have one more hex attack to detect
		end--if
	end --if
	
end --del_hex

	--when I get hit with a poison
function affs:poison (aff)

	if aff then
		affs:add_queue (aff)
	end--if
	flags:del_check ("spiders")--crow spiders hit with chills, clumsiness or sensitivity. No message for sensitivity
	affs:del_hex ()
	
end --function
		

function affs:bleeding (amnt, total) --I should first delete all the other bleeding afflictions

	amnt=tonumber (amnt)
	for aff, val in pairs (self ["current"]) do
		if string.find (aff, "bleeding_") then
			if not total then
				amnt=val+amnt
			end --if
			affs:del (aff) --if I am trying to cure bleeding with chervil, then I alse delete the flag. But I won't send two cures at the same time becuse I am offbal
		end --if
	end --for		
	
	if amnt>=affs ["bleeding_levels"] [5] then
		affs:add ("bleeding_5", amnt, "silent")
	elseif amnt>=affs ["bleeding_levels"] [4] then
		affs:add ("bleeding_4", amnt, "silent")
	elseif amnt>=affs ["bleeding_levels"] [3] then
		affs:add ("bleeding_3", amnt, "silent")
	elseif amnt>=affs ["bleeding_levels"] [2] then
		affs:add ("bleeding_2", amnt, "silent")
	elseif amnt>=system ["settings"] ["clot_threshold"] then
		affs:add ("bleeding_1", amnt, "silent")
	end --if
	
end --function


function affs:freezing (poison)

	if defs:has ("fire") then
		defs:del_queue ("fire")
	elseif affs:has ("chills") then
		affs:prone ("frozen")
	else
		affs:add_queue ("chills")
	end --if
	
end --function


function affs:clot (part) --to check what the clot cured trigger is

	if not (self ["clots"] [part]) then
		if self ["clots"] ["number"] >= 4 then
			display.error ("affs:clot -> you cannot have more than 4 clots")
			return
		end --if
		self ["clots"] [part] = 1
		self ["clots"] ["number"] = self ["clots"] ["number"]+1
		affs:add ("clot_"..tostring (self ["clots"] ["number"]), "", "silent")
	end --if
	
	display.affs ("clot "..part.." ("..tostring (self ["clots"] ["number"]).." clots)")
	
end --function


function affs:lacerated (part, cure)
		
		--reset
	if not part then
		for i=1,4 do
			affs:del ("lacerated_"..i)
		end --for
		self ["lacerations"] = {}
		return
	end--if
	
	if cure and self ["lacerations"] [part] then
		for i=1,4 do
			affs:del ("lacerated_"..tostring (i))
		end --for
		
		self ["lacerations"] [part] = nil
		local no = 0
		for k, v in ipairs ({"lefleg", "rightleg", "leftarm", "rightarm"}) do
			if self ["lacerations"] [v] then
				no = no+1
			end
		end --for
		if no>0 then
			affs:add_simple ("lacerated_"..tostring (no), true, "silent")
		end --if
		return
	end --if
	
	if not (self ["lacerations"] [part]) then
	
		for i=1,4 do
			affs:del ("lacerated_"..tostring (i))
		end --for
		
		self ["lacerations"] [part] = true
		local no = 0
		for k, v in ipairs ({"leftleg", "rightleg", "leftarm", "rightarm"}) do
			if self ["lacerations"] [v] then
				no = no+1
			end
		end --for
		if no>0 then
			affs:add_simple ("lacerated_"..tostring (no), true, "silent")
		end --if
	end --if
	display.affs ("Lacerated "..part)--just so I know I am registering the affliction
	
end --function


function affs:artery (part, cure)
	
		--reset
	if not part then
		for i=1,5 do
			affs:del ("artery_"..tostring (i))
		end --for
		self ["arteries"] = {}
		return
	end--if
	
	if cure and self ["arteries"] [part] then
		for i=1,5 do
			affs:del ("artery_"..tostring (i))
		end --for
		
		local no = 0
		for k, v in ipairs ({"lefleg", "rightleg", "leftarm", "rightarm", "head"}) do
			if self ["arteries"] [v] then
				no = no+1
			end
		end --for
		if no>0 then
			affs:add_simple ("artery_"..tostring (no), true, true, "silent")
		end --if
		return
	end --if

	if not (self ["arteries"] [part]) then
	
		for i=1,5 do
			affs:del ("artery_"..tostring (i))
		end --for
		
		self ["arteries"] [part] = true
		local no = 0
		for k, v in ipairs ({"lefleg", "rightleg", "leftarm", "rightarm", "head"}) do
			if self ["arteries"] [v] then
				no = no+1
			end
		end --for
		if no>0 then
			affs:add_simple ("artery_"..tostring (no), true, "silent")
		end --if
	end --if
	display.affs ("Artery "..part)--just so I know I am registering the affliction
	
end --function


function affs:vessel (count, add)

	local number = affs ["vessels"]
	if not count then 
		number = number+1
	elseif add then 
		number = number+count
	else 
		number = count
	end--if
	
		--only 2 vessels per clot
	if number<affs ["clots"] ["number"]*2 then
		number = affs ["clots"] ["number"]*2
	end--if
	
	affs:del ({"vessels_critical", "vessels_low", "vessels_med"})
	if number>0 then
		if number>=8 then
			affs:add_simple ("vessels_critical")
		elseif number >=4 then
			affs:add_simple ("vessels_low")
		else
			affs:add_simple ("vessels_med")
		end --if
	else
		number = 0
	end--if
	
	affs ["vessels"] = number
	
end --function

function affs:coil (count, add)

	local number = affs ["coils"]
	if not count then 
		number = number+1
	elseif add then 
		number = number+count
	else 
		number = count
	end--if
		--maximum of 8 coils
	if number>8 then
		number = 8
	end --if
	
	for i =1,8 do
		affs:del ("coil_"..tostring (i))
	end --if
	if number>0 then
		affs:add ("coils_"..tostring (number))
	else
		number = 0
	end --if
	
	affs ["coils"] = number
	
end --function

	--tea repeling afflictions
function affs:repel (name)
	
	name = string.lower (name)
	if
		name == "prone" or
		name == "entangled" or
		name == "paralysis" or
		name == "stunned" or
		name == "frozen" or
		name == "roped" or
		name == "impaled" or
		name == "shackled"
			then
		prompt:queue (function ()
			for i,v in ipairs(affs.prone_check) do
				if v == name then
					table.remove(affs.prone_check, i)
				end
			end
		end, "affs_repel")
	else
		prompt:unqueue ("affs_add_"..name)
		local is_telepaff = flags:get_check ("telepathy") or 0
		if is_telepaff == 1 then
			flags:del_check ("telepathy")
		elseif is_telepaff == 2 then
			flags:add_check ("telepathy", 1)
		end--if
	end --if
	affs:add_queue ("masked", -1)
	
end --function

function affs:reject_try ()

	if defs:has ("rubeus") then
		EnableTrigger ("reject_rubeus", true)
		prompt:queue (function () EnableTrigger ("reject_rubeus", false) end, "reject_rubeus")
	end
	
	if defs:has ("lich") or defs:has ("archlich") then
		EnableTrigger ("reject_lichdom", true)
		prompt:queue (function () EnableTrigger ("reject_lichdom", false) end, "reject_rubeus")
	end
	EnableTrigger ("reject_shrug", true)
	
end--queue_reject

	--for abilities that reject afflictions, like rubeus, lichdom or tea, or whatever
function affs:reject (ability)

	if ability == "rubeus" then
		local is_rejected = {"pacifism", "lovers", "shyness", "lust", "fear"}
		for k, aff in ipairs (is_rejected) do
			prompt:unqueue ("affs_add_"..aff)
		end--for
		affs:add_queue ("masked", -1)
	elseif ability == "lichdom" then
		for k, aff in ipairs (self.affs_mental) do
			prompt:unqueue ("affs_add_"..aff)
		end--for
		affs:add_queue ("masked", -1)
	elseif ability == "shrug" then
		system:del_cure ()
		prompt:unqueue ("fetish")
		flags:del_check ({"fetish", "spiders"})
	end--if
	
	affs:del_hex ()
	
end--for

	--GRAPPLES!
function affs:grappled (part, person, option)
		
		-- If there is no person grappling it, remove it
	if not person then
		if part then
			self ["grapples"] [part] = nil
			self ["ninshi"] [part] = nil
			self ["ootangk"] [part] = nil
			self ["hold"] [part] = nil
		else --if called without any arguments, reset it
			self ["grapples"] = {}
			self ["ninshi"] = {}
			self ["ootangk"] = {}
			self ["hold"] = {}
		end
	elseif not part then
			-- Person's name with no body part means ungrapple everything that person might have held
		local has_more, is_grapple = false
		for k, p in ipairs ({ "chest", "gut", "head", "leftarm", "leftleg", "rightarm", "rightleg", "body" }) do
			if self ["grapples"] [p] ~= person then
				has_more = true
			end--if
			if self ["grapples"] [p] == person then
				is_grapple = p
			end--if
		end--for
			--if I was grappled by the person that ungrappled
		if is_grapple then
				--if I don't have any more grapples and I was writhing grapple
			if 	not has_more and
				(flags:get ("writhing_start") or flags:get ("writhing") or "nil") == "grappled"
					then
				system:cured ("writhe", "grappled", person)
			end--if
			self ["grapples"] [is_grapple] = nil
		end--if
	else
		self ["grapples"] [part] = person
		if option == "ninshi" then
			self ["ninshi"] [part] = true
		elseif option == "ootangk" then
			self ["ootangk"] [part] = true
		elseif option == "hold" then
			self ["hold"] [part] = true
		end --if
	 end
  
	self:scan_grappled ()

end


	--ADDS THE GRAPPLED AFFLICTION IF NECESSARY
function affs:scan_grappled ()

	if
		self ["grapples"] ["chest"] or
		self ["grapples"] ["gut"] or
		self ["grapples"] ["head"] or
		self ["grapples"] ["leftarm"] or
		self ["grapples"] ["leftleg"] or
		self ["grapples"] ["rightarm"] or
		self ["grapples"] ["rightleg"] or
		self ["grapples"] ["body"]
			then
		affs:add_simple ("grappled")
	else
		self ["ninshi"] = {}
		self ["ootangk"] = {}
		self ["hold"] = {}
		affs:del ("grappled")
	end --if
	
end--function


function affs:numb (part, diag, cured)

	if not part then
		return display.error ("Specify a numbed body part")
	end --if
	
	if diag then
		self ["numbed"] [part] = true
	else
		if cured then
			self ["numbed"] [part] = nil
		else
			local bp = {["head"] = {"head", "chest", "leftarm", "rightarm"},
							["chest"] = {"head", "gut", "chest", "leftarm", "rightarm"},
							["gut"] = {"chest", "leftleg", "rightleg"},
							["leftarm"] = {"leftarm", "chest", "gut", "head"},
							["rightarm"] = {"rightarm", "chest", "gut", "head"},
							["leftleg"] = {"leftleg", "gut", "rightleg"},
							["rightleg"] = {"leftleg", "gut", "rightleg"},}
			for k, v in ipairs (bp [part]) do
				affs ["numbed"] [v] = true
			end --for
		end --if
	end --if
	
	for k, part in ipairs ({"chest", "gut", "head", "leftarm", "rightarm", "rightleg", "leftleg"}) do
		affs:del ("numb_"..part)
		if affs ["numbed"] [part] then
			affs:add_simple ("numb_"..part, true, cured)--if I am cured it won't show the message
		end --if
	end --if
	
end --function


function affs:burned (level)

	local burn_levels = {["first"] = "1", ["second"] = "2", ["third"] = "3", ["fourth"] = "4",}
	
	for k, lvl in ipairs (burn_levels) do
		affs:del ("burns_"..lvl)
	end --for
	if #level == 0 then
		return
	end --if
	affs:add_queue ("burns_"..burn_levels [level])
	
end --function


function affs:impaled (amnt)
	
	if not amnt then
		amnt = 1
	end --if
	
	if amnt == 0 then
		affs:del ("impaled")
		affs:del ("crucified")
		affs ["impales"]=0
	else
		affs ["impales"] = affs ["impales"]+amnt
		if amnt == -1 then--this means I've successfully writhed from an impale
			system:cured ("impaled")	
			affs:del ("crucified")
		end--if
		if affs ["impales"]<0 then affs ["impales"] = 0 end
		
		if affs ["impales"]>0 then--if I still have impales
			if not affs:has ("impaled") then
				affs:add_simple ("impaled")
			end --if
		else--if I don't, I make sure I remove any impale related afflictions
			display.free ()
		end --if
	end --if

end --function


function affs:pinleg (amnt)
	
	if not amnt then
		amnt = 1
	end --if
	
	if amnt == 0 then
		affs:del ("pinleg")
		affs:del ("crucified")
		affs ["pinlegs"]=0
	else
		affs ["pinlegs"] = affs ["pinlegs"]+amnt
		if amnt == -1 then--this means I've successfully writhed from an impale
			system:cured ("pinleg")
		else
			if (flags:get ("no_insomnia") or "") == "insomnia" then
				fst:fire ("no_insomnia", "now")
			end--if
		end--if
		if affs ["pinlegs"]<0 then affs ["pinlegs"]=0 end
		
		if affs ["pinlegs"]>0 then--if I still have impales
			affs:add_simple ("pinleg")
		else--if I don't, I make sure I remove any impale related afflictions
			display.free ()
		end --if
	end --if

end --function


function affs:insawarped (aff, amnt, threshold)

	if not aff then
		return display.warning ("ERROR - you must supply an affliction to affs:paradigmatics!")
	end --if

	if not amnt then amnt=1 end
	local new = amnt + (affs [aff] ["number"])
	
	if amnt<0 then --this means I cured insanity
		local had = affs [aff] ["number"]
		if had > affs [aff] ["major"] then
			had = "massive"
		elseif had > affs [aff] ["moderate"] then
			had = "major"
		elseif had > affs [aff] ["slight"] then
			had = "moderate"
		else
			had = "slight"
		end --if
		system:cured (aff.."_"..had)
		if (threshold or "nil") == "none" then
			affs [aff] ["number"] = 0
			return affs:del ({aff.."_slight", aff.."_moderate", aff.."_major", aff.."_massive",})
		end --if
		if
			threshold and --I check if the insanity remaining is bigger than what I have tracked
			affs [aff] [threshold] > new 
				then
			affs [aff] ["number"] = affs [aff] [threshold]
			return affs:add_simple (aff.."_"..threshold)
		end --if
	end --if
		--tracking the power of insanity/timewarped afflictions that I have
	if new < 1 then --if by some weird coincidence the curing made me have less than one insanity/timewarped
		affs [aff] ["number"] = 1
	else
		affs [aff] ["number"] = new
	end --if
		--adding the affliction as needed
	if new > affs [aff] ["major"] then
		new = "massive"
	elseif new > affs [aff] ["moderate"] then
		new = "major"
	elseif new > affs [aff] ["slight"] then
		new = "moderate"
	else
		new = "slight"
	end --if
	affs:add_simple (aff.."_"..new)
	
end --function
	

function affs:burning ()

	EnableTrigger("aff_pyro_burnlevel", true)
	prompt:queue (function () EnableTrigger("aff_pyro_burnlevel", false) end, "affs_burning")
	
end --function

function affs:hypnogaze (text)
  local colors = {
		["azure"] = function () affs:add_queue("dizziness") end,
		["cerulean"] = function () affs:add_queue("confusion") end,
		["crimson"] = function () affs:prone("paralysis") end,
		["emerald"] = function () affs:add_queue("vertigo") end,
		["fuchsia"] = function () affs:add_queue("daydreaming") end,
		["lavender"] = function () affs:add_queue("pacifism") end,
		["mauve"] = function () affs:add ("blackout") flags:add_check ("vapors") end,
		["pink"] = function () affs:add_queue("hallucinations") end,
		["purple"] = function () affs:add_queue ("blackout") end,
		["scarlet"] = function () affs:add_queue("fear") end,
		["sapphire"] = function () affs:add_queue("dementia") end,
		["topaz"] = function () affs:add_queue("stupidity") end
	  }
	for c,a in pairs(colors) do
		if string.find(text, c) then
			a()
		end--if
	end--for

end--function


function affs:glamour (text)
	local colors = {
		["incandescent blue striations"] = function () affs:add_queue("recklessness") end,
		["vibrant orange hues"] = function () affs:add_queue("stupidity") end,
		["scarlet red light"] = function () affs:prone("paralysis") end,
		["bright yellow flashes"] = function () affs:add_queue("dementia") end,
		["deep indigo whorls"] = function () flags:add_check ("recklessness") end,
		["emerald green iridescence"] = function () affs:add_queue("epilepsy") end,
		["lustrous violet swirls"] = function () affs:add_queue("dizziness") end,
	}
  for c,a in pairs(colors) do
	 if string.find(text, c) then
		a ()
	 end--if
  end--for
  
end--function


function affs:blackout ()

		-- Turn on blackout prompt trigger
	EnableTriggerGroup ("System_Blackout", true)
	system:poisons_on()
	EnableTriggerGroup ("System_Cures", true)
		-- You don't see the 'You take a drink' messages, so we need to
end--function


function affs:in_trees ()

	flags:add_check ("in_trees")
	if system:is_enabled ("notrees") then
		flags:del ("climbing")
		fst:disable ("climbing")
		affs:add_simple ("intrees")
	end--if
	
end --function


function affs:lusted (name, rejected)

	if rejected then
		affs ["lusts"] [name] = nil
		if adven:is_enemy_list (name) then
			adven:queue_enemy (name)
		end --if
	else
		affs ["lusts"] [name] = true
	end --if
	affs:scan_lusted ()
	
end --function


function affs:scan_lusted ()

	affs:del ("lust")
	if next (affs ["lusts"]) then
		if not affs:has ("lust") then
			for name, v in pairs (affs ["lusts"]) do
				if system:get_settings ("rejecting") == "enemies" then
					if system:is_enemy (name) then
						affs:add_queue ("lust", name)
						break
					end --if
				elseif system:get_settings ("rejecting") == "all" then
					affs:add_queue ("lust", name)
					break
				end --if
			end --for
		end --if
	end --if
	
end --function


function affs:runes (rune1, rune2, person)
	if person then
		if not flags:get("antirunes_" .. person) then
			flags:add ("antirunes_" .. person, person)
			affs:runes (rune1, rune2)
			if IsTimer ("antirunes_"..person) ~= 0 then
				local minutes = math.floor(1/60)
				local seconds = 1
				ImportXML([[<timers>
	<timer
	 name="antirunes_]]..person .. [["
	 minute="]] .. minutes .. [["
	 second="]] .. seconds .. [["
	 offset_second="0.00"
	 send_to="12"
	 group="System_Fst" >
  <send>flags:del("antirunes_]] ..person.. [[")
  DeleteTimer ("antirunes_]]..person..[[")</send>
  </timer>
  </timers>]])
				SetTimerOption ("antirunes_"..person, "second", 1)	
				EnableTimer ("antirunes_"..person, true)
				ResetTimer ("antirunes_"..person)
			else
				ResetTimer ("antirunes_"..person)
			end --if
		end --if
		return
	end--if

	local rune_affs = {
		["ansuz"] = "hypochondria",
		["beorc"] = "shyness",
		["cen"] = "stupidity",
		["daeg"] = "illuminated",
		["eh"] = "recklessness",
		["eoh"] = "confusion",
		["eohl"] = "pacifism",
		["feoh"] = "masochism",
		["ger"] = "impatience",
		["gyfu"] = "paralysis",
		["ing"] = "lovers",
		["lagu"] = "dementia",
		["manna"] = "disloyalty",
		["nyd"] = "sensitivity",
		["peorth"] = "hallucinations",
		["tiwaz"] = "justice",
		["ur"] = "gluttony",
		["wynn"] = "loneliness",
	}

	if rune1 == "othala" then
		affs:masked (1)
	elseif rune1 == "haegl" then
		flags:add_check ("recklessness")
	elseif rune1 == "sigil" then
		display.warning ("Check DEF!")
	elseif rune1 == "rad" then
		display.warning ("Moved by Rad Rune!")
	elseif rune1 == "isa" then
		affs:freezing ()
	else
		affs:add_queue(rune_affs[rune1])
	end--if

	if not rune2 then
		return
	end--if

	if rune2 == "othala" then
		affs:masked (1)
	elseif rune2 == "haegl" then
		flags:add_check ("recklessness")
	elseif rune2 == "sigil" then
		display.warning ("Check DEF!")
	elseif rune2 == "rad" then
		display.warning ("Moved by Rad Rune!")
	elseif rune2 == "isa" then
		affs:freezing ()
	else
		affs:add_queue(rune_affs[rune2])
	end--if
	
end--function

	-- Astrology afflictions, based on nativity
function affs:astro (sign)
	display.deb ("Astrology Sign: " .. sign)
  
	if sign == "Sun" then
	 flags:damaged ()
	 return
  end

  if not my_nativity then
	 return display.warning ("Check your nativity!")
  end

  local sphere = my_nativity [sign]
  if not sphere then
	 display.warning (sign .. " not in your nativity setup")
	 return false
  end

  if sphere == "Spider" or sphere == "Antlers" or sphere == "Lion" or sphere == "Bumblebee" then
	 sphere = 1
  elseif sphere == "Volcano" or sphere == "Dolphin" or sphere == "Burning Censer" or sphere == "Skull" then
	 sphere = 2
  elseif sphere == "Twin Crystals" or sphere == "Dragon" or sphere == "Glacier" or sphere == "Crocodile" then
	 sphere = 3
  else
	 debug.error ("Invalid sphere in your nativity: " .. tostring(sphere))
	 return
  end
  
  local signs = {
	 ["Moon"] = { "dizziness", "hallucinations", "dementia" },
	 ["Eroee"] = { "peace", "sensitivity", "lovers" },
	 ["Sidiak"] = { "epilepsy", "stupidity", "confusion" },
	 ["Tarox"] = { "asthma", "recklessness", affs.freezing },
	 ["Papaxi"] = { "health_curse", "ego_curse", "mana_curse" },
	 ["Aapek"] = { "anorexia", affs.aeon, "scabies" }
  }

  local aff = signs [sign] [sphere]
  if not aff then
	 display.error ("Missing " .. sign .. "/" .. my_nativity[sign] .. " aff in affs:astro function")
	 return
  end

  if type(aff) == "function" then
	 aff (self)
  else
	 affs:add (aff)
  end--if

end

	--copied to nocure
function affs:impatience ()
	
	if not affs:has ("impatience") then
		if 
			(flags:is_sent ("focus_body") or flags:is_sent ("focus_spirit")) and
			bals:get ("focus") == 0.5
				then
			fst:fire ("focus", true)--I can still focus mind if I have impatience
		end --if
		affs:add_simple ("impatience")
	end --if
	
end --function


function affs:stupidity ()

	local is_curing
	if not affs:has ("fracturedskull") then
		affs:add_simple ("stupidity")
			--only retrying if I am curing with penny, focusing will destroy my mana
		if (flags:get ("stupidity") or "nil") == "eat_pennyroyal" then
			is_curing = "eat_pennyroyal"
		end --if
	else
		is_curing = flags:get ("fracturedskull")
	end --if
	if is_curing then
		fst:fire (affs:get_bal (is_curing))
	end --if
	
end --function


function affs:asthma ()

	if not affs:has ("asthma") then
		if flags:get ("smoking") then
			fst:herb ()--I can eat herbs while I have asthma
		end --if
		affs:add_simple ("asthma")
	end --if
	
end --function


function affs:collapsedlungs ()

	if not affs:has ("collapsedlungs") then
		if 
			flags:get ("smoking") and
			flags:get ("smoking") ~= "smoke_faeleaf"
				then
			fst:herb ()--I can use herbs while I have asthma
		end --if
		affs:add_simple ("collapsedlungs")
	end --if
	
end --function


function affs:blacklung ()

	if not affs:has ("blacklung") then
		if 
			flags:get ("smoking") and
			flags:get ("smoking") ~= "smoke_faeleaf"
				then
			fst:herb ()--I can use herbs while I have asthma
		end --if
		affs:add_simple ("blacklung")
	end --if
	
end --function

	--copied to nocure
function affs:slickness ()
	
	if not affs:has ("slickness") then
		local cure = flags:get ("applying")
		if cure then
			if string.find (cure, "apply_health_to_") then
				fst:elixir ()--I can still drink health if I have slickness
			elseif string.find (cure, "apply_arnica_to_") then
				fst:herb ()--I can still eat herbs if I have slickness
			end --if
		end --if
		affs:add_simple ("slickness")
	end --if
	
end --function


function affs:windpipe ()

	if not affs:has ("windpipe") then
		if
			bals:get ("herb") == 0.5 and
			not flags:get ("smoking") and
			not string.find ((flags:get ("applying") or "nil"), "apply_arnica_to_")
				then --windpipe doesn't prevent smoking or applying arnica
			fst:herb ()
		end
		if
			bals:get ("elixir") == 0.5 and
			not string.find ((flags:get ("applying") or "nil"), "apply_health_to_")
				then --I still can apply healing
			fst:elixir ()
		end --if
		affs:add_simple ("windpipe")
	end --if
	
end --function


function affs:slitthroat ()

	if not affs:has ("slitthroat") then
		if
			bals:get ("herb") == 0.5 and
			not flags:get ("smoking") and
			not string.find ((flags:get ("applying") or "nil"), "apply_arnica_to_")
				then --slitthroat doesn't prevent smoking
			fst:herb ()
		end
		if
			bals:get ("elixir") == 0.5 and
			not string.find ((flags:get ("applying") or "nil"), "apply_health_to_")
				then --I still can apply healing
			fst:elixir ()
		end --if
		affs:add_simple ("slitthroat")
	end --if
	
end --function


function affs:throatlock ()
	
	if not affs:has ("throatlock") then
		if
			bals:get ("herb") == 0.5 and
			not flags:get ("smoking") and
			not string.find ((flags:get ("applying") or "nil"), "apply_arnica_to_")
				then --throatlock doesn't prevent smoking
			fst:herb ()
		end
		if
			bals:get ("elixir") == 0.5 and
			not string.find ((flags:get ("applying") or "nil"), "apply_health_to_")
				then --I still can apply healing
			fst:elixir ()
		end --if
		affs:add_simple ("throatlock")
	end --if
	
end --function


function affs:anorexia ()
	
	if not affs:has ("anorexia") then
		if
			bals:get ("herb") == 0.5 and
			not flags:get ("smoking") and
			not string.find ((flags:get ("applying") or "nil"), "apply_arnica_to_")
				then --anorexia doesn't prevent smoking
			fst:herb ()
		end
		if
			bals:get ("elixir") == 0.5 and
			not string.find ((flags:get ("applying") or "nil"), "apply_health_to_")
				then --I still can apply healing
			fst:elixir ()
		end --if
		affs:add_simple ("anorexia")
	end --if
	
end --function


function affs:rubies (absolute, number)
	
	if absolute then
		affs:add_simple ("rubies", number)
	elseif not absolute then
		if number then
			affs:add_simple ("rubies", (affs:has ("rubies") or 0)+number)
		else
			affs:add_simple ("rubies", (affs:has ("rubies") or 0)+1)
		end--if
	end--if
	
	if affs:has ("rubies") <= 0 then
		affs:del ("rubies")
	elseif affs:has ("rubies") < 3 then
		prompt:del_alert ("rubies")
	else
		prompt:add_alert ("rubies", "Ruby "..affs:has ("rubies"), 20)
	end--if
	
end --rubies


function affs:unwield (name, fixed) --line will be the full name

	local id
	if next (offense.current) then
		for i, n in pairs (offense.current) do
			if n == name then
				id = i
				break
			end--if
		end--for
	else
		return display.warning ("No wielded items detected")
	end--if
	
	if fixed and not next (self ["unwielded"]) then
		affs:del ("unwield")
		return display.error ("There Were No Unwielded Items Detected")
	end--if
	
	if fixed then
		for k, i in ipairs (self.unwielded) do
			if i == id then
				table.remove (self.unwielded, k)
				break
			end--if
		end--for
		fst:disable ("unwield")
		affs:del ("unwield")
		display.cured ("unwield")
		if next (self ["unwielded"]) then
			affs:add_simple ("unwield")
		end--if
	else
			--if I haven't already unwielded the item
		if next (self ["unwielded"]) then
			for k, i in ipairs (self ["unwielded"]) do
				if i==id then
					affs:add_simple ("unwield")
					return
				end--if
			end--for
		end--if
		
		if string.find (id, "shield") then
			table.insert (self ["unwielded"], 1, id)--shield first
		else
			table.insert (self ["unwielded"], id)
		end--if
		
		affs:add_simple ("unwield")
	end--if
	
end--function
	


function affs:is_prone ()

	if 
		affs:has ("prone") or
		affs:has ("entangled") or
		affs:has ("paralysis") or
		affs:has ("stun") or
		affs:has ("frozen") or
		affs:has ("roped") or
		affs:has ("impaled") or 
		affs:has ("crucified") or
		affs:has ("shackled")
			then
		return true
	end

	return false
	
end --is_prone


function affs:condition (limb)

	limb = string.gsub (limb, " ", "")
	if 	affs:has ("broken_"..limb) or
		affs:has ("mangled_"..limb) or
		affs:has ("amputated_"..limb) or
		affs:has ("clamped_"..limb)
			then
		return "unhealthy"
	end--if
	
	if string.find (limb, "arm") and
		affs:has ("hemiplegy_upper")
			then
		return "unhealthy"
	end--if
	
	if string.find (limb, "leg") and
		affs:has ("hemiplegy_lower")
			then
		return "unhealthy"
	end--if
	
	if string.find (limb, "right") and
		affs:has ("hemiplegy_right")
			then
		return "unhealthy"
	end--if
	
	if string.find (limb, "left") and
		affs:has ("hemiplegy_left")
			then
		return "unhealthy"
	end--if
	
	return "healthy"
	
end --condition


--[[
	
	LIST OF POSSIBLE AFFLICTIONS AND THEIR CURES
	
]]--


--[[SALVE AFFLICTIONS]]--

affs ["salve"] = { --CHANGED MOST OF THE NAMES TO ADD THE BODYPART TOO, NOT ONLY THE SIDE
	"slitthroat",
	"burstorgans",
	"disemboweled",
	"concussion",
	"asthma",
	"burns_4", ---THIS IS NEW!!!!
	"crushedchest",
	"shortbreath",
	"severedspine",
	"amputated_leftleg",
	"amputated_rightleg",
	"fracturedskull",
	"collapsedlungs",
	"tendon_leftleg",
	"tendon_rightleg",
	"burns_3",--THIS IS NEW!!!
	"mangled_leftleg", 
	"mangled_rightleg",
	"shatteredankle_leftleg",
	"shatteredankle_rightleg",
	"amputated_leftarm",
	"amputated_rightarm",
	"broken_leftleg",
	"broken_rightleg",
	"sunallergy_2",
	"burns_2", --THIS IS NEW!!!!
	"chestpain",
	"kneecap_leftleg",
	"kneecap_rightleg",
	"collapsednerve_rightarm",--THIS IS NEW
	"collapsednerve_leftarm",--THIS IS NEW
	"twisted_leftleg",--THIS IS NEW
	"twisted_rightleg",--THIS IS NEW
	"brokenwrist_leftarm",
	"brokenwrist_rightarm",
	"mangled_rightarm",
	"mangled_leftarm",
	"elbow_leftarm",----NAME CHANGE FROM elbow_leftarm!!!!
	"elbow_rightarm",----NAME CHANGE FROM elbow_rightarm!!!
	"broken_rightarm",
	"broken_leftarm",
	"damagedhead",
	"vapors",
	"twisted_rightarm",--THIS IS NEW
	"twisted_leftarm",--THIS IS NEW
	"puncturedlung",
	"rupturedstomach",
	"blacklung",
	"sunallergy_1",
	"burns_1", --THIS IS NEW
	"trembling",
	"shatteredjaw",
	"brokenjaw",
	"scabies",
	"pox",
	"dizziness",
	"peckedeye_left",
	"peckedeye_right",
	}

--[[SALVE CURES]]--
	
affs ["cures"] ["salve"] = {
	["burns_4"] = "apply liniment", ---THIS IS NEW!!!!
	["burns_3"] = "apply liniment", ---THIS IS NEW!!!!
	["burns_2"] = "apply liniment", ---THIS IS NEW!!!!
	["burns_1"] = "apply liniment", ---THIS IS NEW!!!!
	["collapsednerve_rightarm"] = "apply regeneration to arms",--THIS IS NEW
	["collapsednerve_leftarm"] = "apply regeneration to arms",--THIS IS NEW
	["twisted_leftleg"] = "apply mending to legs",--THIS IS NEW
	["twisted_rightleg"] = "apply mending to legs",--THIS IS NEW
	["twisted_rightarm"] = "apply mending to arms",--THIS IS NEW
	["twisted_rightarm"] = "apply mending to arms",--THIS IS NEW
	["asthma"] = "apply melancholic to chest",
	["trembling"] = "apply melancholic to chest",
	["concussion"] = "apply regeneration to head",
	["slitthroat"] = "apply mending to head",
	["burstorgans"] = "apply regeneration to gut",
	["disemboweled"] = "apply regeneration to gut",
	["crushedchest"] = "apply regeneration to chest",
	["shortbreath"] = "apply melancholic to chest",
	["amputated_leftleg"] = "apply regeneration to legs",
	["amputated_rightleg"] = "apply regeneration to legs",
	["collapsedlungs"] = "apply regeneration to chest",
	["mangled_leftleg"] = "apply regeneration to legs",
	["mangled_rightleg"] = "apply regeneration to legs",
	["amputated_leftarm"] = "apply regeneration to arms",
	["amputated_rightarm"] = "apply regeneration to arms",
	["tendon_leftleg"] = "apply regeneration to legs",
	["tendon_rightleg"] = "apply regeneration to legs",
	["chestpain"] = "apply regeneration to chest",
	["damagedhead"] = "apply regeneration to head",
	["fracturedskull"] = "apply mending to head",
	["severedspine"] = "apply regeneration to gut",
	["kneecap_leftleg"] = "apply regeneration to legs",
	["kneecap_rightleg"] = "apply regeneration to legs",
	["brokenwrist_leftarm"] = "apply mending to arms",
	["brokenwrist_rightarm"] = "apply mending to arms",
	["broken_leftleg"] = "apply mending to legs",
	["broken_rightleg"] = "apply mending to legs",
	["puncturedlung"] = "apply melancholic to chest",
	["rupturedstomach"] = "apply regeneration to gut",
	["vapors"] = "apply melancholic to head",
	["blacklung"] = "apply melancholic to chest",
	["shatteredjaw"] = "apply regeneration to head",
	["brokenjaw"] = "apply mending to head",
	["mangled_rightarm"] = "apply regeneration to arms",
	["mangled_leftarm"] = "apply regeneration to arms",
	["broken_rightarm"] = "apply mending to arms",
	["broken_leftarm"] = "apply mending to arms",
	["sunallergy_1"] = "apply liniment",
	["sunallergy_2"] = "apply liniment",
	["scabies"] = "apply liniment",
	["pox"] = "apply liniment",
	["dizziness"] = "apply melancholic to head",
	["elbow_leftarm"] = "apply regeneration to arms",
	["elbow_rightarm"] = "apply regeneration to arms",
	["peckedeye_left"] = "apply regeneration to head",
	["peckedeye_right"] = "apply regeneration to head",
	["shatteredankle_leftleg"] = "apply regeneration to legs",
	["shatteredankle_rightleg"] = "apply regeneration to legs",
	}


--[[ELIXIR AFFLICTIONS]]--

affs ["elixir"] = {--aeon is a very special case; I have a prompt just for it.
	"crotamine_4",
	"no_speed",
	"health_critical",
	"vessels_critical",
	"wounds_head_critical",
	"wounds_leftleg_critical",
	"wounds_rightleg_critical",
	"ego_critical",
	"mana_critical",
	"wounds_chest_critical",
	"wounds_gut_critical",
	"blackout",
	"dysentery",
	"hypersomnia",
	"wounds_leftarm_critical",
	"wounds_rightarm_critical",
	"powersink",
	"wounds_head_extra_heavy",
	"wounds_leftleg_extra_heavy",
	"wounds_rightleg_extra_heavy",
	"wounds_chest_extra_heavy",
	"wounds_gut_extra_heavy",
	"wounds_leftarm_extra_heavy",
	"wounds_rightarm_extra_heavy",
	"scalped",
	"crotamine_3",
	"shatteredankle_leftleg",
	"shatteredankle_rightleg",
	"frozen",
	"healthleech",
	"health_low",
	"vessels_low",
	"wounds_head_heavy",
	"wounds_leftleg_heavy",
	"wounds_rightleg_heavy",
	"wounds_chest_heavy",
	"wounds_gut_heavy",
	"wounds_leftarm_heavy",
	"wounds_rightarm_heavy",
	"hemophilia",
	"confusion",
	"chestpain",
	"powersap", --THIS IS NEW!!!
	"vomitingblood",
	"crotamine_2",
	"mana_low",
	"ego_low",
	"chills",
	"elbow_leftarm",
	"elbow_rightarm",
	"furrowedbrow",
	"love",
	"shyness",
	"generosity",
	"lethargy",
	"worms",
	"health_med",
	"vessels_med",
	"wounds_head_med",
	"wounds_leftleg_med",
	"wounds_rightleg_med",
	"wounds_chest_med",
	"wounds_gut_med",
	"wounds_leftarm_med",
	"wounds_rightarm_med",
	"mana_med",
	"ego_med",
	"numb_leftleg",
	"numb_rightleg",
	"numb_head",
	"numb_leftarm",
	"numb_rightarm",
	"numb_chest",
	"numb_gut",
	"no_love",
	"crotamine_1",
	"vomiting",
	"no_moonwater",
	"wounds_head_light",
	"wounds_leftleg_light",
	"wounds_rightleg_light",
	"wounds_chest_light",
	"wounds_gut_light",
	"wounds_leftarm_light",
	"wounds_rightarm_light",
	"weakness",
	"ablaze",
	"disloyalty", --repugnance in Iasmos'
	"no_fire",
	"no_frost",
	"no_galvanism",
	"wounds_head_negligible",
	"wounds_leftleg_negligible",
	"wounds_rightleg_negligible",
	"wounds_chest_negligible",
	"wounds_gut_negligible",
	"wounds_leftarm_negligible",
	"wounds_rightarm_negligible",
	}
	
--[[ELXIR CURES]]--	

affs ["cures"] ["elixir"] = {
	["elbow_leftarm"] = "drink allheale",
	["elbow_rightarm"] = "drink allheale",
	["shatteredankle_leftleg"] = "drink allheale",
	["shatteredankle_rightleg"] = "drink allheale",
	["chestpain"] = "drink allheale",
	["aeon"] = "drink allheale",
	["blackout"] = "drink allheale",
	["vessels_critical"] = "drink health",
	["vessels_low"] = "drink health",
	["vessels_med"] = "drink health",
	["numb_gut"] = "apply health to gut",
	["numb_chest"] = "apply health to chest",
	["numb_head"] = "apply health to head",
	["numb_leftleg"] = "apply health to legs",
	["numb_rightleg"] = "apply health to legs",
	["numb_leftarm"] = "apply health to arms",
	["numb_rightarm"] = "apply health to arms",
	["aeon"] = "drink phlegmatic",
	["no_speed"] = "drink quicksilver",
	["crotamine_1"] = "drink antidote",
	["crotamine_2"] = "drink antidote",
	["crotamine_3"] = "drink antidote",
	["crotamine_4"] = "drink antidote",
	["powersap"] = "drink antidote",
	["love"] = "drink choleric",
	["frozen"] = "drink fire",
	["scalped"] = "drink sanguine",
	["dysentery"] = "drink choleric",
	["healthleech"] = "drink sanguine",
	["hypersomnia"] = "drink choleric",
	["health_med"] = "drink health",
	["health_low"] = "drink health",
	["health_critical"] = "drink health",
	["mana_med"] = "drink mana",
	["mana_low"] = "drink mana",
	["mana_critical"] = "drink mana",
	["ego_med"] = "drink bromide",
	["ego_low"] = "drink bromide",
	["ego_critical"] = "drink bromide",
	["no_love"] = "drink love",
	["powersink"] = "drink phlegmatic",
	["vomitingblood"] = "drink choleric",
	["confusion"] = "drink sanguine",
	["ablaze"] = "drink frost",
	["hemophilia"] = "drink sanguine",
	["lethargy"] = "drink sanguine",
	["chills"] = "drink fire",
	["furrowedbrow"] = "drink sanguine",
	["shyness"] = "drink phlegmatic",
	["vomiting"] = "drink choleric",
	["weakness"] = "drink phlegmatic",
	["worms"] = "drink choleric",
	["disloyalty"] = "drink love",
	["no_fire"] = "drink fire",
	["no_frost"] = "drink frost",
	["no_galvanism"] = "drink galvanism",
	["powersap"] = "drink antidote",
	["no_moonwater"] = "drink moonwater",
	["wounds_head_negligible"] = "apply health to head",
	["wounds_leftleg_negligible"] = "apply health to legs",
	["wounds_rightleg_negligible"] = "apply health to legs",
	["wounds_chest_negligible"] = "apply health to chest",
	["wounds_gut_negligible"] = "apply health to gut",
	["wounds_leftarm_negligible"] = "apply health to arms",
	["wounds_rightarm_negligible"] = "apply health to arms",
	["wounds_head_light"] = "apply health to head",
	["wounds_leftleg_light"] = "apply health to legs",
	["wounds_rightleg_light"] = "apply health to legs",
	["wounds_chest_light"] = "apply health to chest",
	["wounds_gut_light"] = "apply health to gut",
	["wounds_leftarm_light"] = "apply health to arms",
	["wounds_rightarm_light"] = "apply health to arms",
	["wounds_head_med"] = "apply health to head",
	["wounds_leftleg_med"] = "apply health to legs",
	["wounds_rightleg_med"] = "apply health to legs",
	["wounds_chest_med"] = "apply health to chest",
	["wounds_gut_med"] = "apply health to gut",
	["wounds_leftarm_med"] = "apply health to arms",
	["wounds_rightarm_med"] = "apply health to arms",
	["wounds_head_heavy"] = "apply health to head",
	["wounds_leftleg_heavy"] = "apply health to legs",
	["wounds_rightleg_heavy"] = "apply health to legs",
	["wounds_chest_heavy"] = "apply health to chest",
	["wounds_gut_heavy"] = "apply health to gut",
	["wounds_leftarm_heavy"] = "apply health to arms",
	["wounds_rightarm_heavy"] = "apply health to arms",
	["wounds_head_extra_heavy"] = "apply health to head",
	["wounds_leftleg_extra_heavy"] = "apply health to legs",
	["wounds_rightleg_extra_heavy"] = "apply health to legs",
	["wounds_chest_extra_heavy"] = "apply health to chest",
	["wounds_gut_extra_heavy"] = "apply health to gut",
	["wounds_leftarm_extra_heavy"] = "apply health to arms",
	["wounds_rightarm_extra_heavy"] = "apply health to arms",
	["wounds_head_critical"] = "apply health to head",
	["wounds_leftleg_critical"] = "apply health to legs",
	["wounds_rightleg_critical"] = "apply health to legs",
	["wounds_chest_critical"] = "apply health to chest",
	["wounds_gut_critical"] = "apply health to gut",
	["wounds_leftarm_critical"] = "apply health to arms",
	["wounds_rightarm_critical"] = "apply health to arms",
	}
	
--[[HERB AFFLICTIONS]]--
	
affs ["herb"] = {
	"stupidity",
	"concussion",
	"anorexia",
	"void", --THIS IS NEW!!!!!!
	"windpipe",
	"slickness",
	"no_sixthsense",
	"blindness",
	"recklessness",
	"impatience",
	"jinx",
	"hypochondria",
	"clot_4",
	"bleeding_5",
	"artery_5",
	"vapors",
	"clot_3",
	"bedeviled",--THIS IS NEW!!!
	"slicedopengut",
	"narcolepsy",
	"lightheaded",
	"stiff_head",--THIS IS NEW!!!!
	"no_kafe",
	"no_insomnia",--THIS IS NEW!!!!
	"insanity_massive",
	"timewarp_massive",
	"coils_8",
	"clot_2",
	"bleeding_4",
	"lacerated_4",
	"artery_4",
	"scrambledbrain",
	"hemiplegy_left",
	"hemiplegy_lower",
	"hemiplegy_right",
	"hemiplegy_upper",
	"clot_1",
	"phrenicnerve",
	"stiff_rightarm",
	"stiff_leftarm",
	"sliced_leftarm",
	"sliced_rightarm",
	"severedear_left",
	"severedear_right",
	"slicedchest",
	"omniphobia",
	"gashedcheek",
	"shyness",
	"bleeding_3",
	"lacerated_3",
	"artery_3",
	"stiff_gut",
	"stiff_chest",
	"insanity_major",
	"timewarped_major",
	"sliced_leftleg",
	"sliced_rightleg",
	"succumb",
	"no_rebound",
	"daydreaming",
	"pierced_leftarm",
	"pierced_leftleg",
	"pierced_rightarm",
	"pierced_rightleg",
	"confusion",
	"masochism",
	"slicedopenforehead",
	"coils_7",
	"lacerated_2",
	"artery_2",
	"pacifism",
	"peace",
	"insanity_moderate",
	"timewarped_moderate",
	"lovers",
	"bleeding_2",
	"lacerated_1",
	"artery_1",
	"deadened",
	"no_truehearing",
	"deafness",
	"coils_6",
	"insanity_slight",
	"timewarped_slight",
	"dislocated_leftarm",
	"dislocated_leftleg",
	"dislocated_rightarm",
	"dislocated_rightleg",
	"fractured_leftarm",
	"fractured_rightarm",
	"vestiphobia",
	"dementia",
	"dissonance",
	"dizziness",
	"snappedrib",
	"loneliness",
	"crushedfoot_leftleg", ---NAME CHANGE FROM crushedfoot_left!!!!
	"crushedfoot_rightleg",---NAME CHANGE FROM crushedfoot_right!!!!
	"coils_5",
	"epilepsy",
	"sensitivity",
	"generosity",
	"gluttony",
	"hallucinations",
	"healthleech",
	"hemophilia",
	"coils_4",
	"bleeding_1",
	"daydreaming",
	"claustrophobia",
	"agoraphobia",
	"justice",
	"lethargy",
	"manabarbs",
	"powerspikes",
	"egovice",
	"achromaticaura",
	"coils_3",
	"paranoia",
	"powersink",
	"addiction",
	"puncturedchest",
	"brokenchest",
	"coils_2",
	"relapsing",
	"rigormortis",
	"vertigo",
	"coils_1",
	"brokennose",
	"puncturedaura",
	"depression",
	"mangledtongue",
	"insomnia",
	"clumsiness",
	}
	
--[[HERB CURES]]--

affs ["cures"] ["herb"] = {
	["coils_8"] = "smoke faeleaf",
	["coils_7"] = "smoke faeleaf",
	["coils_6"] = "smoke faeleaf",
	["coils_5"] = "smoke faeleaf",
	["coils_4"] = "smoke faeleaf",
	["coils_3"] = "smoke faeleaf",
	["coils_2"] = "smoke faeleaf",
	["coils_1"] = "smoke faeleaf",
	["concussion"] = "eat myrtle",
	["insanity_massive"] = "eat pennyroyal",
	["insanity_major"] = "eat pennyroyal",
	["insanity_moderate"] = "eat pennyroyal",
	["insanity_slight"] = "eat pennyroyal",
	["timewarped_massive"] = "eat horehound",
	["timewarped_major"] = "eat horehound",
	["timewarped_moderate"] = "eat horehound",
	["timewarped_slight"] = "eat horehound",
	["no_insomnia"] = "eat merbloom",
	["no_rebound"] = "smoke faeleaf",
	["clot_4"] = "eat yarrow",
	["clot_3"] = "eat yarrow",
	["clot_2"] = "eat yarrow",
	["clot_1"] = "eat yarrow",
	["insomnia"] = "smoke coltsfoot",
	["blindness"] = "eat myrtle",
	["stupidity"] = "eat pennyroyal",
	["pacifism"] = "eat reishi",
	["void"] = "eat pennyroyal", --THIS IS NEW!!!!!!
	["jinx"] = "eat reishi", --THIS IS NEW!!!!
	["bedeviled"] = "eat horehound",--THIS IS NEW!!!
	["stiff_head"] = "eat marjoram",--THIS IS NEW!!!!
	["stiff_chest"] = "eat marjoram",
	["stiff_gut"] = "eat marjoram",
	["stiff_leftarm"] = "eat marjoram",
	["stiff_rightarm"] = "eat marjoram",
	["stiff_leftleg"] = "eat marjoram",
	["stiff_rightleg"] = "eat marjoram",
	["hypochondria"] = "eat wormwood",
	["slicedopengut"] = "eat marjoram",
	["narcolepsy"] = "eat kafe",
	["vapors"] = "eat kombu",
	["clot"] = "eat yarrow",
	["anorexia"] = "smoke coltsfoot",
	["no_sixthsense"] = "eat faeleaf",
	["lightheaded"] = "eat reishi",
	["bleeding_5"] = "eat chervil",
	["no_kafe"] = "eat kafe",
	["scrambledbrain"] = "eat pennyroyal",
	["windpipe"] = "smoke myrtle", --useless, I treat windpipe in an if statement
	["windpipe"] = "apply arnica to head",
	["impatience"] = "smoke coltsfoot",
	["hemiplegy_left"] = "smoke myrtle",
	["hemiplegy_lower"] = "smoke myrtle",
	["hemiplegy_right"] = "smoke myrtle",
	["phrenicnerve"] = "smoke myrtle",
	["bleeding_4"] = "eat chervil",
	["severedear_left"] = "eat marjoram",
	["severedear_right"] = "eat marjoram",
	["slicedchest"] = "eat marjoram",
	["omniphobia"] = "eat kombu",
	["gashedcheek"] = "eat marjoram",
	["addiction"] = "eat galingale",
	["depression"] = "eat galingale",
	["shyness"] = "smoke coltsfoot",
	["bleeding_3"] = "eat chervil",
	["sliced_leftarm"] = "eat marjoram",
	["sliced_rightarm"] = "eat marjoram",
	["sliced_leftleg"] = "eat marjoram",
	["sliced_rightleg"] = "eat marjoram",
	["succumb"] = "eat reishi",
	["clumsiness"] = "eat kombu",
	["pierced_leftarm"] = "smoke myrtle",
	["pierced_leftleg"] = "smoke myrtle",
	["pierced_rightarm"] = "smoke myrtle",
	["pierced_rightleg"] = "smoke myrtle",
	["confusion"] = "eat pennyroyal",
	["masochism"] = "smoke coltsfoot",
	["slicedopenforehead"] = "eat yarrow",
	["lacerated_1"] = "eat yarrow",
	["lacerated_2"] = "eat yarrow",
	["lacerated_3"] = "eat yarrow",
	["lacerated_4"] = "eat yarrow",
	["artery_1"] = "eat yarrow",
	["artery_2"] = "eat yarrow",
	["artery_3"] = "eat yarrow",
	["artery_4"] = "eat yarrow",
	["bleeding_2"] = "eat chervil",
	["deadened"] = "eat kombu",
	["deafness"] = "eat myrtle",
	["no_truehearing"] = "eat earwort",
	["dislocated_leftarm"] = "eat marjoram",
	["dislocated_leftleg"] = "eat marjoram",
	["dislocated_rightarm"] = "eat marjoram",
	["dislocated_rightleg"] = "eat marjoram",
	["dementia"] = "eat pennyroyal",
	["dissonance"] = "eat horehound",
	["dizziness"] = "eat kombu",
	["loneliness"] = "smoke coltsfoot",
	["epilepsy"] = "eat kombu",
	["generosity"] = "eat galingale",
	["gluttony"] = "eat galingale",
	["hallucinations"] = "eat pennyroyal",
	["healthleech"] = "eat horehound",
	["hemophilia"] = "eat yarrow",
	["bleeding_1"] = "eat chervil",
	["daydreaming"] = "eat kafe",
	["claustrophobia"] = "eat wormwood",
	["agoraphobia"] = "eat wormwood",
	["justice"] = "eat reishi",
	["lethargy"] = "eat yarrow",
	["lovers"] = "eat galingale",
	["manabarbs"] = "eat horehound",
	["powerspikes"] = "eat horehound",
	["egovice"] = "eat horehound",
	["achromaticaura"] = "eat horehound",
	["paranoia"] = "eat pennyroyal",
	["peace"] = "eat reishi",
	["powersink"] = "eat reishi",
	["puncturedchest"] = "eat marjoram",
	["recklessness"] = "eat horehound",
	["snappedrib"] ="apply arnica to chest",
	["brokenchest"] = "apply arnica to chest",
	["relapsing"] = "eat yarrow",
	["rigormortis"] = "eat marjoram",
	["sensitivity"] = "eat myrtle",
	["slickness"] = "eat calamus",
	["vertigo"] = "eat myrtle",
	["vestiphobia"] = "eat wormwood",
	["brokennose"] = "apply arnica to head",
	["puncturedaura"] = "eat reishi",
	["fractured_leftarm"] = "apply arnica to arms",
	["fractured_rightarm"] = "apply arnica to arms",
	["crushedfoot_leftleg"] = "apply arnica to legs",
	["crushedfoot_rightleg"] = "apply arnica to legs",
	["mangledtongue"] = "eat marjoram",
	}
	
--[[WRITHE AFFLICTIONS]]--

affs ["writhe"] = {
	"lashed_leftarm",
	"lashed_rightarm",
	"lashed_leftleg",
	"lashed_rightleg",
	"trussed",
	"grappled",
	"shackled",
	"entangled",
	"clamped_leftarm", ---big question mark, need to know the exact lines, add_clamped is broken too
	"clamped_rightarm",
	"transfixed",
	"roped",
	"hoisted",
	}
	
--[[WRITHE CURES]]--
	 ---VERY IMPORTANT, I NEED THE WRITHE AFFLICTIONS HERE TO CURE PROPERLY
affs ["cures"] ["writhe"] = { --clamp will also be in the cures list, not writhe clamp
	["clamped_leftarm"] = "writhe clamp",
	["clamped_rightarm"] = "writhe clamp",
	["trussed"] = "writhe truss", --cured by summer
	["entangled"] = "writhe entangle", --cured by summer
	["grappled"] = "writhe grapple",
	["hoisted"] = "writhe hoist",
	["roped"] = "writhe ropes", --cured by summer
	["shackled"] = "writhe shackles", --cured by summer
	["lashed_leftarm"] = "writhe vines",--NOT CURED BY SUMMER
	["lashed_leftleg"] = "writhe vines",
	["lashed_rightarm"] = "writhe vines",
	["lashed_rightleg"] = "writhe vines",
	["transfixed"] = "writhe transfix",
	["impaled"] = "writhe",
	["pinleg"] = "writhe",
	["crucified"] = "writhe",
	}

--[[FOCUS AFFLICTIONS]]--
	
affs ["focus"] = { --IASMOS HAS SOME COMMENTED, MAYBE THERE AREN'T SO IMPORTANT
	"impatience",
	"stupidity",
	"anorexia",
	"paralysis",
	"throatlock",
	"leglock",
	"recklessness",
	"insanity_massive",
	"insanity_major",
	"timewarped_massive",
	"timewarped_major",
	"confusion",
	"pacifism",
	"epilepsy",
	"insanity_moderate",
	"timewarped_moderate",
	"addiction",
	"weakness",
	--"vertigo",
	--"dizziness",
	--"masochism",
	"sickness",
	--"loneliness",
	--"claustrophobia",
	--"agoraphobia",
	--"paranoia",
	"shyness",
	"hallucinations",
	"taintsick",--NEW!!!!!!
	"darkmoon",
	"health_curse",
	"mana_curse",
	"ego_curse",
	"insanity_slight",
	"insanity_moderate",
	"treebane",
	"omen",
	"void",
	"puncturedaura",
	"illuminated",
	"binah_sphere",
	}
	
--[[FOCUS CURES]]--
	
affs ["cures"] ["focus"] = {
	["addiction"] = "focus mind",
	["anorexia"] = "focus mind",
	["agoraphobia"] = "focus mind",
	["binah_sphere"] = "focus spirit",
	["claustrophobia"] = "focus mind",
	["confusion"] = "focus mind",
	["darkmoon"] = "focus spirit",
	["dissonance"] = "focus mind",
	["dizziness"] = "focus mind",
	["ego_curse"] = "focus spirit",
	["egovice"] = "focus spirit",
	["epilepsy"] = "focus mind",
	["generosity"] = "focus mind",
	["health_curse"] = "focus spirit",
	["illuminated"] = "focus spirit",
	["impatience"] = "focus mind",
	["leglock"] = "focus body",
	["lightheaded"] = "focus spirit",
	["lovers"] = "focus mind",
	["hallucinations"] = "focus mind",
	["manabarbs"] = "focus spirit",
	["throatlock"] = "focus body",
	["loneliness"] = "focus mind",
	["mana_curse"] = "focus spirit",
	["masochism"] = "focus mind",
	["omen"] = "focus spirit",
	["pacifism"] = "focus mind",
	["paralysis"] = "focus body",
	["paranoia"] = "focus mind",
	["powerspikes"] = "focus spirit",
	["recklessness"] = "focus mind",
	["shyness"] = "focus mind",
	["stupidity"] = "focus mind",
	["sickness"] = "focus spirit",
	["treebane"] = "focus spirit",
	["vertigo"] = "focus mind",
	["vestiphobia"] = "focus mind",
	["void"] = "focus mind",
	["weakness"] = "focus mind", 
	}
	
--[[AFFLICTIONS CURED BY ALLHEALE]]--

affs ["ah"] = {
			"ablaze", "narcolepsy", "addiction", "aeon", "agoraphobia", "shatteredankle_leftleg", "shatteredankle_rightleg", "anorexia", "slicedopenforehead",
				"asthma", "aurawarp", "bedeviled", "sliced_leftarm", "sliced_rightarm", "blacklung", "brokenjaw", "brokennose",
				"brokenchest", "brokenwrist_leftarm", "brokenwrist_rightarm", "chestpain", "claustrophobia", "clumsiness",
				"confusion", "crotamine", "windpipe", "daydreaming", "deadened", "dementia", "dislocated_leftarm",
				"dislocated_leftleg", "dislocated_rightarm", "dislocated_rightleg", "dissonance", "dizziness", "dysentery",
				"enfeebled", "epilepsy", "fear", "fractured_leftarm", "fractured_rightarm", "fracturedskull", "frozen",
				"gashedcheek", "gluttony", "generosity", "hallucinations", "healthleech", "hemiplegy_left", "hemiplegy_lower",
				"hemiplegy_right", "hemophilia", "hypersomnia", "hypochondria", "impatience", "jinx", "justice",
				"lacerated_1", "lacerated_2", "lacerated_3", "lacerated_4", "leglock", "artery_1", "artery_2", "artery_3", "artery_4", "artery_5",
				"lethargy", "lightheaded", "severedear_left", "severedear_right", "love", "lovers", "masochism", "narcolepsy",
				"collapsednerve_leftarm", "collapsednerve_rightarm", "numb_chest", "numb_gut", "numb_head", "numb_leftarm", "numb_leftleg",
				"numb_rightarm", "numb_rightleg", "omniphobia", "pacifism", "paralysis", "paranoia", "peace", "pierced_leftarm",
				"pierced_leftleg", "pierced_rightarm", "pierced_rightleg", "powersap", "powersink", "pox", "puncturedchest",
				"puncturedlung", "recklessness", "relapsing", "rigormortis", "scabies", "scalped", "scrambled", "sensitivity",
				"shatteredjaw", "shortbreath", "shyness", "slicedchest", "slicedopengut", "slickness", "slitthroat",
				"stupidity", "sunallergy", "sliced_leftleg", "sliced_rightleg", "throat_locked", "twisted_leftarm", "twisted_leftleg", 
				"twisted_rightarm", "twisted_rightleg", "unconscious", "vapors", "vertigo", "vestiphobia", "void",
				"vomiting", "vomitingblood", "weakness", "worms", "broken_leftleg", "broken_rightleg",
			"broken_leftarm", "broken_rightarm", "blackout",
		}
	
--[[BALANCES FOR CURES]]--

affs ["balances"] = { --maybe add tea and moonwater here?
	["drink_health"] = "elixir",
	["drink_mana"] = "elixir",
	["drink_bromide"] = "elixir",
	["focus_body"] = "focus",
	["focus_spirit"] = "focus",
	["focus_mind"] = "focus",
	["eat_arnica"] = "herb",
	["eat_merbloom"] = "herb",
	["apply_arnica_to_arms"] = "herb",
	["apply_arnica_to_head"] = "herb",
	["apply_arnica_to_chest"] = "herb",
	["apply_arnica_to_legs"] = "herb",
	["eat_calamus"] = "herb",
	["eat_chervil"] = "herb",
	["eat_faeleaf"] = "herb",
	["eat_galingale"] = "herb",
	["eat_horehound"] = "herb",
	["eat_kafe"] = "herb",
	["eat_kombu"] =	"herb",
	["eat_marjoram"] = "herb",
	["eat_myrtle"] = "herb",
	["eat_pennyroyal"] = "herb",
	["eat_reishi"] = "herb",
	["eat_sparkleberry"] = "sparklies",
	["eat_wormwood"] = "herb",
	["eat_yarrow"] = "herb",
	["eat_earwort"] = "herb",
	["eat_faeleaf"] = "herb",
	["drink_antidote"] = "purg",
	["drink_choleric"] = "purg",
	["drink_love"] = "purg",
	["drink_fire"] = "purg",
	["drink_frost"] = "purg",
	["drink_phlegmatic"] = "purg",
	["drink_sanguine"] =  "purg",
	["drink_galvanism"] = "purg",
	["drink_quicksilver"] = "speed",
	["apply_melancholic_to_head"]= "salve",
	["apply_melancholic_to_chest"] = "salve",
	["apply_liniment"] = "salve",
	["apply_mending_to_arms"] = "salve",
	["apply_mending_to_head"] = "salve",
	["apply_mending_to_legs"] = "salve",
	["apply_regeneration_to_arms"] = "salve",
	["apply_regeneration_to_chest"] = "salve",
	["apply_regeneration_to_gut"] = "salve",
	["apply_regeneration_to_legs"] = "salve",
	["apply_regeneration_to_head"] = "salve",
	["apply_health_to_head"] = "elixir",
	["apply_health_to_chest"] = "elixir",
	["apply_health_to_gut"] = "elixir",
	["apply_health_to_arms"] = "elixir",
	["apply_health_to_legs"] = "elixir",
	["smoke_coltsfoot"] = "herb",
	["smoke_myrtle"] = "herb",
	["smoke_faeleaf"] = "herb",
	["drink_allheale"] = "ah",
	["drink_tea"] = "brew",
	}
	

return affs
