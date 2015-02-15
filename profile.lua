--[[

profile.lua

Written by Nick Gammon
Date: 15th May 2010

Designed to do function profiling of various inbuilt functions, such as the ones in the 
world table, and various other ones like sqlite3, progress, etc.

To use:

require "profile" 

This will replace all functions in the tables WANTED_TABLES (below) with "stub" functions
that will time how many times they are called, and for how long, using the high-precision
timer (accessed by GetInfo (232)).

To access the results, simply look up the contents of the profile table (which is a local variable
below) or use this alias:

<aliases>
 <alias
   match="profile"
   enabled="y"
   sequence="100"
   script="show_profile"
  >
 </alias>  
</aliases>
  


--]]


-- set up profiling

local profile = {}
local myGetInfo = GetInfo -- make local for speed and efficiency

local WANTED_TABLES = {-- "world",
						"utils", "bit", 
                        "sqlite3", "progress", "rex", 
                        "io", "lpeg", "able", "act", "affs", "bals", "defs",
						"display", "flags", "fst", "magic", "nocure", "parry",
						"pipes", "prompt", "skills", "stance", "wounds", "scan",} 
                       
-- stub function to profile an existing function

local function make_profile_func (fname, f)
  local t = { elapsed = 0, count = 0 }
  profile [fname] = t
 
  -- this is the replacement function
  return function (...)
     t.count = t.count + 1          -- invocations
     local start = myGetInfo (232)  -- high-precision timer
     local results = { f (...) }    -- call original function
     t.elapsed = t.elapsed + myGetInfo (232) - start  -- time taken
     return unpack (results)   
  end -- function
end -- make_profile_func

-- replace world functions by profiling stub function

local max_name_length = 0

for _, tbl in ipairs (WANTED_TABLES) do
  for k, f in pairs (_G [tbl] ) do
    if type (f) == "function" then
      local name = tbl .. "." .. k
      if tbl == "world" then
        name = k
      end -- if
      max_name_length = math.max (max_name_length, #name)
      _G [tbl] [k] = make_profile_func (name, f)
    end -- if
  end -- for
end -- for each wanted table

require "pairsbykeys"

-- show profile, called by alias

function show_profile (name, line, wildcards)

  local function heading (s)
    print (string.rep ("-", 20), "Function profile - " .. s .. " order", string.rep ("-", 20))
    print ""
    print (string.format ("%" .. max_name_length .. "s %12s %12s %12s", 
           "Function", "Count", "Seconds", "Average"))
    print ""
  end -- heading
  
  heading "alpha"
  for k, v in pairsByKeys (profile) do
    if v.count > 0 then
      print (string.format ("%" .. max_name_length .. "s %12i %12.4f %12.6f", 
             k, v.count, v.elapsed, v.elapsed / v.count))
    end -- if
  end -- for
  print ""
  
  local t = {}
  for k, v in pairs (profile) do
    if v.count > 0 then
      table.insert (t, k)
    end -- if used
  end -- for
  
  -- sort into descending order by elapsed time
  table.sort (t, function (a, b) return profile [a].elapsed > profile [b].elapsed end )
  
  heading "time"
  for _, k in ipairs (t) do
      print (string.format ("%" .. max_name_length .. "s %12i %12.4f %12.6f", 
             k, profile [k].count, profile [k].elapsed, profile [k].elapsed / profile [k].count))
  end -- for
  print ""
  
end -- show_profile