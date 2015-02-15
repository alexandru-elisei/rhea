--[[
	WOUNDS TRACKING
]]--

	--TO DO THE MEDBAG ABILITIES
if
	not wounds
		then
	wounds = {
		["cwpn"] = nil,
		["default_kata"] = 250,
		["current"] = {},
		["bpart_priority"] = {
			"head",
			"gut",
			"chest",
			"rightleg",
			"leftleg",
			"rightarm",
			"leftarm",
			},
		["wounds_level"] = {95, 282, 450, 1300, 2500, 3700},
		["wounds_state"] = {"negligible", "light", "med", "heavy", "extra_heavy", "critical",},
		["wounds_cured"] = {
			["health"] = 800,
			["medbag"] = 1000,
			},
		["weapons"] = {
			["rapier"] =  {
				["specialization"] = "BM",
				["wounds"] = 400,},
			["Gorshoth"] = {
				["specialization"] = "BM",
				["wounds"] = 450,},
			["Argorath"] = {
				["specialization"] = "BM",
				["wounds"] = 450,},				
			["scimitar"] = {
				["specialization"] = "BM",
				["wounds"] = 400,
			},
			["broadsword"] = {
				["specialization"] = "BM",
				["wounds"] = 300, --damage weapon, not wounding
			},
			["longsword"] = {
				["specialization"] = "BM",
				["wounds"] = 400,
			},
			["hammer"] = {
				["specialization"] = "BC",
				["wounds"] = 400,
			},
			["morningstar"] = {
				["specialization"] = "BC",
				["wounds"] = 400,
			},
			["flail"] = {
				["specialization"] = "BC",
				["wounds"] = 300, --damage weapon, not wounding
			},
			["mace"] = {
				["specialization"] = "BC",
				["wounds"] = 400,
			},
			["klangaxe"] = {
				["specialization"] = "AL",
				["wounds"] = 800,
			},
			["greataxe"] = {
				["specialization"] = "AL",
				["wounds"] = 800,
			},
			["waraxe"] = {
				["specialization"] = "AL",
				["wounds"] = 650, --damage weapon, not wounding
			},
			["battleaxe"] = {
				["specialization"] = "AL",
				["wounds"] = 800,
			},
			["katana"] = {
				["specialization"] = "PB",
				["wounds"] = 800,
			},
			["greatsword"] = {
				["specialization"] = "PB",
				["wounds"] = 800,
			},
			["claymore"] = {
				["specialization"] = "PB",
				["wounds"] = 650, --damage weapon, not wounding
			},
			["bastardsword"] = {
				["specialization"] = "PB",
				["wounds"] = 800,
			},
			["kata"] = {
				["specialization"] = "MONK",
				["wounds"] = 250,
			},
		},
		["affs"] = {
			["disemboweled"] = 6,
			["burstorgans"] = 6,
			["broken_leftarm"] = 4,
			["broken_rightarm"] = 4,
			["brokenchest"] = 2,
			["brokenjaw"] = 2,
			["broken_leftleg"] =4,
			["broken_rightleg"] = 4,
			["brokennose"] = 2,
			["concussion"] = 6,
			["fractured_leftarm"] = 3,
			["fractured_rightarm"] = 3,
			["fracturedskull"] = 3,
			["windpipe"] = 4,
			["vomitingblood"] = 4,
			["amputated_leftleg"] = 6,
			["amputated_rightleg"] = 6,
			["amputated_leftarm"] = 6,
			["amputated_rightarm"] = 6,
			["elbow_leftarm"] = 4,
			["elbow_rightarm"] = 4,
			["kneecap_leftleg"] = 4,
			["kneecap_rightleg"] = 4,
			["collpsednerve_leftarm"] = 4,
			["collpsednerve_rightarm"] = 4,
			["collapsedlungs"] = 4,
			["slitthroat"] = 4,
			["tendon_leftleg"] = 4,
			["tendon_rightleg"] = 4,
			["rupturedstomach"] = 4,
			["severedspine"] = 6,
			["shatteredjaw"] = 4,
		},
	}
	
end --if


	--ADDING WOUNDS
function wounds:nadd (sBpart, dAmnt) --dAmnt can be a negative amount

	self ["current"] [sBpart] = (self ["current"] [sBpart] or 0) + dAmnt
	if self ["current"] [sBpart] <= 0 then
		self ["current"] [sBpart] = nil
	end --if
	
end --function


	--SETTING WOUNDS TO A SPECIFIC AMOUNT, RESETTING THE WOUNDS ON A BODY PART, OR RESETTING ALL WOUNDS
function wounds:set (sBpart, dAmnt)

	if sBpart	then
		if dAmnt == 0 then
			dAmnt = nil
		end --if
		self ["current"] [sBpart] = dAmnt
	else
		self ["current"] = {} --resetting the current wounds
	end --if
	
end --function


	--RETURNS THE AMOUNT OF WOUNDS ON A SPECIFIC BODYPART
function wounds:get (part)

	if part then
		return self ["current"] [part]
	else
		return next (self ["current"]) --if I don't specify a bodypart, return true if I have any wounds
	end --if

end --function


	--RETURNS THE WOUNDING NUMBER
function wounds:total ()

	local result = 0
	
	if
		next (self ["current"])
			then
		for bpart, w in pairs (self ["current"]) do
			result = result + w
		end --for
	end --if
	
	return result
	
end --function

	
	--RESETS WOUNDS
function wounds:reset ()

	self:set ()
	self ["cwpn"] = nil
	
	display.system ("Wounds RESET")

end --function

	--DEEPWOUNDS TRACKING
function wounds:add (sBpart, nLevel, amnt)

		--formatting
	sBpart = string.gsub (sBpart, " ", "")
	wounds:hit (sBpart)
	local is_wounded
	if amnt then
		is_wounded = amnt
	else
		is_wounded = (self ["weapons"] [self ["cwpn"]] ["wounds"] or 0) * (flags:get_check ("multiply") or 1)
	end--if
	self ["current"] [sBpart] = self ["current"] [sBpart] or 0
	if
			--setting the wounds to the bodypart to those of the wounding level
		nLevel and
		type (nLevel) == "number"
			then
		if self:get (sBpart)+is_wounded < self ["wounds_level"] [nLevel] then--if my current wounds are lower than the wounds needed to reach the specified level
			self:set (sBpart, self ["wounds_level"] [nLevel])
		else
			self:nadd (sBpart, is_wounded)
		end --if
	else --if I haven't specified a wound level
		self:nadd (sBpart, is_wounded)
	end --if
	
	display.deb ("WOUNDS:ADD -> FOR "..(sBpart or "error").." ARE "..(self ["current"] [sBpart] or "error"))
	
	self:scan ("keep flag") --I need to keep the flag, I might get wounds while I am trying to cure, and if I delete the flag all my curing will go haywire
	
end --function	
	
	
	--you always cure the RIGHT LEG FIRST.
	--since that is the case, I am thinking that if you have wounds to both your legs, but your right leg ninshied, applying health will always fail
function wounds:scan (osArg)
	
		--I first check what wounds I already have in the affs queue
	if next (affs ["current"]) then
		for aff, v in pairs (affs ["current"]) do
			if string.find (aff, "wounds") then--if I create a wounds affliction, its name should contain wounds
				affs:del (aff) -- I delete this affliction, I will update it later
				break --only one wounds affliction at a time!
			end --if
		end --for
	end --if
	
		--I check for the highest wound level
	local w = -1
	for k, bpart in pairs (self ["bpart_priority"]) do --b is bodypart (string);
		if
			self:get (bpart) and
			self:get (bpart) > w
			--ninshi [bpart] == nil --ninshied bodyparts cannot be healed by applying salve
				then			
			w = self:get (bpart)
			b = bpart
		end --if
	end --for
	
	if w > 0 then
		if w <= wounds ["wounds_level"] [2] then w = "negligible"
		elseif w <= wounds ["wounds_level"] [3] then w = "light"
		elseif w <= wounds ["wounds_level"] [4] then w = "med"
		elseif w <= wounds ["wounds_level"] [5] then w = "heavy"
		elseif w <= wounds ["wounds_level"] [6] then w = "extra_heavy"
		else w = "critical"
		end--if
		
		affs:add ("wounds_"..b.."_"..w, true, "silent")
		
		display.deb ("WOUNDS:SCAN -> adding health_"..w.." = apply health to "..b)
		
	end --if --otherwise, do nothing
	
	--housekeeping
	b = nil
	
	parry:init () --each time I scan for wounds, I need to modify my parry
	stance:init () --I also check for stancing
	self ["cwpn"] = nil
	
end --function
	
	--deals with warrior attacks
function wounds:warrior_attack (weapon, dodged, line) --I REALLY, REALLY like this
	
	local stumble = string.find (line, "e stumbles forward as ")
	if
		#dodged == 0 and
		not stumble
			then
		system:poisons_on ()
		EnableTriggerGroup ("System_Wounds", true) --I need to fix this to receive tables VERY IMPORTANT
		prompt:queue (function ()EnableTriggerGroup ("System_Wounds", false) end, "warrior_attack")
			--I'll check for recklessness each time I receive health/mana/ego damage
		flags:damaged ()
			--searching for the weapon used
		local w
		if string.find (weapon, "katana") then
			w = "katana"
		elseif string.find (weapon, "kata") then
			w="kata"
		else
			for k, stats in pairs (self ["weapons"]) do
				if  string.find (weapon, k) then
					w=k
					break
				end --if
			end --for
		end--if
		if w then self.cwpn=w
		else display.error ("Unknown Weapon Detected") end
	end--if
			
end --function


function wounds:monk_attack (spec, part, amnt, wpn)--MAYBE CALL FROM HERE THE WOUNDS_ADD?!?!

	if spec then
		for k, v in ipairs (spec) do
			spec [k] = "System_"..v.."Mods"
		end--for
		table.insert (spec, "System_KataMods")
		system:cond (spec)
		prompt:queue (function () system:cond () end, "monk_attack")
	end--if
	
	if part then
		if not amnt then
			amnt = self ["default_kata"]
		end --if
	end --if
	self ["cwpn"] = (wpn or "kata")
	if amnt and amnt ~= 0 then
		wounds:add (part, nil, amnt)
		flags:damaged ()
	end	
	
end --function


function wounds:hit (part)

	if not part then
		return display.warning ("WOUNDS:HIT -> must specify a bodypart!")
	end --if
	self ["hit_loc"] = part
	
end --function


function wounds:is_hit ()

	return (self ["hit_loc"])
	
end --if

	
	--WHEN I PARTIALLY CURE WOUNDS --WTF DO I DO WITH MEDBAG?!
function wounds:cured_partially (bodypart, special)
		
		--formatting
	bodypart = string.gsub (bodypart, " ", "")
	if special then
		self:nadd (bodypart, special)
	else
		self:nadd (bodypart,  -(self ["wounds_cured"] ["health"])) --it depends on what I used to heal it
		system:del_cure ()
		bals:offbal ("elixir", "silent")
		if string.find (bodypart, "leg") then
			bodypart = "legs"
		elseif string.find (bodypart, "arm") then
			bodypart = "arms"
		end --if
		system:unqueue_cure ("apply_health_to_"..bodypart)
	end--if
	
	if
		not self:get (bodypart) or --it was a partially cured message, so I cannot have cured entirely
		self:get (bodypart) < 0
			then
		self:set (bodypart, 199)
	end --if
	
	self:scan ()
	display.cured ("Partially "..bodypart)

end --function


	--WHEN WOUNDS ARE CURED ENTIRELY --WTF DO I DO WITH MEDBAG?!
function wounds:cured (bodypart) --need to test how many wounds the medbag cures

	bodypart = string.gsub (bodypart, " ", "")	
	wounds:set (bodypart, 0)
	system:del_cure ()
	bals:offbal ("elixir", "silent")
	wounds:scan ()--affliction will be deleted here
	
	display.cured ("Wounds "..bodypart)
	
	if string.find (bodypart, "leg") then
		bodypart = "legs"
	elseif string.find (bodypart, "arm") then
		bodypart = "arms"
	end --if
	system:unqueue_cure ("apply_health_to_"..bodypart)
	
end --function


function wounds:aff (part, affliction, arg1, arg2, arg3)
	
	if self ["cwpn"] then
		affs:add_queue (affliction, arg1, arg2, arg3)
		if 
			type ("affliction") ~= "table" and
			self ["affs"] [affliction] and
			wounds:get (part)+(self ["weapons"] [self ["cwpn"]] ["wounds"] or 0)<wounds ["wounds_level"] [self ["affs"] [affliction]]
				then
			wounds:add (part, self ["affs"] [affliction])
		else
			wounds:add (part)
		end--if
	end--if

end --function

return wounds



