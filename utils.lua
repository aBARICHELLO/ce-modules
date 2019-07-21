-- Auxiliary module for IO/Logging functions
local u = {}

function u.log(message)
    print("--> asm.lua: " .. message)
end

function u.syntaxCheck(script)
    local error, message = autoAssembleCheck(script)
    if not error then
        u.log("Syntax error found in autoassembler script.\n" .. message)
        return ""
    end
    return script
end

-- Open Cheat Engine's auto assemble(.asm) scripts and return contents as a string
function u.open(path)
    local file = io.open(path, "r")
    if file == nil then
        u.log("Couldn't find file!")
        return
    end
    local script = file:read("*all")
    file:close()
    return u.syntaxCheck(script)
end

-- Parse a .asm file, return only the section
-- [enable] if enable otherwise returns [disable] section
function u.extractSection(path, enable)
    local key = {start = nil, stop = nil}
    if enable then
        key.start = "[ENABLE]"
        key.stop = "[DISABLE]"
    else
        key.start = "[DISABLE]"
        key.stop = "[ENABLE]"
    end

    local script = ""
    local appendFlag = false
    for line in io.lines(path) do
        if line == key.start then
            appendFlag = true
        elseif line == key.stop then
            appendFlag = false
        elseif appendFlag then
            script = script .. line .. "\n"
        end
    end
    return u.syntaxCheck(script)
end

return u
