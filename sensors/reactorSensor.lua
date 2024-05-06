local reactorSensor = {}

function reactorSensor.getData()
    r = peripheral.find("Reactor Logic Adapter")
	if not r then
		error("Reactor Logic Adapter not found.",0)
	end

    re = r.getProducing()
    rev = math.modf(re)
    -- rep = (re/1000000000)
    -- repv = math.modf(rep)

    rch = r.getCaseHeat()/1000000 -- in MK
    rchv = math.modf(rch)
    rph = r.getPlasmaHeat()/1000000 -- in MK
    rphv = math.modf(rph)


    ri = r.isIgnited()


    rd = {re=re,rev=rev, rch=rch,rchv=rchv,rph=rph,rphv=rphv, ri=ri}
    
    return md
end

return reactorSensor
