local modem = component.proxy(component.list("modem")())
local eeprom = component.proxy(component.list("eeprom")())

modem.open(9999)
modem.send("MODEM_ADDRESS", 9999, eeprom.getData())
local code, left = "", 0
repeat
    local evt, _, _, _, _, message, chunksLeft = computer.pullSignal(1000)
    if evt == "modem_message" then
        code = code .. message
        left = chunksLeft
    end
until left == 0
local l, err = load(code)
if l then pcall(l) end
