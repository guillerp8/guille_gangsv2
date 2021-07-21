function isAllowed(source)
    local steam = nil
    local xPlayer = ESX.GetPlayerFromId(source)
    for k,v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steam = v
        end
    end
    for k,v in pairs(Config['admins']) do
        if v == steam then
            return true
        end
    end
    for k,v in pairs(Config['groups']) do
        if xPlayer.getGroup() == v then
            return true
        end
    end
    return false
end

function log(txt)
    if txt then
        print("^2[guille_gangsv2]^8 " ..txt)
    else
        print("^2[guille_gangsv2]^8 Attempting to print a nil value")
    end
end

function getPlayerData(src, steam)
    local this = {}

    this.src = src
    this.steam = steam

    function this.getSteam(cb)
        local steam = GetPlayerIdentifiers(this.src)[1]
        if steam then
            return steam
        end
    end

    function this.getSource()
        return this.src
    end

    function this.getLicense(cb)
        local license = GetPlayerIdentifiers(this.src)[2]
        if license then
            return license
        end
    end

    function this.getName(cb)
        local name = GetPlayerName(this.src)
        return name
    end
    return this
end


