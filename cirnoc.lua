-- The strongest C interpreter


-- What this does is load the given file and strip all the preprocessor directives.

local function loadfile(filename)
	local file = io.open(filename, "r")
	if not file then
		print("Could not open file: " .. filename)
	end

	local lines = {}
	for line in file:lines() do
		local trimmed = line:match("^%s*(.-)%s*$")
		if not trimmed:match("^#") then
			table.insert(lines, line)
		end
	end
	file:close()

	return table.concat(lines, "\n")
end

-- Extract the body of main()

local function extractmainbody(source)
	local startpos = source:find("main%s*%([^)]*%)%s*{")
	if not startpos then
		error("Could not find main()")
	end

	local bracestart = source:find("{", startpos)
	local depth = 0
	local i = bracestart

	while i <= #source do
		local c = source:sub(i, i)
		if c == "{" then depth = depth + 1
		elseif c == "}" then
			depth = depth - 1
			if depth == 0 then
				return source:sub(bracestart + 1, i - 1)
			end
		end
		i = i + 1
	end

	error("Unbalanced braces in main()")
end

-- Turning C statements into Lua ones
local function interpret(body)
	for stmt in body:gmatch("[^;]+;?") do
		local arg = stmt:match('printf%s*%(%s*"(.-)"%s*%)')
		if arg then
			-- turn C escapes into Lua ones
			arg = arg:gsub("\\n", "\n")
			arg = arg:gsub("\\t", "\t")
			io.write(arg)
		end
	end
end

-- Run it
local filename = arg[1]
if not filename then
	print("Usage: lua cirnoc.lua <file>")
	print("you baka") -- KEKW - vmunix
end

local source = loadfile(filename)
local body = extractmainbody(source)
interpret(body)
