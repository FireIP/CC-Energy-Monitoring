function getData()
    me = peripheral.find("meBridge")
    if not me then
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

    md = {me=me,mev=mev,mep=mep,mepv=mepv, mu=mu,mtls=mtls,mtlsv=mtlsv,mtlmm=mtlmm,mtlmmv=mtlmmv,mtlms=mtlms,mtlmsv=mtlmsv}
    
    return md
end