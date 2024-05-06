--[[Server-OS/sendData by FireIP
	Version 0.4
	for Server-OS(v0.4)
	Changes: temp removed reactor
	]]

	args = ...
	ch = tonumber(args)

	dataFilePath = "/pro/data.txt"
	
	term.clear()
	term.setCursorPos(1,1)
	print("sendData (v0.4)")
	print("Sending data on port: " .. ch)
	
	--Functions
	
	function sendData(cha)
		print("Sending data.")
		while true do
			
			D = getData()
	
			a.transmit(cha,20,D)
			sleep(0.25)
		end
	end

	function getData()
		data = textutils.unserialize(datFile.readAll())
		md = data.ME
		rf = data.R
		D = {"data", ME=md, R=rd}
		return D
	end
	
	--Programm stuff
	
	
	
	a = peripheral.find("modem")
	if not a then
		error("Wireless modem not found.",0)
	end
	a.closeAll()
	a.open(20)
	
	datFile = fs.open(dataFilePath, "r")

	while true do
		sendData(ch)
	end
