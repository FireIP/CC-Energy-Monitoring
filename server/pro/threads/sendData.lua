--[[Server-OS/sendData by FireIP
	Version 0.3
	for Server-OS(v0.3.2)
	Changes: temp removed reactor
	]]

	args = ...
	ch = tonumber(args)
	
	term.clear()
	term.setCursorPos(1,1)
	print("sendData (v0.2)")
	print("Sending data on port: " .. ch)
	
	--Functions
	
	function sendData(cha)
		print("Sending data.")
		while true do
			-- Handling the ME-System
			me = m.getNetworkEnergyStored()
			mev = math.modf(me)
			mep = (me/1820000)*100
			mepv = math.modf(mep)
	
			mu = m.getNetworkEnergyUsage()
			mtls = me/(mu*20)
			mtlsv = math.modf(mtls)
			mtlmm = mtls/60
			mtlmmv = math.modf(mtlmm)
			mtlms = math.fmod(mtls,60)
			mtlmsv = math.modf(mtlms)
	
			md = {me=me,mev=mev,mep=mep,mepv=mepv, mu=mu,mtls=mtls,mtlsv=mtlsv,mtlmm=mtlmm,mtlmmv=mtlmmv,mtlms=mtlms,mtlmsv=mtlmsv}

			-- Handling the Reactor
			re = l.getProducing()
			rev = math.modf(re)
			-- rep = (re/1000000000)
			-- repv = math.modf(rep)

			rch = l.getCaseHeat()/1000000 -- in MK
			rchv = math.modf(rch)
			rph = l.getPlasmaHeat()/1000000 -- in MK
			rphv = math.modf(rph)


			ri = l.isIgnited()


			rd = {re=re,rev=rev, rch=rch,rchv=rchv,rph=rph,rphv=rphv, ri=ri}


			
			D = {"data", ME=md, R=rd}
	
			a.transmit(cha,20,D)
		end
	end
	
	--Programm stuff
	
	
	
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
	
	l = peripheral.find("Reactor Logic Adapter")
	if not l then
		error("Reactor Logic Adapter not found.",0)
	end
	
	while true do
		sendData(ch)
	end