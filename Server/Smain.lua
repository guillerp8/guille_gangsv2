ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

gangs = {}
players = {}
plys = {}


MySQL.ready(function()
    log("^1Fixed IMPORTANT bug when set gang")
    MySQL.Async.fetchAll("SELECT * FROM guille_gangsv2", {}, function(data)
        for k, v in pairs(data) do
            gangs[v.gang] = getGangData(v.gang, v.maxmembers, json.decode(v.ranks), json.decode(v.colors), json.decode(v.vehicles), json.decode(v.points), json.decode(v.members), json.decode(v.shop), json.decode(v.inventory))
            for key, value in pairs(json.decode(v.members)) do
                for g, r in pairs(json.decode(v.ranks)) do
                    if tonumber(r.num) == tonumber(value.member.rank) then
                        players[value.member.steam] = manageGang(value.member.steam, v.gang, value.member.rank, r.label)
                    end
                end
            end
        end
        local playersOn = GetPlayers()
        for k,v in pairs(playersOn) do
            plys[GetPlayerIdentifiers(v)[1]] = getPlayerData(v, GetPlayerIdentifiers(v)[1])
        end
    end)
end)

function updateGangs()
    MySQL.Async.fetchAll("SELECT * FROM guille_gangsv2", {}, function(data)
        for k, v in pairs(data) do
            gangs[v.gang] = getGangData(v.gang, v.maxmembers, json.decode(v.ranks), json.decode(v.colors), json.decode(v.vehicles), json.decode(v.points), json.decode(v.members))
            for key, value in pairs(json.decode(v.members)) do
                for g, r in pairs(json.decode(v.ranks)) do
                    if tonumber(r.num) == tonumber(value.member.rank) then
                        players[value.member.steam] = manageGang(value.member.steam, v.gang, value.member.rank, r.label)
                    end
                end
            end
        end
    end)
end

ESX.RegisterServerCallback('guille_gangs:server:getGangsData', function(source,cb)
    local _src = source
    local ply = getPlayerData(_src)
    if players[ply.getSteam()] then
        local gang = players[ply.getSteam()].Player().getGang()
        if gang then
            local rank = players[ply.getSteam()].Player().getRank()
            local boss = gangs[gang].gangInfo().getBossRank()
            local rankName = players[ply.getSteam()].Player().getRankName()
            local data = gangs[gang]
            local identifier = ply.getSteam()
            cb(gang, rank, data, boss, identifier)
        end
    end
end)

RegisterCommand("creategang", function(source, args)
    local _src = source
    if isAllowed(_src) then
        TriggerClientEvent("guille_gangs:client:openCreation", _src)
    else
        TriggerClientEvent('esx:showNotification', _src, 'No perms to use this')
    end
end)

RegisterCommand("modifygangs", function(source, args)
    local _src = source
    if isAllowed(_src) then
        TriggerClientEvent("guille_gangs:client:modifyGangs", _src)
    end
end)

RegisterServerEvent("guille_gangs:server:addGang")
AddEventHandler("guille_gangs:server:addGang", function(gangName, maxMembers, ranks, gangStyle, red, green, blue, vehicles, points)
    local _src = source
    if isAllowed(_src) then
        MySQL.Async.execute("INSERT INTO guille_gangsv2 (gang, maxmembers, ranks, gangStyle, colors, vehicles, points, members, shop, inventory) VALUES (@gang, @maxmembers, @ranks, @gangStyle, @colors, @vehicles, @points, @members, @shop, @inventory)", {
            ['@gang'] = gangName, 
            ['@maxmembers'] = maxMembers,
            ['@ranks'] = json.encode(ranks),
            ['@gangStyle'] = gangStyle,
            ['@colors'] = json.encode({r = red, g = green, b = blue}),
            ['@vehicles'] = json.encode(vehicles),
            ['@points'] = json.encode(points),
            ['@members'] = json.encode({}),
            ['@shop'] = json.encode({}),
            ['@inventory'] = json.encode({})
        })
        gangs[gangName] = getGangData(gangName, maxMembers, ranks, {r = red, g = green, b = blue}, vehicles, points, {}, {}, {})
    end
end)

RegisterCommand("setgang", function(source, args)
    local _src = source
    if isAllowed(_src) then
        local id = args[1]
        local rank = args[3]
        if args[1] and args[2] and args[3] then
            if id == "me" then
                id = _src
            end
            local ply = getPlayerData(id)
            local gang = args[2]
            if players[ply.getSteam()] then
                if gang == players[ply.getSteam()].Player().getGang() and rank == players[ply.getSteam()].Player().getRank() then
                    log("Same gang")
                    return
                end
            end
            if gangs[gang] ~= nil then
                if gangs[gang].gangInfo().isRankValid(rank) then
                    if players[ply.getSteam()] then
                        local plygang = players[ply.getSteam()].Player().getGang()
                        local action = gangs[plygang].gangActions()
                        if plygang then
                            action.removeMember(ply.getSteam(), true, function(result)
                                if result then
                                    log("Gang member removed")
                                end
                            end)
                        end
                    end
                    local newgang = gangs[gang].gangActions()
                    newgang.addMember(id, gang, rank, function(result)
                        if result then
                            log("Success changing gang")
                        end
                    end)
                else
                    TriggerClientEvent("guille_gangs:client:notify", _src, "That rank does not exist")
                end
            else
                TriggerClientEvent("guille_gangs:client:notify", _src, "That gang does not exist")
            end
        else
            TriggerClientEvent("guille_gangs:client:notify", _src, "Some arguments are missing")
        end
    else
        TriggerClientEvent("guille_gangs:client:notify", _src, "You are not allowed to use this")
    end
end, false)

RegisterCommand("setgangmember", function(source, args)
    local _src = source
    local ply1 = getPlayerData(_src)
    if not players[ply1.getSteam()] then
        return log("Not gang attempting to set a member")
    end
    local plyGang = players[ply1.getSteam()].Player().getGang()
    local boss = gangs[plyGang].gangInfo().getBossRank()
    if tonumber(players[ply1.getSteam()].Player().getRank()) == tonumber(boss) then
        local id = args[1]
        local rank = args[2]
        if args[1] and args[2]  then
            if id == "me" then
                id = _src
            end
            local ply = getPlayerData(id)
            local gang = plyGang
            if players[ply.getSteam()] then
                if gang == players[ply.getSteam()].Player().getGang() and rank == players[ply.getSteam()].Player().getRank() then
                    log("Same gang")
                    return
                end
            end
            if not plys[ply.getSteam()] then
                TriggerClientEvent("guille_gangs:client:notify", _src, "Error on changing gang, tell your player to restart")
                return
            end
            if gangs[gang] ~= nil then
                if gangs[gang].gangInfo().isRankValid(rank) then
                    if players[ply.getSteam()] then
                        local plygang = players[ply.getSteam()].Player().getGang()
                        local action = gangs[plygang].gangActions()
                        if plygang then
                            action.removeMember(ply.getSteam(), true, function(result)
                                if result then
                                    log("Gang member removed")
                                end
                            end)
                        end
                    end
                    local newgang = gangs[gang].gangActions()
                    newgang.addMember(id, gang, rank, function(result)
                        if result then
                            log("Success changing gang")
                        end
                    end)
                else
                    TriggerClientEvent("guille_gangs:client:notify", _src, "That rank does not exist")
                end
            else
                TriggerClientEvent("guille_gangs:client:notify", _src, "That gang does not exist")
            end
        else
            TriggerClientEvent("guille_gangs:client:notify", _src, "Some arguments are missing")
        end
    else
        TriggerClientEvent("guille_gangs:client:notify", _src, "You are not the boss")
    end
end, false)

--[[ RegisterServerEvent("s")
AddEventHandler("s", function(s)
    print(s)
end) ]]

RegisterServerEvent("guille_gangs:server:buyItem")
AddEventHandler("guille_gangs:server:buyItem", function(type, name, price)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    if type == "weapon" then
        local money = xPlayer.getMoney()
        if money >= tonumber(price) then
            xPlayer.addWeapon(name, 250)
            xPlayer.removeMoney(tonumber(price))
            xPlayer.showNotification('Has comprado una ' ..ESX.GetWeaponLabel(name))
        else
            xPlayer.showNotification('No tienes suficiente dinero')
        end
    else 
        local money = xPlayer.getMoney()
        if money >= tonumber(price) then
            xPlayer.addInventoryItem(name, 1)
            xPlayer.removeMoney(tonumber(price))
            xPlayer.showNotification('Has comprado un ' ..ESX.GetItemLabel(name))
        else
            xPlayer.showNotification('No tienes suficiente dinero')
        end
    end
end)



AddEventHandler("esx:playerLoaded", function(source)
    local _src = source
    log("Created player " ..GetPlayerName(_src))
    plys[GetPlayerIdentifiers(_src)[1]] = getPlayerData(_src, GetPlayerIdentifiers(_src)[1])
end)

RegisterServerEvent('guille_gangs:requestarrest')
AddEventHandler('guille_gangs:requestarrest', function(targetid, playerheading, playerCoords,  playerlocation)
    TriggerClientEvent('guille_gangs:getarrested', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('guille_gangs:doarrested', source)
end)

RegisterServerEvent('guille_gangs:requestrelease')
AddEventHandler('guille_gangs:requestrelease', function(targetid, playerheading, playerCoords,  playerlocation)
    TriggerClientEvent('guille_gangs:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('guille_gangs:douncuffing', source)
end)

RegisterServerEvent('guille_gangs:putinvehicle')
AddEventHandler('guille_gangs:putinvehicle', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if target == 0 then
        xPlayer.showNotification('Not players near')
    else
        TriggerClientEvent('guille_gangs:putInVehicle', target)
    end
end)

RegisterServerEvent('guille_gangs:outfromveh')
AddEventHandler('guille_gangs:outfromveh', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if target == 0 then
        xPlayer.showNotification('Not players near')
    else
        TriggerClientEvent('guille_gangs:OutVehicle', target)
    end
end)

RegisterServerEvent('guille_gangs:escort')
AddEventHandler('guille_gangs:escort', function(target)
    TriggerClientEvent('guille_gangs:drag', target, source)
end)

-- Check version is not mine

local name = "[^4guille_gangsv2^7]"

MySQL.ready(function()

    function checkVersion(error, latestVersion, headers)
        local currentVersion = Config['scriptVersion']            
        
        if tonumber(currentVersion) < tonumber(latestVersion) then
            print(name .. " ^1is outdated.\nCurrent version: ^8" .. currentVersion .. "\nNewest version: ^2" .. latestVersion .. "\n^3Update^7: https://github.com/guillerp8/guille_gangsv2")
        elseif tonumber(currentVersion) > tonumber(latestVersion) then
            print(name .. " has skipped the latest version ^2" .. latestVersion .. ". Either Github is offline or the version file has been changed")
        else
            print(name .. " is updated.")
        end
    end

    PerformHttpRequest("https://raw.githubusercontent.com/guillerp8/jobcreatorversion/ma/gangs.txt", checkVersion, "GET")
end)

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    deferrals.defer()
    local _src = source
    deferrals.update("[guille_gangsv2] Checking steam")
    Citizen.Wait(100)
    local steam = nil
	for k,v in ipairs(GetPlayerIdentifiers(_src)) do
		if string.match(v, 'steam') then
			steam = v
			break
		end
	end
    print(steam)
    if not steam then
        deferrals.done("[guille_gangsv2] Your steam cannot be found.")
    else
        deferrals.done()
    end
end)