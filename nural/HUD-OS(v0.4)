--[[HUD-OS by FireIP
	Version 0.4
	Changes:
		code cleanup]]


term.clear()
term.setCursorPos(1,1)
print("HUD-OS(v0.4)")

print("Startup [1/1]")

--Functions

function connect()
	print("Pinging...")
	ping = true

	local timeout = os.startTimer(1)
	while ping do
		a.transmit(20,recC,"ping")
		pEvent = {os.pullEvent()}

		if pEvent[1] == "modem_message" then
	
			if pEvent[5] == "listening" then
				print("Recieved answer!")
	
				a.transmit(20,recC,"copy")
				rec = true

				recieveData()
			
			end

			timeout = os.startTimer(1)
			
		elseif pEvent[1] == "timer" and pEvent[2] == timeout then
			timeout = os.startTimer(1)
		end

	end

end

function recieveData()
	while rec do
		mess = {os.pullEvent()}
		if mess[1] == "modem_message" then
			if mess[5][1] == "data" then
				print("Recieving data!")

				--rec = false
				-- Handling ME-Data
				D = mess[5]
				bstr = "ME-System: " .. D.ME.mev .. " AE" .. " (" .. D.ME.mepv .. "%)" .. " (" .. D.ME.mtlmmv .. "m " .. D.ME.mtlmsv .. "s)"
				metx.setText(bstr)
				if D.ME.mep <= 75 then
					metx.setColor(255,45,0)
				else
					metx.setColor(-1)
				end

				-- Handling Reactor Data
				if D.R.ri then
					rs = "active"
				else
					rs = "inactive"
				end

				bstr = "FR_1: " .. D.R.rev .. " EU/t" .. " (" .. rs .. ")" .. " (CH: " .. D.R.rchv .. " MK" .. " PH: " .. D.R.rphv .. " MK)"
				rtx.setText(bstr)
			end
		end
	end
end

--Programm stuff

rec = false
recC = 22

mod = peripheral.find("neuralInterface")
if not mod then
	error("Not on neural interface.",0)
end

can = mod.canvas()
can.clear()
headl = can.addText({4,3},"Energy:",-1,0.6)
metx = can.addText({4,9},"connecting...",-1,0.55)
rtx = can.addText({4,15},"loading...",-1,0.55)

a = peripheral.find("modem")
if not a then
	error("Wireless modem not found.",0)
end
a.open(recC)

term.getCursorPos(1,2)
term.clearLine()
print("Running...")

while true do
	connect()
end