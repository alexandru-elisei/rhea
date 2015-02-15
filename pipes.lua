--[[
	PIPES TRACKING -- I NEED A FLAG FOR SMOKING!
	***I smoke faeleaf, it doesn't take herb balance (act:smoke)
	***I enable fst:rebound, when it fires deletes the flags for no_rebound, so I can try again to smoke
	***when I smoke, I disable fst:rebound and enable fst:ondef_rebound
	***I disable fst:ondef_rebound when I get rebound
--]]


require "affs"
require "flags"
require "fst"
require "serialize"
--require "system"

	--init
if
	not (pipes)
		then
	pipes = {}
	pipes = {
		["current"] ={
			["myrtle"] = {},
			["coltsfoot"] = {},
			["faeleaf"] = {},
			["arties"]  = {},
		},
	}	
end --if


--Note ("")
--display.tprint (pipes, "all")



--[[I NEED TO KEEP TRACK ALL THE TIME OF THE EMPTY PIPES, THIS INCLUDES MARKING THEM
IN MY AFFS.REFILL_PIPES TABLE, AS WELL AS SETTING THEIR PUFFS TO 0.
THIS IS IMPERATIVE.
]]--


function pipes:reset (silent)

	self ["current"] ["myrtle"] = {}
	self ["current"] ["coltsfoot"] = {}
	self ["current"] ["faeleaf"] = {}
	
	if not silent	then
		display.system ("Pipes RESET")
	end --if
	
end --function
	
	
function pipes:save ()
	
	system_pipes = self ["current"]
	SetVariable ("system_pipes", serialize.save ("system_pipes"))
	system_pipes = {}
	system_pipes = nil	
	
end --function


function pipes:init ()

	loadstring (GetVariable ("system_pipes")) ()
	self ["current"] = system_pipes
	system_pipes = {}
	system_pipes = nil

end --function


function pipes:is_artie (pipe)

	return self ["current"] [pipe] and self ["current"] ["arties"] [self ["current"] [pipe] ["id"]]

end --function

		
function pipes:set_unlit (pipe)

	if
		self ["current"] [pipe] and
		not self:is_artie (pipe)
			then
		self ["current"] [pipe] ["status"] = "unlit"
	end --if
	
end --function


function pipes:set_lit (pipe)

	if self ["current"] [pipe] then
		self ["current"] [pipe] ["status"] = "lit"
	end --if
	
end --function


function pipes:is_lit (pipe)
	
	if
		next (self ["current"] [pipe]) and
		(self ["current"] [pipe] ["status"] == "lit" or self ["current"] ["arties"] [self ["current"] [pipe] ["id"]])
			then
		return true
	end --if
	
	return false
	
end --function


function pipes:set_empty (pipe)

	if self ["current"] [pipe]  then--making sure I pass a valid pipe
		self ["current"] [pipe] ["puffs"] = 0
	end --if
	
end --function


function pipes:is_empty (pipe)
	
	if
		self ["current"] [pipe] and
		self ["current"] [pipe] ["puffs"] == 0
			then
		return true
	end --if
	
	return false
	
end --function


function pipes:set_full (pipe)

	if self ["current"] [pipe] then --making sure I pass a valid pipe
		self ["current"] [pipe] ["puffs"] = self ["current"] [pipe] ["maxpuffs"]
	end --if
	
end --function


function pipes:scan ()

	if
		not pipes ["current"] ["myrtle"] ["id"] or
		not pipes ["current"] ["coltsfoot"] ["id"] or
		not pipes ["current"] ["faeleaf"] ["id"]
			then
		return
	end--if
	
	if not affs:has ("pipes_refill") then
		if pipes:is_empty ("myrtle") then
			affs:add ("pipes_refill", "myrtle", "silent")
		elseif pipes:is_empty ("coltsfoot") then
			affs:add ("pipes_refill", "coltsfoot", "silent")
		elseif pipes:is_empty ("faeleaf") then
			affs:add ("pipes_refill", "faeleaf", "silent")
		end --if
	end --if
	
	if not affs:has ("pipes_unlit") then
		if
			not pipes:is_lit ("myrtle") and
			not pipes:is_empty ("myrtle")
				then
			affs:add ("pipes_unlit", pipes ["current"] ["myrtle"] ["id"], "silent")
		elseif
			not pipes:is_lit ("coltsfoot") and
			not pipes:is_empty ("coltsfoot")
				then
			return affs:add ("pipes_unlit", pipes ["current"] ["coltsfoot"] ["id"], "silent")
		elseif
			not pipes:is_lit ("faeleaf") and
			not pipes:is_empty ("faeleaf")
				then
			return affs:add ("pipes_unlit", pipes ["current"] ["faeleaf"] ["id"], "silent")
		end --if
	end --if
	
end --function				


	--EACH TIME I SMOKE A PIPE
function pipes:smoking (special)
	
		--I cannot smoke if I am stun/unconscious/blackout
	affs:del ({"stun", "unconscious"})
	fst:disable ("stun")
	system:cured ("blackout")
		--in case I was trying to smoke in aeon
	sca:check ()
		--failsafes & cleaning up
	EnableTrigger ("smoking_phrenic", false)
	EnableTrigger ("smoking_empty", false)
	EnableTrigger ("smoking_pipesunlit", false)
		--searching for what I smoked
	local pipe = flags:get ("smoking") or special
	if pipe then --maybe I have lag			
			--updating pipe status
		self ["current"] [pipe] ["puffs"] = self ["current"] [pipe] ["puffs"]-1
			--setting the cure
		system:add_cure ("smoke_"..pipe)
	end --if.
	
	flags:del ("smoking")
	pipes:scan ()
	pipes:save ()
	
end --function


	--TO BE EXECUTED WHEN ONE OF THE PIPES IS UNLIT
function pipes:err (case) -- err signifies that there was an error in the tracking

	EnableTrigger ("smoking_phrenic", false)
	EnableTrigger ("smoking_", false)
	EnableTrigger ("smoking_empty", false)
	EnableTrigger ("smoking_pipesunlit", false)
	
	local pipe = flags:get ("smoking")
	if case == "unlit" then
		affs:del ("pipes_unlit")
	elseif case == "empty" then
		if pipe then --herb failsafe fired before I could smoke
			pipes:set_empty (pipe)
			affs:del ("pipes_refill")
		end --if
	elseif case == "phrenicnerve" then
		affs:add_queue ("phrenicnerve")
	end --if
	if pipe then
		for aff, cure in pairs (flags ["current"]) do
			if cure == "smoke_"..pipe then
				flags:del (aff)
			end --if
		end --for
		flags:del (flags:is_sent ("smoke_"..pipe))
		bals:onbal ("herb")
		system:del_cure ("smoke_"..pipe) --deleting the smoke cure from the sent cures table, because it failed
	end --if
	
	sca:check ()
	flags:del ("smoking")
	pipes:scan ()	
	pipes:save ()

end --function


	---WHEN I LIGHT A PIPE; LIGHT_PIPES !
function pipes:light ()
		
		--resetting it here, I disable it later in the function
	fst:disable ("pipes_unlit")
		--one pipe less to light
	if flags:get ("pipes_unlit") then  --only in case the light command wasn't sent by the system, to remove once I fix aliases to work with the system
		if self ["current"] ["myrtle"] ["id"] == affs:has ("pipes_unlit") then
			self:set_lit ("myrtle")
		elseif self ["current"] ["coltsfoot"] ["id"] == affs:has ("pipes_unlit") then
			self:set_lit ("coltsfoot")
		elseif self ["current"] ["faeleaf"] ["id"] == affs:has ("pipes_unlit") then
			self:set_lit ("faeleaf")
		end --if
	end --if
	
	affs:del ("pipes_unlit")
	pipes:scan ()
	pipes:save ()
	
	sca:check ()
	
end --function


	--when i refill a pipe
function pipes:filled ()
	
		--failsafes
	fst:disable ("pipes_refill")
	EnableTrigger ("pipesfilled", false) --! 
	EnableTrigger ("pipesfull", false) -- !
		--updating pipe status
	local pipe = affs:has ("pipes_refill")
	self:set_full (pipe)
	self:set_unlit (pipe)
		--I refilled this pipe
	affs:del ("pipes_refill")
	sca:check ()
		
	pipes:scan ()	
	pipes:save ()
	
end --function


function pipes:assign (pipe, i, p, s)

	if pipe then
		if pipe ~= "empty" then
			s = string.lower (s)
			if
				pipe ~= "myrtle" and
				pipe ~= "faeleaf" and
				pipe ~= "coltsfoot"
					then
				return display.warning ("invalid pipe type")
			end --if
			self ["current"] [pipe] ["id"] = i
			self ["current"] [pipe] ["puffs"] = tonumber (p)
			if s == "artie" then
				self ["current"] ["arties"] [i] = true
			end --if
				--setting the maximum number of puffs
			if
				self:is_artie (pipe)
					then
				self ["current"] [pipe] ["status"] = "artie"
				self ["current"] [pipe] ["maxpuffs"] = 20
			else
				self ["current"] [pipe] ["maxpuffs"] = 10
				self ["current"] [pipe] ["status"] = s
			end --if
				--increasing that by 10 if I have smoking, in herbs
			if skills:is_available ("smoking") then
				self ["current"] [pipe] ["maxpuffs"] = self ["current"] [pipe] ["maxpuffs"] + 10
			end --if
		else
			pipe_ids = pipe_ids or {}
			pipe_ids [#pipe_ids + 1] = i
		end --if
	else
		if --if I have all the pipes assigned, but still empty ones
			self ["current"] ["myrtle"] ["id"] and
			self ["current"] ["coltsfoot"] ["id"] and
			self ["current"] ["faeleaf"] ["id"]
				then
			pipes_ids = {} --I don't assign the empty ones
			pipes_ids = nil
		end --if
		
		if pipe_ids then
			local pipe_type = {"myrtle", "faeleaf", "coltsfoot"}
			
				--if the pipe is unassigned
			for k, pipe in ipairs (pipe_type) do
				if
					not self ["current"] [pipe] ["id"] and
					next (pipe_ids)
						then
					pipes:assign (pipe, pipe_ids [#pipe_ids], 0, "unlit")
					if not affs:has ("pipes_refill") then
						affs:add ("pipes_refill", pipe, "silent")
					end --if
					display.system ("Pipe "..tostring (pipe_ids [#pipe_ids]).." assigned to "..pipe)
					pipe_ids [#pipe_ids] = nil
				end --if
			end --for
			
				--cleaning up
			pipe_ids = {}
			pipe_ids = nil
			
		end --if
	end --if
	
	pipes:scan ()
	pipes:save ()
	
end --function


pipes:init ()


return pipes