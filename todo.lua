--[[
		QUEUE FOR MISC ACTIONS
		
]]--


require "fst"
require "flags"
require "bals"
--require "system"


if not todo then
	todo = {
		["free"] = {},
		["bal"] = {},
	}
end --if


function todo:reset (silent)

	todo ["free"] = {}
	todo ["bal"] = {}

	if not silent then
		display.system ("Todo RESET")
	end --if
	
end --function
	
	
function todo:to_do (ctg)

	if affs:has ("blackout") then
		return
	end--if
	
	if ctg == "free" then
		return next (self [ctg]) and not flags:get ("todo_free")
	else
		return bals:has ("bal") and bals:has ("eq") and not affs:is_prone () and next (self [ctg]) and not flags:get ("todo_bal")
	end --if
	
end --function


function todo:scan (ctg)--to be called ONLY after a todo:to_do (ctg)

	flags:add ("todo_"..ctg, todo [ctg] [1] ["id"])
	if ctg == "bal" then
		flags:add ("bal")
	end--if
	fst:enable ("todo_"..ctg)
	
	act:queue (todo [ctg] [1] ["syntax"])
	
end --function


function todo:add (ctg, id, syntax, priority, duplicate)

	local tag ={
		["id"] = id,
		["syntax"] = syntax,
	}
	if not duplicate then
		for k, v in ipairs (self [ctg]) do
			if self [ctg] [k] ["id"] == id then
				table.remove (self [ctg], k)
				break
			end --if
		end --for
	end --if
	
	table.insert (self [ctg], (priority or #self [ctg]+1), tag)
		
end --function


function todo:is_queued (id, ctg)

	if not next (self ["bal"]) and not next (self ["free"]) then
		return false
	end --if
	
	if ctg then
		for k, v in ipairs (self [ctg]) do
			if v ["id"] == id then
				return v ["syntax"]
			end --if
		end --for
		return false
	end
	
	for k, v in ipairs (self ["free"]) do
		if v ["id"] == id then
			return true
		end --if
	end --for
	
	for k, v in ipairs (self ["bal"]) do
		if v ["id"] == id then
			return true
		end --if
	end --for
	
	return false
	
end --if


function todo:done (id, ctg)

	id = string.gsub (id, " ", "_")
	if ctg then
		for k, v in ipairs (todo [ctg]) do
			if todo [ctg] [k] ["id"] == id then
				table.remove (todo [ctg], k)
				fst:disable ("todo_"..ctg)
				flags:del ("todo_"..ctg)
				if ctg == "bal" then
					flags:del ("bal")
				end --if
				return
			end --if
		end --for
	end --if
	
	for k, v in ipairs (todo ["free"]) do
		if todo ["free"] [k] ["id"] == id then
			table.remove (todo ["free"], k)
			fst:disable ("todo_free")
			flags:del ("todo_free")
			return
		end --if
	end --for

	for k, v in ipairs (todo ["bal"]) do
		if todo ["bal"] [k] ["id"] == id then
			table.remove (todo ["bal"], k)
			fst:disable ("todo_bal")
			flags:del ({"todo_bal", "bal"})
			return
		end --if
	end --for
	
end --function





