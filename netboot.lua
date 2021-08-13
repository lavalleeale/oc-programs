local component = require "component"
local computer = require("computer")
local event = require "event"
local io = require "io"
local os = require "os"
local modem = component.modem

local path = "/home/programs/bin/"
local libpath = "/home/programs/lib/"
local file = io.open("bios.lua", "r")
local bios = file:read("a")
bios = bios:gsub("MODEM_ADDRESS", modem.address)

local args = {...}
if args[1] == "flash" then
    local eeprom = component.eeprom
    eeprom.set(bios)
    eeprom.setLabel("Netboot file: " .. args[2])
    eeprom.setData(args[2])
end

local function escape_pattern(text) return text:gsub("%%", "%%%%") end

local function resolveLibs(contents)
    if contents:match("require%(\".-\"%)") then
        local matches = contents:gmatch("require%(\"(.-)\"%)")
        for match in matches do
            local lib = io.open(libpath .. match .. ".lua", "r")
            if lib ~= nil then
                local libcontents = resolveLibs(lib:read("a"))
                lib:close()
                libcontents = escape_pattern(libcontents)
                contents = contents:gsub("require%(\"" .. match .. "\"%)",
                                         "(function()" .. libcontents ..
                                             " end)()", 1)
            end
        end
    end
    return contents
end

local function splitByChunk(text, chunkSize)
    local s = {}
    for i = 1, #text, chunkSize do s[#s + 1] = text:sub(i, i + chunkSize - 1) end
    return s
end

print("Starting server")

modem.open(9999)
while true do
    local _, _, from, port, _, message = event.pull("modem_message")
    local file = io.open(path .. message, "r")
    if file == nil then
        print("Client requested nonexistant file: " .. message)
    else
        print("Client requested file: " .. message)
        local contents = file:read("a")
        file:close()
        local withLibs = resolveLibs(contents)
        local toSend = withLibs:gsub("[\t]", "")
        local chunks = splitByChunk(toSend,
                                    computer.getDeviceInfo()[modem.address]
                                        .capacity - 12)
        for index, value in ipairs(chunks) do
            modem.send(from, port, value,
                       math.ceil(
                           #toSend /
                               (computer.getDeviceInfo()[modem.address].capacity -
                                   12)) - index)
        end
    end
end
