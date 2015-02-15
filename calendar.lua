--[[
Functions for tracking date and time of day.
--]]

if not calendar then
calendar = {
	day = 0,
	month = 0,
	year = 0,
	night = 0,
	months = {
		["Estar"] = 1,
		["Urlachmar"] = 2,
		["Kiani"] = 3,
		["Dioni"] = 4,
		["Vestian"] = 5,
		["Avechary"] = 6,
		["Dvarsh"] = 7,
		["Tzarin"] = 8,
		["Klangiary"] = 9,
		["Juliary"] = 10,
		["Shanthin"] = 11,
		["Roarkian"] = 12
    },
}
end

-- Initialize the calendar (only on connect)
function calendar:init()
	
	act:queue ("date")
	act:queue ("time")
	
end

-- Sets the current date, usable by other modules then
function calendar:date (d, m, y)
  
	if not (d) then
		display.system ("The date is:")
		ColourNote ("white", "", "	"..self ["day"].."."..self ["month"].."."..self ["year"])
	else
		self ["day"] = d
		self ["month"] = m
		self ["year"] = y
	end --if
  
end

-- Sets the time of day to night or day
function calendar:time (is_night, silent)
	
	if not silent then
		if is_night then
			display.system ("Nighttime")
		else
			display.system ("Daytime")
			skills ["available"] ["adroitness"] = {}
			skills ["available"] ["adroitness"] = nil
		end
	end--if
	self ["night"] = is_night
	
	if 	is_night and 
		(defs:has ("lich") or defs:has ("archlich")) and
		not defs:has ("adroitness") 
			then
		skills ["available"] ["adroitness"] = {
			["use"] = "defs_free",
			["syntax"] = "adroitness"}
		table.insert (defs ["free"], "adroitness")
	elseif next (defs.free) then
		local pos = system:getkey (defs.free, "adroitness")
		if pos then
			defs:queue_unqueue ("adroitness")
			defs:unqueue ("free")
		end--if		
	end--if
  
end

-- Functions to check for daytime or nighttime
function calendar:is_night()

  return self ["night"] == true
  
end

function calendar:is_day()

  return self ["night"] == false
  
end

-- How far apart are two months?
function calendar:month_diff(m1, m2)

  if not self ["months"] [m1] then
    display.warning ("Invalid month name passed to calendar:month_diff - " .. tostring(m1))
    return
  elseif not self ["months"] [m2] then
    display.warning ("Invalid month name passed to calendar:month_diff - " .. tostring(m2))
    return
  end

  local n1 = self ["months"] [m1]
  local n2 = self ["months"] [m2]

  local diff = math.abs (n1 - n2)
  if diff > 6 then
    return 12 - diff
  end

  return diff
end

return calendar
