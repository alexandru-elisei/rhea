--[[
	BALANCE TRACKING
]]--


require "display"
--require "failsafes"

if
	not bals
		then
	bals = {
		["elixir"] = 1, --done the gn
		["speed"] = 1,
		["bal"] = 1,
		["eq"] = 1, --PROTECTION CONSUMES EQ, REQUIRE BOTH
		["herb"] = 1,--done the gn
		["salve"] = 1,--done the gn
		["purg"] = 1,--done the gn
		["focus"] = 1,--done the gn
		["ah"] = 1,--done the gn
		["sparklies"] = 1,--done the gn
		["brew"] = 1,--done the gn
		["scroll"] = 1, --scrolls
		["tail"] = 0, --for stinging
		["firing"] = {"herb", "purg", "salve"} 
		}
end --if


function bals:reset ()

	bals ["elixir"] = 1 --done the gn
	bals ["speed"] = 1
	bals ["bal"] = 1
	bals ["eq"] = 1 --PROTECTION CONSUMES EQ, REQUIRE BOTH
	bals ["herb"] = 1--done the gn
	bals ["salve"] = 1--done the gn
	bals ["purg"] = 1--done the gn
	bals ["focus"] = 1--done the gn
	bals ["ah"] = 1--done the gn
	bals ["sparklies"] = 1--done the gn
	bals ["brew"] = 1--done the gn
	bals ["scroll"] = 1 --scroll of healing.
	bals ["tail"] = 0
	
	display.system ("Balances RESET")
	
end --function


	--RETURNS THE BALANCE, NUMBER VALUE
function bals:get (sBal) --returns a number
	
	return self [sBal]
	
end --function


function bals:has (sBal)--returns boolean value
	
	if
		sBal == "bal" and
		system:is_enabled ("armbalance")
			then
		return (self ["bal"] == 1 and self ["leftarm"] == 1 and self ["rightarm"] == 1)
	else	
		if self [sBal] then
			return (self [sBal] == 1)
		else
			return true
		end --if
	end --if

end --function


	--WHEN YOU GAIN BALANCE (=1)
function bals:onbal (sBal, silent)

	fst:disable ("gn_"..sBal)
	fst:disable (sBal) --for some cures, they gain balance when they cure
	
	self [sBal] = 1
	
	if self ["firing"] [sBal] then
		fst:fire (sBal, "now", "shush")
	end--if
	
	if not silent then
		display.onbal (sBal)
	end --if
	
end --function
	
	
	--WHEN YOU LOOSE A BALANCE (=0)
function bals:offbal (sBal, silent)

	fst:disable (sBal)
	fst:enable ("gn_"..sBal)
	self [sBal] = 0
	if sBal == "bal" or sBal == "eq" then
		flags:del ("bal")
	end--if
	
	if not silent	then
		display.offbal (sBal)
	end --if
	
end --function


	--when you try to consume a balance
function bals:try (sBal, silent)

		--I have a special failsafe to deal with aeon/sap/choke, I don't need the normal failsafes
	if
		not affs:has ("aeon") and
		not affs:has ("sap") and
		not affs:has ("choke")
			then
		fst:enable (sBal)	
	end --if
	self [sBal] = 0.5
	
end --function
	

return bals
		
		