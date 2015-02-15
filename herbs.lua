--[[
	HARVESTING HERBS AND SUCH
	
--]]

if not herbs then
	herbs = {
		["hibernation"] = {
			["horehound"] = "Vestian",
			["wormwood"] = "Vestian",
			["mistletoe"] = "Avechary",
			["flax"] = "Estar",
			["weed"] = "Estar",
			["myrtle"] = "Estar",
			["merbloom"] = "Estar",
			["kafe"] = "Urlachmar",
			["colewort"] = "Kiani",
			["sage"] = "Dioni",
			["kombu"] = "Dioni",
			["juniper"] = "Dioni",
			["calamus"] = "Dioni",
			["earwort"] = "Dioni",
			["sparkleberry"] = "Dvarsh",
			["sargassum"] = "Tzarin",
			["rawtea"] = "Tzarin",
			["reishi"] = "Tzarin",
			["arnica"] = "Klangiary",
			["pennyroyal"] = "Klangiary",
			["galingale"] = "Shanthin",
			["rosehips"] = "Shanthin",
			["marjoram"] = "Shanthin",
			["chervil"] = "Roarkian",
			["yarrow"] = "Roarkian",
			["faeleaf"] = "Juliary",
			["coltsfoot"] = "Juliary"
		},
		["names"] = {
			["an arnica bud"] = "arnica",
			["a calamus root"] = "calamus",
			["a sprig of chervil"] = "chervil",
			["a colewort leaf"] = "colewort",
			["a plug of coltsfoot"] = "coltsfoot",
			["a piece of black earwort"] = "earwort",
			["a stalk of faeleaf"] = "faeleaf",
			["a bunch of flax"] = "flax",
			["a stem of galingale"] = "galingale",
			["a horehound blossom"] = "horehound",
			["a juniper berry"] = "juniper",
			["a kafe bean"] = "kafe",
			["kombu seaweed"] = "kombu",
			["a sprig of marjoram"] = "marjoram",
			["a piece of merbloom seaweed"] = "merbloom",
			["a sprig of mistletoe"] = "mistletoe",
			["a bog myrtle leaf"] = "myrtle",
			["a bunch of pennyroyal"] = "pennyroyal",
			["raw tea leaves"] = "rawtea",
			["a reishi mushroom"] = "reishi",
			["a pile of rosehips"] = "rosehips",
			["a sage branch"] = "sage",
			["sargassum seaweed"] = "sargassum",
			["a sparkleberry"] = "sparkleberry",
			["a packet of spices"] = "spices",
			["a sprig of cactus weed"] = "weed",
			["a wormwood stem"] = "wormwood",
			["a yarrow sprig"] = "yarrow"
		},
		["limit"] = 5,
		["queued"] = {},
		["inroom"] = {},
	}
end--if

	--resetting harvesting
function herbs:reset ()
	
	self ["queued"] = {}
	todo:done ("pick_herb", "bal")
	EnableTriggerGroup ("System_Herbs", false)
	
end--function

	--checking if a herb is hibernating
function herbs:is_hibernating (name, month)
	
	if not month then
		return
	end --if
	
	local herb = self ["names"] ["name"] or name
	return self ["hibernation"] [herb] == month

end --if	

	--queueing herbs to be harvested
function herbs:pick (name, number)
	
	if name and type (name) == "table" then
		for k, herb in ipairs (name) do
			herbs:add (herb)
		end --for
		return
	end --if
	
	if not name then
		return display.warning ("You must specify a herb to harvest!")
	end --if
	
	if not self ["hibernation"] [name] then
		return display.system ("Unknown Herb")
	end --if
	
	if not number then
		if next (self ["inroom"]) then
			number = (self ["inroom"] [name] or 0) - self ["limit"]
		end --if
	end --if
	
	if not number or number<0 then
		return display.warning ("You must specify a number of herbs to pick!")
	end --if
	
	if self ["inroom"] [name]-number < self ["limit"] then
		return display.warning ("Harvesting DENIED for STRIP HARVESTERS")
	end --if
	
	for k, v in ipairs (self ["queued"]) do
		if v ["name"] == name then
			return
		end --if
	end --for
	
	EnableTriggerGroup ("System_Herbs", true)
	local tag = {
		["name"] = name,
		["number"] = number,
	}
	table.insert (self ["queued"], tag)
	if not todo:is_queued ("pick_herb") then
		todo:add ("bal", "pick_herb", "harvest "..name)
	end --if
	
	if IsConnected () then
		Send ("")
	end--if

end --function

	--finished harvesting a herb
function herbs:picked (spices)
	
	if not next (self ["queued"]) then
		return
	end --if
	
	local herb = self ["queued"] [1] ["name"]
	if spices then
		Send ("inr spices")
	end --if
	todo:done ("pick_herb", "bal")
	self ["queued"] [1] ["number"] = self ["queued"] [1] ["number"]-1
	if self ["queued"] [1] ["number"]<=0 then
		table.remove (self ["queued"], 1)
		Send ("inr all herb")
		Send ("inb all herb")
	else
		display.system (self ["queued"] [1] ["name"]..": "..tostring (self ["queued"] [1] ["number"]).." left")
	end --if
	if next (self ["queued"]) then
		todo:add ("bal", "pick_herb", "harvest "..self ["queued"] [1] ["name"])
	else
		EnableTriggerGroup ("System_Herbs", false)
	end --if
	
end --function

	--in case something went wrong
function herbs:del (special)

	if special then
		self:reset ()
	end --if
	
	if next (self ["queued"]) then
		self ["queued"] [1] ["number"] = 0
	end --if
	self:picked ()
	
end --function

	--getting the herbs in the room, and colouring them based on the quantity
function herbs:get (name, number)

	if not self ["names"] [name] then
		return display.system ("Unknown Herb")
	end --if
	
	name = self ["names"] [name]
	self ["inroom"] [name] = number--name is 'an arnica bug', or 'a stem of galingale'
	local fg = "greenyellow"
	if herbs:is_hibernating (name) then
		fg = "dimgray"
	elseif number <= 5 then
		fg = "darkorange"
	end--if
	
	local l=15
	ColourTell ("silver", "", string.upper (string.sub (name,1,1))..string.lower (string.sub (name,2))..": "..string.rep (" ", l-#name))
	ColourNote (fg, "", tostring (number).." left")

end --function
	
	