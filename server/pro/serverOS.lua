--[[Server-OS by FireIP
	Version 0.4
	Changes: switch to sensors
	]]


term.clear()
term.setCursorPos(1,1)
print("Server-OS (v0.4)")

print("Initialising [...]")

startActListSensCh = 100
startActRetSensCh = 500

defSensListen = 18
defSensAns = 19
sensCount = 0

handleCounter = 0

modCount = 2
availSens = {modCount}

data = {ME=nil, R=nil}
dataFilePath = "/pro/data.txt"

--Functions

function syncSensor(rc, newListen, newRc)
	syncD = {"sensConf", backoff=(0.125*sensCount), servC=newListen, recC=newRc, numM=modCount}
	a.transmit(rc, newListen ,syncD)
	sync = true
	timeout = os.startTimer(5)
	while sync do
		event = {os.pullEvent()}
		if event[1] == "modem_message" then
			if event[5] == "switching" then
				sensCount = sensCount + 1
				sync = false

			elseif event[5] == "sensorData" then
				recDa = event[5]
				if recDa.modList[1] then
					data.ME = recDa.ME
				end
				if recDa.modList[2] then
					data.R = recDa.R
				end
				datFile.write(textutils.serialise(data))
				sync = false
			end
			
			os.cancelTimer(timeout)
		elseif event[1] == "timer" and event[2] == timeout then
			print("Sensor did not switch channel")
			sync = false
		end
	end

end

function handelSensor(rc, inCh)
	handleCounter = handleCounter + 1
	syncSensor(rc, inCh, rc)

	if handleCounter > 20000 then
		sensCount = 0
	end
end

function handelNewSensor(rc)
	syncSensor(rc, startActListSensCh + sensCount, startActRetSensCh + sensCount)
end

function listen()
	while listening do
		event = {os.pullEvent("modem_message")}
		if event[5] == "ping" then
			print("Recived a ping!")

			rc = event[4]
			a.transmit(rc,20,"listening")
			event = {os.pullEvent("modem_message")}
			if event[5] == "copy" then
				print("Connected!")

				if event[3] == 20 then
					shell.openTab("/pro/threads/sendData.lua", rc)
				elseif event[3] == 18 then
					handleNewSensor(rc)
				else
					if sensCount ~= 0 or sensCount >= 80 then
						handelSensor(rc, event[3])
					else
						sensCount = 0
						handelNewSensor(rc)
					end
				end
			end
		end
	end
end

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
a.open(defSensListen)

datFile = fs.open(dataFilePath, "w")

term.setCursorPos(1,2)
term.clearLine()
print("Initialising [done]")

while true do
	connect()
end