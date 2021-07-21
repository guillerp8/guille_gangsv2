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

TriggerEvent("chat:addSuggestion", "/setgang", ("Set gang user"), {{name = ("Id"), help = ("Player ID")}, {name = ("Gang"), help = ("Name of the gang")}, {name = ("Rank"), help = ("Rank to set")}})
TriggerEvent("chat:addSuggestion", "/setgangmember", ("Set gang user if you are boss"), {{name = ("Id"), help = ("Player ID")}, {name = ("Rank"), help = ("Name of the gang")}})
TriggerEvent("chat:addSuggestion", "/creategang", ("Create a gang"), {})
TriggerEvent("chat:addSuggestion", "/modifygangs", ("Modify gangs"), {})
