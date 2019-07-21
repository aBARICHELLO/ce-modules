local u = require "ce-modules/utils"

-- Module used to abstract some operations using Cheat Engine's API
local asm = {}

-- Table that constains all addresses of memory allocations made by cheat engine
-- Key: code cave symbol / Value: address of allocated memory
local memoryAddresses = {}
local SIZE = 0x1000 -- Default allocated memory (4Kb)

-- Execute a simple .asm script, the section to be executed is
-- determined by info.enable
function asm.execute(info)
    u.log("Executing script " .. info.scriptName .. " : " .. tostring(info.enable))
    local script = u.extractSection(info.asmPath, info.enable)
    autoAssemble(script)
end

-- Code cave related functions

-- Allocs memory inside the process, registers necessary user defined symbols
-- and executes the assembly script to create the code cave.
function asm.createCodeCave(info)
    u.log("Enabling script " .. info.asmPath)

    local caveSymbol = info.symbolPrefix .. "_cave"
    local addressSymbol = info.symbolPrefix .. "_entry"

    unregisterSymbol(caveSymbol)
    unregisterSymbol(addressSymbol)

    registerSymbol(addressSymbol, info.address)
    local caveMemAddress = allocateMemory(SIZE)
    registerSymbol(caveSymbol, caveMemAddress)
    memoryAddresses[caveSymbol] = caveMemAddress

    autoAssemble(u.open(info.asmPath))
end

-- Unregisters all user defined symbols on enable.
-- Frees memory used in code cave.
function asm.destroyCodeCave(info)
    u.log("Disabling script " .. info.symbolPrefix)

    local caveSymbol = info.symbolPrefix .. "_cave"
    local addressSymbol = info.symbolPrefix .. "_entry"

    writeBytes(info.address, info.bytes)
    unregisterSymbol(caveSymbol)
    unregisterSymbol(addressSymbol)

    local caveMemAddress = memoryAddresses[caveSymbol]
    deAlloc(caveMemAddress, SIZE)
    memoryAddresses[caveSymbol] = nil
end

return asm
