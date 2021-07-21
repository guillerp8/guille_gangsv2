ESX = nil 

Citizen.CreateThread(function() 
    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 
        Citizen.Wait(0) 
    end
    getPoints()
end)

function log(txt)
    if txt then
        print("^2[guille_gangsv2]^8 " ..txt)
    else
        print("^2[guille_gangsv2]^8 Attempting to print a nil value")
    end
end

