ESX.RegisterServerCallback('guille_gangs:server:getGangs', function(source,cb) 
    cb(gangs)
end)


RegisterServerEvent("guille_gangs:server:removeGangMember")
AddEventHandler("guille_gangs:server:removeGangMember", function(steam, gang, OboWombo)
    local _src = source
    if isAllowed(_src) or OboWombo then
        local plygang = players[steam].Player().getGang()
        if plygang then
            local actgang = gangs[plygang].gangActions()
            actgang.removeMember(steam, false, OboWombo, function(result)
                if result and not OboWombo then
                    TriggerClientEvent("guille_gangs:client:continueEditing", _src, gang)
                end
            end)
        end
    end
end)

RegisterServerEvent("guille_gangs:server:deleteGang")
AddEventHandler("guille_gangs:server:deleteGang", function(gang)
    local _src = source
    if isAllowed(_src) then
        local actgang = gangs[gang].gangInfo()
        local members = actgang.getGangMembers()
        gangs[gang] = nil
        for k, v in pairs(members) do
            local steam = v.member.steam
            if plys[steam] then
                local id = plys[steam].getSource()
                TriggerClientEvent("guille_gangs:client:getGang", id)
                players[steam] = nil
            end
        end
        MySQL.Async.execute('DELETE FROM guille_gangsv2 WHERE gang=@gang', {
            ['@gang'] = gang,
        })
        TriggerClientEvent("guille_gangs:client:modifyGangs", _src)
    end
end)

RegisterServerEvent("guille_gangs:server:deleteVehicle")
AddEventHandler("guille_gangs:server:deleteVehicle", function(veh, gang)
    local _src = source
    if isAllowed(_src) then
        local actgang = gangs[gang].gangActions()
        actgang.deleteVehicle(veh, function(deleted)
            if deleted then
                TriggerClientEvent("guille_gangs:client:modifyGangs", _src)
            end
        end)
    end
end)

RegisterServerEvent("guille_gangs:server:addItem")
AddEventHandler("guille_gangs:server:addItem", function(itemPrice, itemName, itemType, label, gang)
    local _src = source
    if isAllowed(_src) then
        local actgang = gangs[gang].gangActions()
        actgang.addItem(itemPrice, itemName, itemType, label, function(result)
            if updated then
                TriggerClientEvent("guille_gangs:client:modifyGangs", _src)
            end
        end)
    end
end)

RegisterServerEvent("guille_gangs:server:addVeh")
AddEventHandler("guille_gangs:server:addVeh", function(gang, veh)
    local _src = source
    if isAllowed(_src) then
        local actgang = gangs[gang].gangActions()
        actgang.updateVehicles(veh, function(updated)
            if updated then
                TriggerClientEvent("guille_gangs:client:modifyGangs", _src)
            end
        end)
    end
end)

RegisterServerEvent("guille_gangs:server:updatePoints")
AddEventHandler("guille_gangs:server:updatePoints", function(gang, data)
    local _src = source
    if isAllowed(_src) then
        local actgang = gangs[gang].gangActions()
        actgang.updatePoints(data, function(updated)
            if updated then
                TriggerClientEvent("guille_gangs:client:modifyGangs", _src)
            end
        end)
    end
end)

RegisterServerEvent("guille_gangs:server:deleteItem")
AddEventHandler("guille_gangs:server:deleteItem", function(name, gang)
    local _src = source
    if isAllowed(_src) then
        local actgang = gangs[gang].gangActions()
        actgang.deleteItem(name, function(updated)
            if updated then
                TriggerClientEvent("guille_gangs:client:modifyGangs", _src)
            end
        end)
    end
end)