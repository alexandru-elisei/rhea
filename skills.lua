--[[
		TRACKS YOUR SKILL LEVELS AND CONFIGURES THE SYSTEM ACCORDINGLY
	
--]]--


require "display"
require "serialize"

if
	not skills
		then
	skills = {
		["levels"] = {},
		["available"] = {},
		["ranks"] = {
			"inept",
			"novice",
			"apprentice",
			"capable",
			"adept",
			"master",
			"gifted",
			"expert",
			"virtuoso",
			"fabled",
			"mythical",
			"transcendent",
		},
	}
end --if

	--to be used only when I do skills
function skills:reset (silent)
	
	for k, v in pairs (self ["levels"]) do
		DeleteGroup  ("System_"..string.upper (string.sub (v, 1, 1))..string.lower (string.sub(v, 2)))
	end--for
	self:get_cures (silent, "delete")
	self ["levels"] = {}
	if not silent then
		display.system ("Skills RESET")
	end --if
	
end --reset

function skills:set (skill, level)

	self ["levels"] [skill] = level
	if
		skill == "blademaster" or
		skill == "bonecrusher" or
		skill == "axelord" or
		skill == "pureblade"
			then
		skill = "knighthood"
	end --if
	local file = io.open ("system_"..skill..".xml")
	if file then
		io.input ("system_" ..skill.. ".xml")
		local xml = io.read ("*all")
		ImportXML(xml)
		io.close (file)
	end--if
	
end--function


function skills:save ()
	
	system_skills= {}
	system_skills ["levels"] = self ["levels"]
	system_skills ["available"] = self ["available"]
	SetVariable ("system_skills", serialize.save ("system_skills"))
	
		--updating various modules that use the skills available
	stance:get_available ()
	system:init ("silent")
	
	system_skills = {}
	system_skills = nil
	
end --function


function skills:init ()

	loadstring (GetVariable ("system_skills")) ()
	skills ["levels"] = system_skills ["levels"]
	skills ["available"] = system_skills ["available"]
	system_skills = {}
	system_skills = nil
	
end --function

	--returns all the available skills, with their syntax
function skills:get_available ()

	skills ["available"] = {}
	if (defs:has ("archlich") or defs:has ("lich")) and
		calendar:is_night ()
			then
		self ["available"] ["adroitness"] = {
			["use"] = "defs_free",
			["syntax"] = "adroitness"}
	end --if
	
	for k, v in pairs (self) do
		if type (v) == "table" then
			for level, s in pairs (v) do
				if 	self ["levels"] [k] and --if self ["levels"] ["highmagic"] == self ["highmagic"]
					system:getkey (self ["ranks"],  level) <= system:getkey (self ["ranks"], self ["levels"] [k])
						then
					for name, attbs in pairs (s) do
						self ["available"] [name] = {
							["use"] = attbs ["use"],
							["syntax"] = attbs ["syntax"]}
					end --for
				end --if
			end --for
		end --if
	end --for
	
end--get_available ()


function skills:get_defs (ctg)

	if not next (self ["levels"]) then
		return display.error ("No Skills Installed!")
	end--if
	
	local defenses = defenses or {}
	for k, v in pairs (self ["available"]) do
		if v ["use"] == "defs_"..ctg then
			table.insert (defenses, k)
		end --if
	end --for
	
	return defenses
	
end --function


function skills:get_cures (silent, del)
	
	if not next (self ["levels"]) then
		return display.error ("No Skills Installed!")
	end--if
	
	for k, v in pairs (self) do
		if type (v) == "table" then
			for level, s in pairs (v) do
				if type (s) == "table" then
					for name, attb in pairs (s) do
						system ["settings"] [name] = nil --making sure I remove cures I cannot use
					end--for
				end--if
			end--for
		end--if
	end--for
	
	for k, v in pairs (self ["available"]) do
		if v ["use"] == "cures" then
			system:set_settings (k, 1, true)
		end--if
	end --for 
	
	if system:is_enabled ("magiclist") then
		local file = io.open ("system_magiclist.xml")
		if file then
			io.input ("system_magiclist.xml")
			local xml = io.read ("*all")
			ImportXML(xml)
			io.close (file)
		end--if
	else
		DeleteGroup ("System_Magiclist.xml")
	end --if
	
end --function


function skills:is_available (skill)

	if not next (self ["levels"]) then
		return display.error ("No Skills Installed!")
	end--if
	
	return (self ["available"] [skill] and next (self ["available"] [skill]))

end --function


function skills:use (skill, now)
	
	if not next (self ["levels"]) then
		return display.error ("No Skills Installed!")
	end--if
	
	if not skills ["available"] [skill] then
		return display.error ("Skill Not Available")
	end--if
	
	if now then
		Send (skills ["available"] [skill] ["syntax"])
	else
		act:queue (skills ["available"] [skill] ["syntax"])
	end--if
	
end --function

	
function skills:get_skilltree (skilltree)

	local result = {}
	
	for k, v in pairs (skills) do
		if
			type (v) == "table" and
			skilltree == k
				then
			for level, s in pairs (v) do
				if self ["levels"] [k] then
					local pos_level = 200
					for pos, tc in ipairs (self ["ranks"]) do
						if tc == level then
							pos_level = pos
							break
						end --if
					end --for
					local pos_ranks_k = 199
					for pos, tc in ipairs (self ["ranks"]) do
						if tc == self ["levels"] [k] then
							pos_ranks_k = pos
							break
						end --if
					end --for
					if pos_level <= pos_ranks_k then
						for name, attbs in pairs (s) do
							result [name] = self [k] [level] [name] ["syntax"]
						end --for
					end --if
				end --if
			end --for
		end --if
	end --for
	
	return result

end --function
	
	
skills ["discernment"] = {
	["inept"] = {
		["nightsight"] = {
			["use"] = "defs_free",
			["syntax"] = "nightsight",
		},
	},
	["novice"] = {
		["wounds"] = {
			["use"] = "cures",
			["syntax"] = "wounds",
		},
	},
	["apprentice"] = {},
	["capable"] = {
		["diag"] = {
			["use"] = "cures",
			["syntax"] = "diag",
		},
	},
	["adept"] = {
		["deathsense"] = {
			["use"] = "defs_ubal",
			["syntax"] = "deathsense",
		}
	},
	["master"] = {
		["pipelist"] = {
			["use"] = "cures",
			["syntax"] = "pipelist",
		},
		["thirdeye"] = {
			["use"] = "defs_free",
			["syntax"] = "thirdeye",
		},
	},
	["gifted"] = {
		["potionlist"] = {
			["use"] = "cures",
			["syntax"] = "potionlist",
		},
	},
	["expert"] = {
		["magiclist"] = {
			["use"] = "cures",
			["syntax"]= "magiclist",
		},
	},
	["virtuoso"] = {
		["contemplate"] = {
			["use"] = "instakill",
			["syntax"] = "contemplate",},
	},
	["fabled"] = {
		["comtemplation"] = "action",
	},
	["mythical"] = {
	},
	["transcendent"] = {
		["discerning"] = "action",
		["aethersight"] = {
			["use"] = "defs_power",
			["syntax"] = "aethersight on",
		},
	},
}

skills ["athletics"] = {
	["inept"] = {
		["weathering"] = {
			["use"] = "defs_free",
			["syntax"] = "weathering",
		},
	},
	["novice"] = {
		["vitality"] = {
			["use"] = "defs_ubal",
			["syntax"] = "vitality",
		},
		["breathe"] = {
			["use"] = "defs_ubal",
			["syntax"] = "breathe deep",
		},
	},
	["apprentice"] = {
		["sturdiness"] = {
			["use"] = "defs_ubal",
			["syntax"] = "stand firm",
		},
	},
	["capable"] = {
		["blocking"] = "action",
	},
	["adept"] = {
		["regeneration"] = {
			["use"] = "defs_user",
			["syntax"] = "regeneration on",
		},
		["resistance"] = {
			["use"] = "defs_rbal",
			["syntax"] = "resistance",
		},
	},
	["master"] = {
		["tackle"] = "action",
		["sprinting"] = "action",
		["barging"] = "action",
	},
	["gifted"] = {
		["constitution"] = {
			["use"] = "defs_ubal",
			["syntax"] = "constitution",
		},
		["adrenaline"] = {
			["use"] = "cures",
			["syntax"] = "adrenaline",
		},
	},
	["expert"] = {
		["hunger"] = {
			["use"] = "cures",
			["syntax"] = "hunger",
		},
	},
	["virtuoso"] = {
		["strength"] = {
			["use"] = "defs_ubal",
			["syntax"] = "flex",
		},
		["consciousness"] = {
			["use"] = "defs_ubal",
			["syntax"] = "consciousness on",
		},
	},
	["fabled"] = {
		["transmute"] = {
			["use"] = "cures",
			["syntax"] = "transmute ",
		},
		["boosting"] = {
			["use"] = "defs_user",
			["syntax"] = "boost regeneration", --REALLY BIG QUESTION MARK
		},
	},
	["mythical"] = {
		["numbness"] = {
			["use"] = "defs_power",
			["syntax"] = "numb", --REALLY BIG QUESTION MARK
		},
		["immunity"] = {
			["use"] = "defs_power",
			["syntax"] = "immunity",--REALLY BIG QUESTION MARK
		},
	},
	["transcendent"] = {
		["surge"] = {
			["use"] = "defs_power",
			["syntax"] = "surge",--REALLY BIG QUESTION MARK
		},
		["puissance"] = "action",
	},
}

skills ["discipline"] = {
	["inept"] = {
		["focus_body"] = {
			["use"] = "cures",
			["syntax"] = "focus body",
		},
	},
	["novice"] = {
		["clot"] = {
			["use"] = "cures",
			["syntax"] = "clot",
		},
	},
	["apprentice"] = {
		["insomnia"] = {
			["use"] = "cures",
			["syntax"] = "insomnia",
		},
	},
	["capable"] = {},
	["adept"] = {},
	["master"] = {
		["restore"] = {
			["use"] = "cures",
			["syntax"] = "restore",
		},
	},
	["gifted"] = {
		["metawake"] = {
			["use"] = "cures",
			["syntax"] = "metawake on",
		},
	},
	["expert"] = {},
	["virtuoso"] = {
		["selfishness"] = {
			["use"] = "defs_ubal",
			["syntax"] = "selfishness", 
		},
	},
	["fabled"] = {
		["focus_mind"] = {
			["use"] = "cures",
			["syntax"] = "focus mind",
		},
	},
	["mythical"] = {},
	["transcendent"] = {},
}
		

skills ["environment"] = {
	["inept"] = {},
	["novice"] = {},
	["apprentice"] = {},
	["capable"] = {},
	["adept"] = {},
	["master"] = {
		["rockclimbing"] = {
			["use"] = "cures",
			["syntax"] = "climb rocks",},},
	["gifted"] = {},
	["expert"] = {
		["tumble"] = {
			["use"] = "cures",
		},
	},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}


skills ["highmagic"] = {
	["inept"] = {
		["pentagram"] = {
			["use"] = "shield",
			["syntax"] = "evoke pentagram",
		},
	},
	["novice"] = {
		["malkuth"] = {
			["use"] = "defs_ubal",
			["syntax"] = "evoke malkuth",
		},
	},
	["apprentice"] = {},
	["capable"] = {
		["yesod"] = {
			["use"] = "defs_ubal",
			["syntax"] = "evoke yesod",
		},
		["netzach"] = {
			["use"] = "defs_ubal",
			["syntax"] = "evoke netzhach",
		},
	},
	["adept"] = {
		["hod"] = {
			["use"] = "cures",
			["syntax"] = "evoke hod",
		}
	},
	["master"] = {
		["tipheret"] = {
			["use"] = "cures", --same as summer
			["syntax"] = "evoke tipheret",
		},
	},
	["gifted"] = {},
	["expert"] = {
		["geburah"] = {--I think it's con or str bonus
			["use"] = "defs_power",
			["syntax"] = "evoke geburah",
		},
	},
	["virtuoso"] = {
		["gedulah"] = {--same as green
			["use"] = "cures",
			["syntax"] = "evoke gedulah",
		},
	},
	["fabled"] = {
		["chockmah"] = {
			["use"] = "defs_ubal",
			["syntax"] = "evoke chockmah",
		},
	},
	["mythical"] = {},
	["transcendent"] = {},
}


skills ["lowmagic"] = {
	["inept"] = {
		["circle"] = {
			["use"] = "shield",
			["syntax"] = "invoke circle",
		},
	},
	["novice"] = {
		["red"] = {
			["use"] = "defs_ubal",
			["syntax"] = "invoke red",
		},
	},
	["apprentice"] = {},
	["capable"] = {},
	["adept"] = {
		["yellow"] = {
			["use"] = "defs_power",
			["syntax"] = "invoke yellow",
		},
	},
	["master"] = {
		["summer"] = {
			["use"] = "cures",
			["syntax"] = "invoke summer",
		},
	},
	["gifted"] = {
		["green"] = {
			["use"] = "cures",
			["syntax"] = "invoke green",
		},
	},
	["expert"] = {
		["blue"] = {
			["use"] = "defs_ubal",
			["syntax"] = "invoke blue",
		},
	},
	["virtuoso"] = {},
	["fabled"] = {
		["indigo"] = {
			["use"] = "defs_ubal",
			["syntax"] = "invoke indigo",
		},
	},
	["mythical"] = {},
	["transcendent"] = {},
}


skills ["bonecrusher"] = {
	["inept"] = {},
	["novice"] = {},
	["apprentice"] = {},
	["capable"] = {},
	["adept"] = {
		["grip"] = {
			["use"] = "defs_ubal",
			["syntax"] = "grip",
		},
		["weaponparry"] = {
			["use"] = "cures",
		},
	},
	["master"] = {},
	["gifted"] = {},
	["expert"] = {},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}


skills ["pureblade"] = {
	["inept"] = {},
	["novice"] = {},
	["apprentice"] = {},
	["capable"] = {},
	["adept"] = {
		["grip"] = {
			["use"] = "defs_ubal",
			["syntax"] = "grip",
		},
		["weaponparry"] = {
			["use"] = "cures",
		},
	},
	["master"] = {},
	["gifted"] = {},
	["expert"] = {},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}


skills ["axelord"] = {
	["inept"] = {},
	["novice"] = {},
	["apprentice"] = {},
	["capable"] = {},
	["adept"] = {
		["grip"] = {
			["use"] = "defs_ubal",
			["syntax"] = "grip",
		},
		["weaponparry"] = {
			["use"] = "cures",
		},
	},
	["master"] = {},
	["gifted"] = {},
	["expert"] = {},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}


skills ["blademaster"] = {
	["inept"] = {},
	["novice"] = {},
	["apprentice"] = {},
	["capable"] = {},
	["adept"] = {
		["grip"] = {
			["use"] = "defs_ubal",
			["syntax"] = "grip",
		},
		["weaponparry"] = {
			["use"] = "cures",
		},
	},
	["master"] = {},
	["gifted"] = {},
	["expert"] = {},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}


skills ["acrobatics"] = { --TRIGgS NOT CODED
	["inept"] = {},
	["novice"] = {
		["limber"] = {
			["use"] = "defs_ubal",
			["syntax"] = "limber",
		},
		["balancing"] = {
			["use"] = "defs_ubal",
			["syntax"] = "balancing on",
		},
		["falling"] = {
			["use"] = "defs_rbal", 
			["syntax"] = "falling",
		},
	},
	["apprentice"] = {
		["elasticity"] = {
			["use"] = "defs_rbal",
			["syntax"] = "elasticity",
		},
		["adroitness"] = {
			["use"] = "defs_free",
			["syntax"] = "adroitness",
		},
	},
	["capable"] = {},
	["adept"] = {
		["springup"] = {
			["use"] = "cures",
			["syntax"] = "springup",
		},
	},
	["master"] = {
		["contort"] = {
			["use"] = "cures",
			["syntax"] = "contort",
		},
	},
	["gifted"] = {},
	["expert"] = {},
	["virtuoso"] = {},
	["fabled"] = {
		["hyperventilate"] = {
			["use"] = "defs_ubal",
			["syntax"] = "hyperventilate",
		},
	},
	["mythical"] = {},
	["transcendent"] = {},
}


skills ["combat"] = {
	["inept"] = {},
	["novice"] = {},
	["apprentice"] = {
		["legs"] = {
			["use"] = "stance",
			["syntax"] = "stance legs",
		},
		["left"] = {
			["use"] = "stance",
			["syntax"] = "stance left",
		},
	},
	["capable"] = {
		["right"] = {
			["use"] = "stance",
			["syntax"] = "stance right",
		},
	},
	["adept"] = {
		["arms"] = {
			["use"] = "stance",
			["syntax"] = "stance arms",
		},
	},
	["master"] = {
		["gut"] = {
			["use"] = "stance",
			["syntax"] = "stance gut",
		},
	},
	["gifted"] = {
		["chest"] = {
			["use"] = "stance",
			["syntax"] = "stance chest",
		},
	},
	["expert"] = {
		["head"] = {
			["use"] = "stance",
			["syntax"] = "stance head",
		},
		["weaponparry"] = {
			["use"] = "cures",
			["syntax"] = "nothing",
		},
	},
	["virtuoso"] = {
		["lower"] = {
			["use"] = "stance",
			["syntax"] = "stance lower",
		},
			--[[uncomment this if you want to use keeneye]]--
		--[[
		["keeneye"] = {
			["use"] = "defs_ubal",
			["syntax"] = "keeneye on",
		},
		--]]
	},
	["fabled"] = {
		["middle"] = {
			["use"] = "stance",
			["syntax"] = "stance middle",
		},
	},
	["mythical"] = {
		["upper"] = {
			["use"] = "stance",
			["syntax"] = "stance upper",
		},
	},
	["transcendent"] = {
		["vitals"] = {
			["use"] = "stance",
			["syntax"] = "stance vitals",
		},
	},
}

skills ["stealth"] = {
	["inept"] = {
		["sneak"] = {
			["use"] = "defs_ubal",
			["syntax"] = "sneak",
		},
	},
	["novice"] = {},
	["apprentice"] = {
		["bracing"] = {
			["use"] = "defs_ubal",
			["syntax"] = "stealth bracing",
		},
	},
	["capable"] = {},
	["adept"] = {},
	["master"] = {
		["agility"] = {
			["use"] = "defs_ubal",
			["syntax"] = "stealth agility",
		},
		["whisper"] = {
			["use"] = "defs_ubal", 
			["syntax"] = "stealth whisper",
		},
	},
	["gifted"] = {},
	["expert"] = {},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {
		["screen"] = {
			["use"] = "defs_ubal",
			["syntax"] = "stealth screen",
		},
	},
	["transcendent"] = {},
}


skills ["kata"] = {
	["inept"] = {},
	["novice"] = {},
	["apprentice"] = {
		["deflect"] = {
			["use"] = "defs_ubal",
			["syntax"] = "ka deflect right",
		},
	},
	["capable"] = {},
	["adept"] = {},
	["master"] = {},
	["gifted"] = {},
	["expert"] = {},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}

skills ["ninjakari"] = {
	["master"] = {},
	["gifted"] = {
		["grip"] = {
			["use"] = "defs_ubal",
			["syntax"] = "grip",
		},
	},
	["expert"] = {},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}

skills ["cosmic"] = {
	["inept"] = {
		["deathsight"] = {
			["use"] = "defs_ubal",
			["syntax"] = "abjure deathsight",},},
	["novice"] = {
		["waterwalk"] = {--20 mana?
			["use"] = "defs_ubal",
			["syntax"] = "abjure waterwalk",},
		["window"] = {
			["use"] = "encha",
			["syntax"] = "abjure window",},},
	["apprentice"] = {},
	["capable"] = {
		["soulwash"] = {--no mana cost
			["use"] = "cures",
			["syntax"] = "abjure soulwash",},
		["web"] = {
			["use"] = "encha",
			["syntax"] = "abjure web",},},
	["adept"] = {
		["cloak"] = {--75 mana
			["use"] = "defs_ubal",
			["syntax"] = "abjure cloak",},},
	["master"] = {
		["timeslip"] = {
			["use"] = "defs_ubal",
			["syntax"] = "abjure timeslip",},},
}

skills ["nihilism"] = {
	["master"] = {
		["wings"] = {--80 mana
			["use"] = "defs_ubal",
			["syntax"] = "darkcall wings",},},
	["gifted"] = {},
	["expert"] = {
		["demonscales"] = {--80 mana
			["use"] = "defs_ubal",
			["syntax"] = "darkcall demonscales",},
		["demoncloak"] = {
			["use"] = "defs_rbal",
			["syntax"] = "darkcall demoncloak on",},},
	["virtuoso"] = {
		["barbedtail"] = {
			["use"] = "defs_ubal",
			["syntax"] = "darkcall barbedtail",},},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}

skills ["rituals"] = {
	["inept"] = {},
	["novice"] = {
		["fortuna"] = {--80 mana
			["use"] = "defs_ubal",
			["syntax"] = "chant fortuna",},},
	["apprentice"] = {
		["draconis"] = {--75 mana
			["use"] = "defs_ubal",
			["syntax"] = "chant draconis",},},
	["capable"] = {
		["populus"] = {--80 mana
			["use"] = "defs_ubal",
			["syntax"] = "chant populus",},},
	["adept"] = {
		["acquisitio"] = {--70 mana
			["use"] = "defs_ubal",
			["syntax"] = "chant acquisitio on",},
		["rubeus"] = {--105 mana?
			["use"] = "defs_ubal",
			["syntax"] = "chant rubeus",},},
	["master"] = {},
}

skills ["necromancy"] = {
	["master"] = {},
	["gifted"] = {},
	["expert"] = {
		["cannibalize"] = {
			["use"] = "cures",
			["syntax"] = "darkchant cannibalize",},},
	["virtuoso"] = {},
	["fabled"] = {},
	["mythical"] = {},
	["transcendent"] = {},
}

skills ["highmagic"] = {
	["inept"] = {
		["pentagram"] = {--30 mana
			["use"] = "shield",
			["syntax"] = "evoke pentagram",},},
	["novice"] = {
		["malkuth"] = {--100 mana
			["use"] = "defs_ubal",
			["syntax"] = "evoke malkuth",	},	},
	["apprentice"] = {},
	["capable"] = {
		["shroud"] = {--50 mana
			["use"] = "defs_ubal",
			["syntax"] = "evoke yesod",},	
		["netzach"] = {--200 mana
			["use"] = "defs_ubal",
			["syntax"] = "evoke netzach",	},},
	["adept"] = {},
	["master"] = {
		["tipheret"] = {--50 mana
			["use"] = "cures",
			["syntax"] = "evoke tipheret",},},
	["gifted"] = {
		["hexagram"] = {
			["use"] = "cures",
			["syntax"] = "evoke hexagram",},},
	["expert"] = {},
	["virtuoso"] = {
		["geburah"] = {--80 mana
			["use"] = "cures",
			["syntax"] = "evoke geburah",	},},
	["fabled"] = {
		["chockmah"] = {
			["use"] = "defs_ubal",
			["syntax"] = "evoke chockmah",},},
	["mythical"] = {},
	["transcendent"] = {},
}

		
skills:init ()

		
return skills