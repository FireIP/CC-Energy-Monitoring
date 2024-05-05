--[[Server-OS by FireIP
	Version 0.3.2
	Changes: temp removed reactor
	]]


term.clear()
term.setCursorPos(1,1)
print("Server-OS (v0.3.2)")

print("Startup [1/3]")
print("Initialising [...]")

--Functions

function connect()
	while listening do
		print("Listening...")
		event = {os.pullEvent("modem_message")}
		if event[5] == "ping" then
			print("Recived a ping!")

			rc = event[4]
			a.transmit(rc,20,"listening")
			event = {os.pullEvent("modem_message")}
			if event[5] == "copy" then
				print("Connected!")
				shell.openTab("/pro/threads/sendData.lua", rc)
			end

		end
	end
end


--Programm stuff

listening = true

a = peripheral.find("modem")
if not a then
	error("Wireless modem not found.",0)
end
a.closeAll()
a.open(20)

m = peripheral.find("meBridge")
if not m then
	error("ME Bridge not found.",0)
end

term.setCursorPos(1,3)
term.clearLine()
print("Initialising [done]")

while true do
	connect()
end