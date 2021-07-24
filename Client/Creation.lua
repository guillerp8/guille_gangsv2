
local gangName, maxMembers, ranks, gangStyle, red, green, blue, vehicles, points = nil, nil, {}, 1, 1, 1, 1, {}, {}

local gangRankToCha = 0

local _altX = false
local _altY = false
local _altWidth = false
local _altTitle = false
local _altSubTitle = false
local _altMaxOption = false

-- Controls


local _altSprite = false

local posibleOnes = { "Gang", "Mafia" }

local rank = 0

local typePoints = {
    "Save Vehicles",
    "Get Vehicles",
    "Armory",
    "Boss",
    --"Things to do",
    "Shop"
}

local _checked = false

local _altTitleColor = false
local _altSubTitleColor = false
local _altTitleBackgroundColor = false
local _altTitleBackgroundSprite = false
local _altBackgroundColor = false
local _altTextColor = false
local _altSubTextColor = false
local _altFocusColor = false
local _altFocusTextColor = false
local _altButtonSound = false

WarMenu.CreateMenu('demo', _U('gang_creation'), _U('gang_info'))

WarMenu.CreateSubMenu('demo_menu', 'demo', _U('menu'))
WarMenu.CreateSubMenu('demo_style', 'demo', _U('style'))
WarMenu.CreateSubMenu('demo_vehicles', 'demo', _U('vehs'))
WarMenu.CreateSubMenu('demo_points', 'demo', _U('points'))
WarMenu.CreateSubMenu('confirm', 'demo', _U('conf'))
WarMenu.CreateSubMenu('demo_exit', 'demo', _U('sure'))

RegisterNetEvent('guille_gangs:client:openCreation')
AddEventHandler('guille_gangs:client:openCreation', function()

    if WarMenu.IsAnyMenuOpened() then
        return
    end

    WarMenu.OpenMenu('demo')

    while true do
        if WarMenu.Begin('demo') then
            WarMenu.MenuButton('Gang Info', 'demo_menu')
            WarMenu.MenuButton('Gang style', 'demo_style')
            WarMenu.MenuButton('Gang vehicles', 'demo_vehicles')
            WarMenu.MenuButton('Add points', 'demo_points')
            WarMenu.MenuButton('Confirm creation', 'confirm')
            WarMenu.MenuButton('Exit', 'demo_exit')

            WarMenu.End()
        elseif WarMenu.Begin('demo_menu') then
            if gangName == nil then
                local pressed, inputText = WarMenu.InputButton('Gang name:', nil, _inputText)
                if pressed then
                    if inputText then
                        gangName = inputText
                    end
                end
            else
                local pressed, inputText = WarMenu.InputButton('Gang name: ~r~' ..gangName, nil, _inputText)
                if pressed then
                    if inputText then
                        gangName = inputText
                    end
                end
            end

            if maxMembers == nil then
                local pressed, inputText = WarMenu.InputButton('Max members:', nil, _inputText)
                if pressed then
                    if inputText then
                        local maxOnes = tonumber(inputText)
                        if maxOnes then
                            maxMembers = maxOnes
                        else
                            ESX.ShowNotification('Max members must be a number')
                        end
                    end
                end
            else
                local pressed, inputText = WarMenu.InputButton('Max members: ~r~' ..maxMembers, nil, _inputText)
                if pressed then
                    if inputText then
                        local maxOnes = tonumber(inputText)
                        if maxOnes then
                            maxMembers = maxOnes
                        else
                            ESX.ShowNotification('Max members must be a number')
                        end
                    end
                end
            end

            if WarMenu.Button('Add rank') then
                ESX.ShowNotification('If you press ~r~Y~w~ you delete the last rank that you created.')
                gangRankToCha = gangRankToCha + 1
                table.insert(ranks, {label = gangRankToCha, num = gangRankToCha})
            end

            if WarMenu.IsItemHovered() then
                WarMenu.ToolTip('You can add infinite ranks')
            end

            for i = 1, #ranks, 1 do
                local pressed, inputText = WarMenu.InputButton('Rank: ' ..ranks[i]['label'], nil, _inputText)
                if pressed then
                    if inputText then
                        ranks[i]['label'] = inputText
                    end
                end
            end

            if IsControlJustPressed(1, 246) then
                table.remove(ranks, #ranks)
                gangRankToCha = gangRankToCha - 1
            end

            WarMenu.End()
        elseif WarMenu.Begin('demo_style') then
            local _, comboBoxIndex = WarMenu.ComboBox('Organization type: ', posibleOnes, gangStyle)
            if gangStyle ~= comboBoxIndex then
                gangStyle = comboBoxIndex
            end
            if red == nil then
                local pressed, inputText = WarMenu.InputButton('Red color:', nil, _inputText)
                if pressed then
                    if inputText then
                        red = inputText
                    end
                end
                if WarMenu.IsItemHovered() then
                    WarMenu.ToolTip('RGB (Example) -> 255, 255, 255')
                end
            else
                local pressed, inputText = WarMenu.InputButton('Red color: ~r~' ..red, nil, _inputText)
                if pressed then
                    if inputText then
                        red = inputText
                    end
                end
                if WarMenu.IsItemHovered() then
                    WarMenu.ToolTip('RGB (Example) -> 255, 255, 255')
                end
            end
            if green == nil then
                local pressed, inputText = WarMenu.InputButton('Green color:', nil, _inputText)
                if pressed then
                    if inputText then
                        green = inputText
                    end
                end
                if WarMenu.IsItemHovered() then
                    WarMenu.ToolTip('RGB (Example) -> 255, 255, 255')
                end
            else
                local pressed, inputText = WarMenu.InputButton('Green color: ~r~' ..green, nil, _inputText)
                if pressed then
                    if inputText then
                        green = inputText
                    end
                end
                if WarMenu.IsItemHovered() then
                    WarMenu.ToolTip('RGB (Example) -> 255, 255, 255')
                end
            end
            if blue == nil then
                local pressed, inputText = WarMenu.InputButton('Blue color:', nil, _inputText)
                if pressed then
                    if inputText then
                        blue = inputText
                    end
                end
                if WarMenu.IsItemHovered() then
                    WarMenu.ToolTip('RGB (Example) -> 255, 255, 255')
                end
            else
                local pressed, inputText = WarMenu.InputButton('Blue color: ~r~' ..blue, nil, _inputText)
                if pressed then
                    if inputText then
                        blue = inputText
                    end
                end
                if WarMenu.IsItemHovered() then
                    WarMenu.ToolTip('RGB (Example) -> 255, 255, 255')
                end
            end
            WarMenu.End()
        elseif WarMenu.Begin('demo_vehicles') then
            local pressed, inputText = WarMenu.InputButton('Add vehicle', nil, _inputText)
            if pressed then
                if inputText then
                    if IsModelInCdimage(inputText) then
                        table.insert(vehicles, {vehicle = inputText})
                        ESX.ShowNotification('Press ~r~Y~w~ to delete the last vehicle added')
                    else
                        ESX.ShowNotification('That car model does not exist')
                    end
                end
            end
            for i = 1, #vehicles, 1 do
                WarMenu.Button(firstToUpper(vehicles[i]['vehicle']))
            end

            if IsControlJustPressed(1, 246) then
                table.remove(vehicles, #vehicles)
            end

            WarMenu.End()
        elseif WarMenu.Begin('demo_points') then
            if WarMenu.Button('Add points') then
                addPoints()
                WarMenu.CloseMenu()
            end
            WarMenu.End()
        elseif WarMenu.Begin('demo_exit') then
            WarMenu.MenuButton('No', 'demo')

            if WarMenu.Button('~r~Yes') then
                WarMenu.CloseMenu()
            end

            WarMenu.End()
        elseif WarMenu.Begin("confirm") then
            if WarMenu.Button('Press to confirm') then
                attemptToConfirm()
                WarMenu.CloseMenu()
            end
            WarMenu.End()
        else
            return
        end

        Citizen.Wait(0)
    end
end)

function addPoints()
    local veh = nil
    local vehicleCreated = false
    Citizen.CreateThread(function()
        local start = 1
        local heading = 0.00
        while true do
            local hit, coords, entity = RayCastGamePlayCamera(1000.0)
            DrawMarker(1, coords, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 233, 0, 255, 0, 0, 0, 0, 0, 0, 0)
            Citizen.Wait(0)
            
            
            if typePoints[start] == "Get Vehicles" and not vehicleCreated then
                local hash = GetHashKey("zentorno")
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Citizen.Wait(1)
                end
                veh = CreateVehicle(hash, coords, 100.00, false, false)
                SetVehicleCustomPrimaryColour(veh, tonumber(red), tonumber(green), tonumber(blue))
                SetEntityCollision(veh, false, false)
                SetEntityAlpha(veh, 180, 0)
                vehicleCreated = true
            end

            if typePoints[start] ~= "Get Vehicles" then
                vehicleCreated = false
                DeleteVehicle(veh)
                ShowHelpNotification('Press ~INPUT_CONTEXT~ to add the point. Use ~INPUT_CELLPHONE_RIGHT~ and ~INPUT_CELLPHONE_LEFT~ to pass throught points, adding ~r~' ..typePoints[start].. "~w~. Press ~INPUT_FRONTEND_RRIGHT~ to stop.")
            else
                ShowHelpNotification('Press ~INPUT_CONTEXT~ to add the point. Use ~INPUT_CELLPHONE_LEFT~ and ~INPUT_CELLPHONE_RIGHT~ to pass throught points, adding ~r~' ..typePoints[start].. "~w~. Keep pressed ~INPUT_AIM~ or ~INPUT_MAP_POI~ to modify the heading. Press ~INPUT_FRONTEND_RRIGHT~ to stop.")
            end

            if IsControlPressed(0, 25) then
                heading = heading + 0.75
            end
            if IsControlPressed(0, 348) then
                heading = heading - 0.75
            end
            SetEntityHeading(veh, heading) 
            SetEntityCoords(veh, coords)
            if IsControlJustPressed(1, 175) then
                if start == #typePoints then
                    start = 1
                else
                    start = start + 1
                end
            end

            if IsControlJustPressed(1, 174) then
                if start == 1 then
                    start = #typePoints
                else
                    start = start - 1
                end
            end

            if IsControlJustPressed(1, 38) then
                table.insert(points, {coords = coords, type = typePoints[start], heading = heading})
                ESX.ShowNotification('Point added!')
            end

            if IsControlJustPressed(0, 194) then
                DeleteVehicle(veh)
                Citizen.Wait(250)
                TriggerEvent("guille_gangs:client:openCreation")
                break
            end
        end
    end)
end

function attemptToConfirm()
    --if gangName ~= nil and maxMembers ~= nil and #ranks ~= 0 and red ~= nil and #points ~= 0 then
        log("Sending gang to db")
        ESX.ShowNotification('Creating the gang...')
        TriggerServerEvent("guille_gangs:server:addGang", gangName, maxMembers, ranks, gangStyle, red, green, blue, vehicles, points)

        gangName = nil 
        maxMembers = nil
        ranks = {}
        gangStyle = 1 
        red = 1
        green = 1
        blue = 1
        vehicles = {}
        points = {}
        gangRankToCha = 0
    --else
        --ESX.ShowNotification('You missed a necessary value')
    --end
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function RayCastGamePlayCamera(distance)
    -- https://github.com/Risky-Shot/new_banking/blob/main/new_banking/client/client.lua
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end


function RotationToDirection(rotation)
    -- https://github.com/Risky-Shot/new_banking/blob/main/new_banking/client/client.lua
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end