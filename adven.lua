--[[ Tracking of ALlies/ENemies]]--

if not adven then
	adven = {
		["enemy_list"] = {}, --current enemies
		["enemies"] = {},--ALL my enemies, by tiers
		["default_enemies"] = {},--the most dangerous ones, default for enemy list
		["ally_list"] = {},--current allies
		["to_enemy"] = {},}
end--if


function adven:reset (item)

	if not item then
		self ["enemy_list"] = {}
		self ["ally_list"] = {}
		self ["to_enemy"] = {}
	elseif self [item] then
		self [item] = {}
	end--if
	self:save ()
	
	display.system ("Allies/enemies RESET")
	
end--reset


function adven:init ()

	loadstring (GetVariable ("system_enemies")) ()
	loadstring (GetVariable ("system_default_enemies")) ()
	loadstring (GetVariable ("system_enemy_list")) ()
	loadstring (GetVariable ("system_ally_list")) ()
	
	self ["enemies"] = system_enemies
	self ["default_enemies"] = system_default_enemies
	self ["enemy_list"] = system_enemy_list
	self ["ally_list"] = system_enemy_list
	
	system_enemies = {} system_enemies = nil
	system_default_enemies = {} system_default_enemies = nil
	system_enemy_list = {} system_enemy_list = nil
	system_ally_list = {} system_ally_list = nil
	
	if not next (adven.enemies) then
		display.system ("Remember to add your enemies!")
		prompt:add_alert ("ne", "NO PERMANENT ENEMIES", 5)
	end --if

end--init


function adven:save ()

		--will highlight all my enemies
	local to_highlight = ""
	if next (self.enemies) then
		for k, n in ipairs (self.enemies) do
			for k1, name in ipairs (n) do
				to_highlight = (to_highlight or "")..name.."|"
			end--for
		end--for
		to_highlight=string.sub (to_highlight, 1, #to_highlight-1)
	end--if
	SetVariable ("highlight_enemies", to_highlight)
	
		--will highlight the enemies in the enemy list (probably underlined, same colour as above)
	to_highlight = ""
	if next (self.enemy_list) then
		for name, v in pairs (self.enemy_list) do
			to_highlight = (to_highlight or "")..name.."|"
		end--for
		to_highlight=string.sub (to_highlight, 1, #to_highlight-1)
	end--if
	SetVariable ("highlight_enemy_list", to_highlight)
	to_highlight = nil
	
	system_enemies = self.enemies or "system_enemies = {}"
	SetVariable ("system_enemies", serialize.save ("system_enemies"))
	system_enemies = {} system_enemies = nil
	system_enemy_list = self.enemy_list or "system_enemy_list = {}"
	SetVariable ("system_enemy_list", serialize.save ("system_enemy_list"))
	system_enemy_list = {} system_enemy_list=nil
	system_default_enemies = self.default_enemies or "system_default_enemies = {}"
	SetVariable ("system_default_enemies", serialize.save ("system_default_enemies"))
	system_default_enemies={} system_default_enemies=nil
	system_ally_list = self.ally_list or "system_ally_list = {}"
	SetVariable ("system_ally_list", serialize.save ("system_ally_list"))
	system_ally_list={} system_ally_list=nil
	
end--save

	--sets all enemies, by tiers
function adven:se (input, tier, pos)

	if tier>5 then---five tiers
		return display.error ("Enemies Are Organized Into 5 Tiers")
	end--if
	
	local name = {}
	local to_display = ""
	for n in string.gmatch (input, "%a+") do
		n = string.upper (string.sub (n,1,1))..string.lower (string.sub (n,2))
		table.insert (name, n)
		if to_display=="" then
			to_display = n
		else
			to_display = to_display..", "..n
		end--if
	end--for
	
	if tier>0 then
		self ["enemies"] [tier] = self ["enemies"] [tier] or {}
			
			--removing any previous entries from the enemies
		if next (self.enemies) then
			for t, n in ipairs (self.enemies) do
				local i = 1
				repeat
					if system:getkey (name, n[i]) then
						table.remove (n, i)
					else
						i=i+1
					end --if
				until (i>#n)
			end--for
		end--removing duplicates
		
		if pos then
			i=0
			for k, n in ipairs (name) do
				table.insert (adven ["enemies"] [tier], pos+i, n)
				i=i+1
			end--for
		else
			for k, n in ipairs (name) do
				table.insert (adven ["enemies"] [tier], n)
			end--for
		end--if
		display.system ("Enemies Added:")
	else
		for x, n in ipairs (name) do
			for k, names in ipairs (adven.enemies) do
				local p = system:getkey (names, n)
				if p then table.remove (adven ["enemies"] [k], p) end
			end--for
		end--for
		display.system ("Enemies Removed:")
	end--if
	ColourNote ("aqua", "", "  "..to_display)
	self:save ()
	
end--se

	--queues a person to enemy
function adven:queue_enemy (input, special)

	if not self.to_enemy then
		self.to_enemy = {}
	end
	
	if type (input) == "table" then
		for k, n in ipairs (input) do
			n = string.upper (string.sub (n,1,1))..string.lower (string.sub (n,2))
			if not system:getkey (self.to_enemy, n) then--making sure there are no duplicates
				table.insert (self.to_enemy, n)
			end--for
		end--for
	elseif type ("input") == "string" then
		for n in string.gmatch (input, "%a+") do
			n = string.upper (string.sub (n,1,1))..string.lower (string.sub (n,2))
			if not system:getkey (self.to_enemy, n) then--making sure there are no duplicates
				table.insert (self.to_enemy, n)
			end--for
		end--for
	end--if
	self:enemied (nil, special)
	
end--queue_enemy

	--enemied someone
function adven:enemied (name, special)
	
	if name then--if I actually enemied someone
		todo:done ("enemying", "free")
		table.remove (self.to_enemy, 1)--I always enemy the first person on the list
		self:set_enemy (name)
		if not next (self.to_enemy) then
			display.system ("Enemying Done")
		end--if
	elseif special and next (self.to_enemy) then--if I am adding all the enemies in the area through scan or scent, for example
		todo:add ("free", "unenemyall", "unenemy all", nil, true)--I unenemy all my enemy list
		return
	else
		self:prioritize_enemies ()
	end--if
	
	if next (self.to_enemy) then--if I have a list of people to enemy
		todo:add ("free", "enemying", "enemy "..self ["to_enemy"] [1], nil, true)
	end--if

end--enemied

	--sorts the persons I want to enemy by tiers and position
function adven:prioritize_enemies ()
	
	local temp = {}
	local done = {}
	for k, v in ipairs (self.to_enemy) do
		local ct = 6
		local cp = 100
		local ce
		if not done [v] then--if v wasn't yet sorted
			for t, n in ipairs (self.enemies) do
				local x=system:getkey (n, v)
				if x then
					ct = t--the current enemy takes the tier, position and name of v
					cp = x
				end--if
			end--for
			ce = v
		else
			ct = nil--if v was sorted then I delete its tier, position and name
			cp = nil
			ce = nil
		end--if
		for i=1, #self.to_enemy do
			local name = self ["to_enemy"] [i]
			if not done [name] then
				if not ce then--if name wasn't sorted and I don't have a current enemy
					ct = 6
					cp = 100
					for t, n in ipairs (self.enemies) do
						local x=system:getkey (n, name)
						if x then
							ct = t
							cp = x
						end--if
					end--for
					ce = name
				else--if I have a current enemy to compare the others to
					for t, n in ipairs (self.enemies) do
						local x = system:getkey (n, name)--I get it's place in the tiers
						if 	x and 
							(t<ct or (t==ct and x<cp))--if it;s priority is bigger than the current enemy
								then
							ce = name--then name because the current enemy to compare the others to
							ct = t
							cp = x
						end--if
					end--for
				end--if
			end--if
		end--for
		done [ce] = true
		table.insert (temp, ce)
	end --for
	
	self.to_enemy = {}
	local max_enemies = system:get_settings ("max_enemies")
	if max_enemies<30 then max_enemies = 30 end
	for k, v in ipairs (temp) do
		if k<= max_enemies then
			self ["to_enemy"] [k] = v
		end--if
	end--for
	
end--prioritize_enemies

	--sets default enemies
function adven:sde (name, special)

	if next (self.default_enemies) then
		local total = 0
		for n, v in pairs (self.default_enemies) do
			total = total+1
		end--for
		if system:get_settings ("max_enemies") <= 0 and total>30  then
			return display.error ("You Can Only Have 30 Default Enemies!")
		elseif total>system:get_settings ("max_enemies") then
			return display.error ("You Can Only Have 30 Default Enemies!")
		end--if
	end--if
	
	if special then--I copy them from my enemy list
		if next (self.enemy_list) then
			for n, v in pairs (self.enemy_list) do
				self ["default_enemies"] [n] = true
			end--for
		end--if
	elseif not name then
		return display.error ("Specify Names For Default Enemies!")
	else
		for n in string.gmatch (name, "%a+") do
			n = string.upper (string.sub (n,1,1))..string.lower (string.sub (n,2))
			self ["default_enemies"] [n] = true
		end--for	
	end--if
	self:save ()
	
	display.system ("Default Enemies Added")
	
end--sde
	

function adven:set_ally (name)

	self ["ally_list"] [name] = true
	self:save ()

end --function


function adven:set_enemy (name)

	self ["enemy_list"] [name] = true
	self:save ()
	
end --function


function adven:del_enemy (name)

	self ["enemy_list"] [name] = nil
	self:save ()
	
end --function


function adven:is_ally (name)

	return (next (self ["ally_list"]) and self ["ally_list"] [name])
	
end --function


function adven:is_enemy_list (name)

	return (next (self ["enemy_list"]) and adven ["enemy_list"] [name])
	
end --function


function adven:is_enemy (name)

	if next (self.enemies) then
		for k, n in ipairs (self.enemies) do
			if system:getkey (n, name) then
				return true
			end--if
		end--for
	end--if
	
	return false
	
end --function


function adven:revert_enemies ()

	if verb == "save" then
		system ["perm_enemies"] = system ["enemies"]
		self:save ()
	elseif verb == "revert" then
		if not next (system ["perm_enemies"]) then
			return display.warning ("You have no permanent enemies to revert to!")
		else
			system ["enemies"] = system ["perm_enemies"]
			self:save ()
		end --if
	else
		display.system ("Permanent Enemies:")
		Note ("")
		for en, v in pairs (self ["perm_enemies"]) do
			ColourNote ("aqua", "", "    "..en)
		end --for
	end --if
	
end --function

adven:init ()

return adven