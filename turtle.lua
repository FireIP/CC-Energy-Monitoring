function doCheck()
    turtle.up()
    turtle.turnRight()
    turtle.forward()
    doRow()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnLeft()
    doRow()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnRight()
    turtle.forward()
    turtle.turnRight()
    turtle.down()
    park()
end

function abort()
    park()
end

function storeStar()
    for i = 9, 15, 1 do
        if turtle.getItemSpace(i) >= turtle.getItemCount(16) then
            turtle.transferTo(i)
            return true
        end
    end
    return false
end

function dropStar()
    for i = 9, 15, 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtle.dropDown(1)
            return true
        end
    end
    return false
end

function doRow()
    for i = 1, 3, 1 do
        turtle.select(16)
        turtle.suckDown()
        star = turtle.getItemDetail()
        if star then
            if star.name == "mythicbotany:faded_nether_star" then
                turtle.dropDown()
            elseif star.name == "minecraft:nether_star" then
                storeStar()
            else
                turtle.dropDown()
                abort()
                return false
            end
        else
            dropStar()
        end
        if i ~= 3 then
            turtle.forward()
        end
    end
    return true
end

function doRefuel()
    for i = 1, 8, 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtle.refuel()
            return true
        end
    end
    return false
end

function park()
    if turtle.getFuelLevel() < turtle.getFuelLimit() - 1000 then
        doRefuel()
    end
    select(16)
end

while true do
    if ~doCheck() then
        return
    end
    sleep(60)
end