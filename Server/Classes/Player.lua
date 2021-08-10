function manageGang(source, gang, rank, rankName)
    local this = {}
    this.src = source
    this.gang = gang
    this.rank = rank
    this.rankName = rankName

    function this.Player()
        local ply = {}

        function ply.getGang()
            return this.gang
        end

        function ply.getRank()
            return this.rank
        end

        function ply.getRankName()
            return this.rankName
        end

        return ply
    end

    return this
end

function getGangData(gang, maxmembers, ranks, colors, vehicles, points, members, shop, inventory)
    local this = {}
    this.gang = gang
    this.max = maxmembers
    this.ranks = ranks
    this.colors = colors
    this.vehicles = vehicles
    this.points = points
    this.members = members
    this.shop = shop
    this.inventory = inventory

    function this.gangInfo()
        local info = {}

        function info.getGangMax()
            return this.max
        end

        function info.getGangRanks()
            return this.ranks
        end

        function info.getBossRank()
            return #this.ranks
        end

        function info.getGangColors()
            return this.colors
        end

        function info.getGangVehicles()
            return this.vehicles
        end

        function info.getGangPoints()
            return this.points
        end

        function info.getGangMembers()
            return this.members
        end

        function info.getShopItems()
            return this.shop
        end

        function info.getInv()
            return this.inventory
        end

        function info.isRankValid(rank)
            if this.ranks[tonumber(rank)] ~= nil then
                return true
            else
                return false
            end
        end
        return info
    end

    function this.gangActions()
        local act = {}

        function act.removeMember(steam, change, OboWombo, cb)
            for k, v in pairs(this.members) do
                if v.member.steam == steam then
                    table.remove(this.members, k)
                    MySQL.Async.execute("UPDATE guille_gangsv2 SET members=@member WHERE gang=@gang", {
                        ['@member'] = json.encode(this.members),
                        ['@gang'] = this.gang
                    }, function(row)
                        if row then
                            if plys[steam] then
                                local id = plys[steam].getSource()
                                players[steam] = nil
                                if not change then
                                    TriggerClientEvent("guille_gangs:client:getGang", id)
                                end
                            end
                            if cb then
                                return cb(true)
                            else
                                return true
                            end
                        end
                    end)
                    break
                end
            end
        end

        function act.addMember(id, gang, rank, cb)
            if not id then
                if cb then
                    cb(false)
                else
                    return false
                end
            elseif not gang then
                if cb then
                    cb(false)
                else
                    return false
                end
            end
            local ply = getPlayerData(id)
            local member = {
                steam = ply.getSteam(),
                name = ply.getName(),
                rank = rank
            }
       
            if member.steam == nil or member.name == nil then
                TriggerClientEvent("guille_gangs:client:notify", id, "An error has ocurred, restart your game")
                return
            end
            table.insert(this.members, {member = member})   
            MySQL.Async.execute("UPDATE guille_gangsv2 SET members=@member WHERE gang = @gang", {
                ['@member'] = json.encode(this.members),
                ['@gang'] = gang
            }, function(row)
                if row then
                    players[ply.getSteam()] = manageGang(ply.getSteam(), gang, rank)
                    TriggerClientEvent("guille_gangs:client:notify", id, "Your gang now is ~r~" ..gang)
                    TriggerClientEvent("guille_gangs:client:getGang", id)
                    if cb then
                        return cb(true)
                    else
                        return true
                    end
                else
                    if cb then
                        cb(false)
                    else
                        return false
                    end
                end
            end)
            if cb then
                cb(false)
            else
                return false
            end
        end

        function act.updateVehicles(veh, cb)
            table.insert(this.vehicles, {vehicle = veh})
            MySQL.Async.execute("UPDATE guille_gangsv2 SET vehicles=@vehicles WHERE gang=@gang", {
                ['@vehicles'] = json.encode(this.vehicles),
                ['@gang'] = this.gang
            }, function(rows)
                if rows then
                    for k, v in pairs(this.members) do
                        local steam = v.member.steam
                        if plys[steam] then
                            local id = plys[steam].getSource()
                            TriggerClientEvent("guille_gangs:client:getGang", id)
                        end
                    end
                    if cb then
                        return cb(true)
                    else
                        return true
                    end
                end
            end)
            if cb then
                cb(false)
            else
                return false
            end
        end

        function act.deleteVehicle(veh, cb)
            for k, v in pairs(this.vehicles) do
                if v.vehicle == veh then
                    table.remove(this.vehicles, k)
                end
            end
            MySQL.Async.execute("UPDATE guille_gangsv2 SET vehicles=@vehicles WHERE gang = @gang", {
                ['@vehicles'] = json.encode(this.vehicles),
                ['@gang'] = this.gang
            }, function(row)
                if row then 
                    for k, v in pairs(this.members) do
                        local steam = v.member.steam
                        if plys[steam] then
                            local id = plys[steam].getSource()
                            TriggerClientEvent("guille_gangs:client:getGang", id)
                        end
                    end
                    if cb then
                        return cb(true)
                    else
                        return true
                    end
                end
            end)
            if cb then
                cb(false)
            else
                return false
            end
        end

        function act.addItem(itemPrice, itemName, itemType, label, cb)
            table.insert(this.shop, {type = itemType, name = itemName, price = itemPrice, label = label})
            MySQL.Async.execute("UPDATE guille_gangsv2 SET shop=@shop WHERE gang = @gang", {
                ['@shop'] = json.encode(this.shop),
                ['@gang'] = this.gang
            }, function(rows)
                if rows then
                    for k, v in pairs(this.members) do
                        local steam = v.member.steam
                        if plys[steam] then
                            local id = plys[steam].getSource()
                            TriggerClientEvent("guille_gangs:client:getGang", id)
                        end
                    end
                    if cb then
                        return cb(true)
                    else
                        return true
                    end
                end
            end)
            if cb then
                cb(false)
            else
                return false
            end
        end

        function act.deleteItem(name, cb)
            for k, v in pairs(this.shop) do
                if v.name == name then
                    table.remove(this.shop, k)
                end
            end
            MySQL.Async.execute("UPDATE guille_gangsv2 SET shop=@shop WHERE gang = @gang", {
                ['@shop'] = json.encode(this.shop),
                ['@gang'] = this.gang
            }, function(rows)
                if rows then
                    for k, v in pairs(this.members) do
                        local steam = v.member.steam
                        if plys[steam] then
                            local id = plys[steam].getSource()
                            TriggerClientEvent("guille_gangs:client:getGang", id)
                        end
                    end
                    if cb then
                        return cb(true)
                    else
                        return true
                    end
                end
            end)
            if cb then
                cb(false)
            else
                return false
            end
        end

        function act.updatePoints(data, cb)
            this.points = data
            MySQL.Async.execute("UPDATE guille_gangsv2 SET points=@points WHERE gang = @gang", {
                ['@points'] = json.encode(data),
                ['@gang'] = this.gang
            }, function(rows)
                if rows then
                    for k, v in pairs(this.members) do
                        local steam = v.member.steam
                        if plys[steam] then
                            local id = plys[steam].getSource()
                            TriggerClientEvent("guille_gangs:client:getGang", id)
                        end
                    end
                    if cb then
                        return cb(true)
                    else
                        return true
                    end
                end
            end)
            if cb then
                cb(false)
            else
                return false
            end
        end

        function act.addItemToInv(type, name, count, label, cb)
            local found = false
            if #this.inventory >= 1 then
                for k, v in pairs(this.inventory) do
                    if v.type == "account" and type == "account" and name == v.name then
                        table.insert(this.inventory, {type = type, label = label, name = name, count = v.count + count})
                        table.remove(this.inventory, k)
                        found = true
                        break
                    elseif v.type == "item" and type == "item" and name == v.name then
                        table.insert(this.inventory, {type = type, label = label, name = name, count = v.count + count})
                        table.remove(this.inventory, k)
                        found = true
                        break
                    end
                end
                
            end
            if not found then
                table.insert(this.inventory, {type = type, label = label, name = name, count = count})
            end
            MySQL.Async.execute("UPDATE guille_gangsv2 SET inventory=@inventory WHERE gang = @gang", {
                ['@inventory'] = json.encode(this.inventory),
                ['@gang'] = this.gang
            }, function(rows)
                if rows then
                    if cb then
                        return cb(true)
                    else
                        return true
                    end
                end
            end)
            if cb then
                cb(false)
            else
                return false
            end
        end
        
        function act.removeItemOfInv(type, name, count, cb)
            local found = false
            if #this.inventory >= 1 then
                for k, v in pairs(this.inventory) do
                    if v.type == "account" and type == "account" then
                        if v.name == name then
                            if v.count >= 1 then
                                this.inventory[k]['count'] = v.count - count
                                if this.inventory[k]['count'] == 0 then
                                    table.remove(this.inventory, k)
                                end
                                found = true
                                break
                            else
                                table.remove(this.inventory, k)
                                found = true
                                break
                            end

                        end
                    elseif v.type == "item" and type == "item" then
                        if v.name == name then
                            if v.count == 0 then
                                table.remove(this.inventory, k)
                            end
                            if v.count > 1 then
                                this.inventory[k]['count'] = v.count - count
                                if this.inventory[k]['count'] == 0 then
                                    table.remove(this.inventory, k)
                                end
                                found = true
                                break
                            else
                                table.remove(this.inventory, k)
                                found = true
                                break
                            end
                        end
                    elseif v.type == "weapon" and type == "weapon" then
                        if v.name == name then
                            table.remove(this.inventory, k)
                            found = true
                            break
                        end
                    end
                end
            end
            MySQL.Async.execute("UPDATE guille_gangsv2 SET inventory=@inventory WHERE gang = @gang", {
                ['@inventory'] = json.encode(this.inventory),
                ['@gang'] = this.gang
            }, function(rows)
                if rows then
                    if cb then
                        return cb(true)
                    else
                        return true
                    end
                end
            end)
            if cb then
                cb(false)
            else
                return false
            end
        end

        return act
    end
    return this
end
