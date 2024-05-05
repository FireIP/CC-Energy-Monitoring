--[[Pocket-OS by FireIP
	Version 0.2
	Changes:
		handel nil data]]


term.clear()
term.setCursorPos(1,1)
print("Pocket-OS(v0.2)")

print("Startup [0/2]")

--Functions

function connect()
	print("Pinging...")
	ping = true
 
 --TODO: Encryption and Identifiacation
 
	local timeout = os.startTimer(1)
	while ping do
		a.transmit(20,recC,"ping")
		pEvent = {os.pullEvent()}

		if pEvent[1] == "modem_message" then
	
			if pEvent[5] == "listening" then
				--print("Recieved answer!")
	
				a.transmit(20,recC,"copy")
				rec = true
				os.cancelTimer(timeout)

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
				term.setCursorPos(1,2)
				term.clearLine()
				print("Running...")

				--rec = false
				-- Handling ME-Data
				D = mess[5]

				if D.ME then
					bstr = "ME-System: " .. D.ME.mev .. " AE" .. " (" .. D.ME.mepv .. "%)" .. " (" .. D.ME.mtlmmv .. "m " .. D.ME.mtlmsv .. "s)"
				
					if D.ME.mep <= 75 then
						term.setTextColour(colors.red)
					else
						term.setTextColour(colors.white)
					end
					term.setCursorPos(1,2)
					term.clearLine()
				else
					bstr = "ME-System: " .. n/a
				end
				print(bstr)
				term.setTextColour(colors.white)

				if D.R then
					if D.R.ri then
						rs = "active"
					else
						rs = "inactive"
					end

					bstr = "FR_1: " .. D.R.rev .. " EU/t" .. " (" .. rs .. ")" .. " (CH: " .. D.R.rchv .. " MK" .. " PH: " .. D.R.rphv .. " MK)"
					term.setCursorPos(1,3)
					term.clearLine()
				else
					bstr = "FR_1: " .. n/a
				end
				print(bstr)
			end
		end
	end
end

term.setCursorPos(1,2)
term.clearLine()
print("Startup [1/2]")

--Programm stuff

rec = false
recC = 22

a = peripheral.find("modem")
if not a then
	error("Wireless modem not found.",0)
end
a.open(recC)

term.setCursorPos(1,2)
term.clearLine()
print("Startup [2/2]")
sleep(0.25)

while true do
	connect()
end
