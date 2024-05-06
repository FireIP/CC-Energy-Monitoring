--[[SensorBase by FireIP
	Version 0.1
	Changes: init
	]]


term.clear()
term.setCursorPos(1,1)
print("Sensor v0.1")

print("Startup [0/3]")

servC = 18
recC = 19
backoff = 1

function getModules(l)
    l[1] = fs.exists("/pro/sensor/modules/meSensor.lua")
    l[2] = fs.exists("/pro/sensor/modules/reacrorSensor.lua")

    for i = 3, #l, 1 do
        l[i] = false
    end
end

function connect()
    print("Pinging...")
    ping = true
    
    --TODO: Encryption and Identifiacation
    
    local timeout = os.startTimer(10)
    while ping do
        sleep(backoff)
        a.transmit(servC, recC, "ping")
        pEvent = {os.pullEvent()}
    

        if pEvent[1] == "modem_message" then
    
            if pEvent[5] == "listening" then
                print("Recieved answer!")
    
                a.transmit(servC, recC, "copy")
                rec = true
                os.cancelTimer(timeout)

                rxTx()
            end
            
        elseif pEvent[1] == "timer" and pEvent[2] == timeout then
            print("Ping timedout")
            timeout = os.startTimer(10)
        end
    end
end

function rxTx()
    mess = os.pullEvent()
    if mess[1] == "modem_message" then
        if mess[5][1] == "sensConf" then
            print("Syncing...")

            -- Handling Sync data
            syncD = mess[5]

            backoff = syncD.backoff

            if servC ~= syncD.servC or recC ~= syncD.recC then
                ping = false
                a.transmit(servC, recC, "switching")

                servC = syncD.servC
                recC = syncD.recC
                print("Switching channel")
                return
            end
            
            numModules = syncD.numM
            
            modules = getModules({numModules})
            -----------------

            --Send data
            if modules[1] then
                local meSensor require "/pro/sensor/modules/meSensor.lua" 
                md = meSensor.getData()
            else
                md = nil
            end

            if modules[2] then
                local reactorSensor require "/pro/sensor/modules/reacrorSensor.lua" 
                rd = reactorSensor.getData()
            else
                rd = nil
            end

            D = {"sensorData", modList=modules, ME=md, R=rd}
            a.transmit(servC, recC, D)

        end
    end
end

term.setCursorPos(1,2)
term.clearLine()
print("Initialising [1/3]")

a = peripheral.find("modem")
if not a then
error("Wireless modem not found.",0)
end
a.closeAll()
a.open(recC)

term.setCursorPos(1,2)
term.clearLine()
print("Initialising [2/3]")

while true do
    connect()
    a.closeAll()
    a.open(recC)
end