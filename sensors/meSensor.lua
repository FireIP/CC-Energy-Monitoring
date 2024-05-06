local meSensor = {}

function meSensor.getData()
    m = peripheral.find("meBridge")
    if not m then
	    error("ME Bridge not found.",0)
    end
    
    me = m.getEnergyStorage()
    memax = m.getMaxEnergyStorage()
    mev = math.modf(me)
    mep = (me/memax)*100
    mepv = math.modf(mep)

    mu = m.getEnergyUsage()
    mtls = me/(mu*20)
    mtlsv = math.modf(mtls)
    mtlmm = mtls/60
    mtlmmv = math.modf(mtlmm)
    mtlms = math.fmod(mtls,60)
    mtlmsv = math.modf(mtlms)

    mncel = #m.listCells()
    mntype = #m.listItems()
    mtyp = math.ceil(((mncel*63)/mntype)*1000)/10
    mtis = m.getTotalItemStorage()
    mnitm = m.getUsedItemStorage()
    minp = math.ceil((mtis/mnitm)*1000)/10

    md = {me=me,mev=mev,mep=mep,mepv=mepv, mu=mu,mtls=mtls,mtlsv=mtlsv,mtlmm=mtlmm,mtlmmv=mtlmmv,mtlms=mtlms,mtlmsv=mtlmsv, mncel=mncel,mntype=mntype,mtyp=mtyp,mtis=mtis,mnitm=mnitm,minp=minp}
    return md
end

return meSensor
