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
	 if not a.isOpen(newListen) then
	  a.open(newListen)
	 end
	 
		sync = true
		timeout = os.startTimer(5)
		while sync do
	  print("listen for data / switch")
			event = {os.pullEvent()}
	  print(event[1])
			if event[1] == "modem_message" then
				if event[5] == "switching" then
					sensCount = sensCount + 1
					sync = false
		print("switched!")
	
				elseif event[5][1] == "sensorData" then
		print("recieving Data")
					recDa = event[5]
					if recDa.modList[1] then
						data.ME = recDa.ME
					end
					if recDa.modList[2] then
						data.R = recDa.R
					end
		print("writing")
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
	 print("handle old sens")
		handleCounter = handleCounter + 1
		syncSensor(rc, inCh, rc)
	
		if handleCounter > 20000 then
			sensCount = -1
		end
	end
	
	function handelNewSensor(rc)
	 newListCh = startActListSensCh + sensCount
	 newRecCh = startActRetSensCh + sensCount
		syncSensor(rc, newListCh, newRecCh)
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
					--print("Connected!")
	
					if event[3] == 20 then
		 print("Connected to pocket!")
						shell.openTab("/pro/threads/sendData.lua", rc)
					elseif event[3] == 18 then
		 print("Connected to New Sensor!")
						handelNewSensor(rc)
					else
		 print("Connected to old Sensor!")
						if sensCount > -1 and sensCount <= 80 then
							handelSensor(rc, event[3])
						else
		  print("resetting sensor")
							sensCount = -1
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
		listen()
	end
	