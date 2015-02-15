--[[
		STANCING BODYPARTS BASED ON WOUNDS
		I CHOOSE THE STANCE THAT PROTECTS THE MOST BODYPARTS
		
--]]--


--require "skills"
require "flags"
require "wounds"
require "display"

if
	not stance
		then
	stance = {
		["needed"] = nil,
		["to_stance"] = nil,
		["current"] = nil,
		["available"]= {},
	}
end --if


function stance:get_available ()

	stance ["available"] = skills:get_skilltree ("combat")
	
end --function


function stance:is_needed ()
	
	if
		system:is_auto ("stance") and
		self ["needed"] and
		next (self ["available"]) and
		not self ["to_stance"] and
		able:to ("stance") and
		(wounds:get () or system:is_enabled ("default_stance")) and
		not flags:get ("stance")
			then
		return true
	end --if
	
	return false
	
end --function
	


function stance:reset (silent)

	self ["to_stance"] = nil
	self ["needed"] = nil
	self ["current"] = nil
	flags:del ("stance")
	fst:disable ("stance")
	
	if not silent then
		display.system ("Stance RESET")
	end --if
	
end --function


function stance:init ()

	self ["to_stance"] = nil
	self ["needed"] = true
	
end --function


function stance:scan ()

	if affs:has ("pit") then
		if self ["available"] ["vitals"] then
			self ["to_stance"] = "vitals"
		elseif self ["available"] ["upper"] then
			self ["to_stance"] = "upper"
		elseif self ["available"] ["head"] then
			self ["to_stance"]  = "head"
		elseif self ["available"] ["chest"] then
			self ["to_stance"] = "chest"
		elseif self ["available"] ["gut"] then
			self ["to_stance"] = "gut"
		elseif self ["available"] ["arms"] then
			self ["to_stance"] = "arms"
		end --if
	elseif wounds:get ()	then
		local wounds_total = wounds:total ()
		local wounds_has = wounds ["current"]
		local pct = {
			["lleg"] = (wounds_has ["leftleg"] or 0)*100/wounds_total,
			["rleg"] = (wounds_has ["rightleg"] or 0)*100/wounds_total,
			["gut"] = (wounds_has ["gut"] or 0) * 100/wounds_total,
			["chest"] = (wounds_has ["chest"] or 0)*100/wounds_total,
			["head"] = (wounds_has ["head"] or 0)*100/wounds_total,
			["larm"] = (wounds_has ["leftarm"] or 0)*100/wounds_total,
			["rarm"] = (wounds_has ["rightarm"] or 0)*100/wounds_total,
		}
		if pct ["lleg"] + pct ["rleg"] > 50 then
			self ["to_stance"] = "legs"
		elseif pct ["head"] > 30 and self ["available"] ["head"] then
			self ["to_stance"] = "head"
		elseif pct ["gut"] > 30 and self ["available"] ["gut"] then
			self ["to_stance"] = "gut"
		elseif pct ["chest"] > 30 and self ["available"] ["chest"] then
			self ["to_stance"] = "chest"
		elseif pct ["larm"] + pct ["rarm"] > 50 and self ["available"] ["arms"] then
			self ["to_stance"] = "arms"
		elseif pct ["gut"] + pct ["head"] + pct ["chest"] > 50 and self ["available"] ["vitals"] then
			self ["to_stance"] = "vitals"
		elseif pct ["lleg"] + pct ["larm"] > 50 and self ["available"] ["left"] then
			self ["to_stance"] = "left"
		elseif pct["rleg"] + pct["rarm"] > 50 and self ["available"] ["right"] then
			self ["to_stance"] = "right"
		elseif pct ["lleg"] + pct ["rleg"] + pct ["gut"] > 50 and self ["available"] ["lower"] then
			self ["to_stance"] = "lower"
		elseif pct ["larm"] + pct ["rarm"] + pct["gut"] + pct ["chest"] and self ["available"] ["middle"] then
			self ["to_stance"] = "middle"
		elseif pct ["chest"] + pct ["head"] + pct ["larm"] + pct ["rarm"] > 50 and self ["available"] ["upper"] then
			self ["to_stance"] = "upper"
		end
	elseif
		system:is_enabled ("default_stance") and
		self ["available"] [system ["settings"] ["default_stance"]]
			then
		self ["to_stance"] = system ["settings"] ["default_stance"]
	end --if
	
	--Note ("QUEUED STANCE: "..(self ["to_stance"] or "none"))
	
	if
		self ["to_stance"] and
		not stance:has (self ["to_stance"])
			then
		self ["current"] = nil
		stance:exec ()
	else
		stance ["needed"] = nil
		return
	end --if
	
end --function
	

function stance:exec ()

	flags:add ("stance", self ["to_stance"])
	flags:add ("bal")
	fst:enable ("stance")
	
	act:queue (self ["available"] [self ["to_stance"]])

end --function


function stance:done ()

	self:set (flags:get ("stance"))
	self ["to_stance"] = nil
	flags:del ({"stance", "bal"})
	fst:disable ("stance")
	
end --function


function stance:set (name, silent)

	self ["current"] = name
	
	if not silent then
		display.stance (name)
	end --if
		
end --function


function stance:has (name)
	
	return self ["current"] == name
	
end --function


stance:get_available ()


return stance