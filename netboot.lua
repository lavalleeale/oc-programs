local component = require "component"
local event = require "event"
local fs = require "filesystem"
local io = require "io"
local modem = component.modem

local path = "/home/programs/"
local files = fs.list(path)
local file = io.open("bios.lua", "r")
local bios = file:read("a")
bios = bios:gsub("MODEM_ADDRESS", modem.address)

local function waitForInsertion(name)
    io.write("Program " .. name .. "? [Y/n] ")
    if ((io.read() or "n") .. "y"):match("^%s*[Yy]") then
        print("Insert eeprom for " .. name)
        repeat os.sleep(1) until pcall(function()
            assert(component.eeprom, "")
        end)
        return true
    end
    return false
end

io.write("Program eeproms? [Y/n] ")
if ((io.read() or "n") .. "y"):match("^%s*[Yy]") then
    local eeprom = component.eeprom
    for name in files do
        if waitForInsertion(name) then
            eeprom = component.eeprom
            eeprom.set(bios)
            eeprom.setLabel(name)
        end
    end
end

print("Starting server")

modem.open(9999)
while true do
    local _, _, from, port, _, message = event.pull("modem_message")
    print("sending " .. message)
    local file = io.open(path .. message, "r")
    modem.send(from, port, file:read("a"))
end
