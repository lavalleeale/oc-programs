local modem = component.proxy(component.list("modem")())
local eeprom = component.proxy(component.list("eeprom")())

modem.open(9999)
modem.send("MODEM_ADDRESS", 9999, eeprom.getLabel())
local evt, _, _, _, _, message = computer.pullSignal(1)
if evt == "modem_message" then
    local l, err = load(message)
    if l then pcall(l) end
end
