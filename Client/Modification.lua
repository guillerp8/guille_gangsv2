local createdGangs = {}
local newPoints = {}
local typePoints = {
    "Save Vehicles", -- Done
    "Get Vehicles", -- Done
    "Armory",
    "Boss",
    "Things to do",
    "Shop"
}

local itemType = ""
local itemName = ""
local itemPrice = ""
local itemLabel = ""
editingPoints = false

RegisterNetEvent("guille_gangs:client:modifyGangs")
AddEventHandler("guille_gangs:client:modifyGangs", function()
    createdGangs = {}
    ESX.TriggerServerCallback('guille_gangs:server:getGangs', function(gangs)
        createdGangs = gangs
    end)
    openModificationMenu()
end)

function openModificationMenu()
    WarMenu.CreateMenu('mod', 'Gang modification', 'Select the gang')


    WarMenu.CreateSubMenu("see-gangs", 'mod', "See created gangs")


    Citizen.CreateThread(function()
        if WarMenu.IsAnyMenuOpened() then
            return
        end
    
        WarMenu.OpenMenu('mod')
        while true do 
            if WarMenu.Begin('mod') then
                WarMenu.MenuButton('See gangs', 'see-gangs')
                WarMenu.End()
            elseif WarMenu.Begin('see-gangs') then
                for k, v in pairs(createdGangs) do
                    if WarMenu.Button(k) then
                        openSelectMenu(k)
                        WarMenu.CloseMenu()
                        currentMenu = nil
                    end 
                end
                WarMenu.End()
            else
                currentMenu = nil
                return
            end
            Citizen.Wait(0)
        end
    end)
end

RegisterNetEvent("guille_gangs:client:continueEditing")
AddEventHandler("guille_gangs:client:continueEditing", function(gang)
    TriggerEvent("guille_gangs:client:modifyGangs")
end)

function openSelectMenu(gang)
    Citizen.CreateThread(function()
        Citizen.Wait(100)
        WarMenu.CreateMenu('opt', 'Editing ' ..gang, 'See or modify')
        WarMenu.CreateSubMenu('members', 'opt', 'Name - Rank - Steam')
        WarMenu.CreateSubMenu('info', 'opt', 'Organization information')
        WarMenu.CreateSubMenu('vehs', 'opt', 'Press a vehicle to delete it')
        WarMenu.CreateSubMenu('points', 'opt', 'Change organization points')
        WarMenu.CreateSubMenu('shop', 'opt', 'View and remove shop items')
        WarMenu.CreateSubMenu('addshop', 'opt', 'Add items to the shop')
        WarMenu.CreateSubMenu('delete', 'opt', 'Delete the gang?')

        if WarMenu.IsAnyMenuOpened() then
            log("Menu opened")
            return
        end

        WarMenu.OpenMenu('opt')

        while true do
            if WarMenu.Begin('opt') then
                WarMenu.MenuButton('See members (Press member to remove)', 'members')
                WarMenu.MenuButton('Organization information', 'info')
                WarMenu.MenuButton('Gang vehicles', 'vehs')
                WarMenu.MenuButton('Points', 'points')
                WarMenu.MenuButton('View shop items', 'shop')
                WarMenu.MenuButton('Add items to shop', 'addshop')
                WarMenu.MenuButton('Delete ' ..gang.. " ~r~[DANGEROUS]", 'delete')
                WarMenu.End()
            elseif WarMenu.Begin('members') then
                for k, v in pairs(createdGangs) do
                    if k == gang then
                        for key, val in pairs(v.members) do
                            if WarMenu.Button(val.member.name.. " - " ..val.member.rank.. " - " ..val.member.steam) then
                                TriggerServerEvent("guille_gangs:server:removeGangMember", val.member.steam, gang)
                                WarMenu.CloseMenu()
                                currentMenu = nil
                                return
                            end
                        end
                    end
                end
                WarMenu.End()
            elseif WarMenu.Begin('info') then
                for k, v in pairs(createdGangs) do
                    if k == gang then
                        if WarMenu.Button("Gang name: " ..k) then
                            notify("This value can not be changed")
                        end

                        if WarMenu.Button("Max members: " ..v.max) then
                            notify("This value can not be changed")
                        end
                    end
                end
                WarMenu.End()
            elseif WarMenu.Begin("vehs") then
                local pressed, inputText = WarMenu.InputButton('Add vehicle', nil, _inputText)
                if pressed then
                    if inputText then
                        if IsModelInCdimage(inputText) then
                            TriggerServerEvent("guille_gangs:server:addVeh", gang, inputText)
                            for k, v in pairs(createdGangs) do
                                if k == gang then
                                    table.insert(v.vehicles, {vehicle = inputText})
                                end
                            end
                        else
                            notify("The model does not exist")
                        end
                    end
                end
                for k, v in pairs(createdGangs) do
                    if k == gang then
                        for key, val in pairs(v.vehicles) do
                            if WarMenu.Button("Vehicle name: " ..val.vehicle) then
                                TriggerServerEvent("guille_gangs:server:deleteVehicle", val.vehicle, gang)
                                currentMenu = nil
                                return
                            end
                        end
                    end
                end
                WarMenu.End()
            elseif WarMenu.Begin("shop") then
                for k, v in pairs(createdGangs) do
                    if k == gang then
                        for key, val in pairs(v.shop) do
                            if WarMenu.Button("Item name: " ..val.name.. " - ~g~" ..val.price.. "$") then
                                TriggerServerEvent("guille_gangs:server:deleteItem", val.name, gang)
                                currentMenu = nil
                                return
                            end
                        end
                    end
                end
                WarMenu.End()
            elseif WarMenu.Begin("addshop") then
                local pressed, type = WarMenu.InputButton('Add item type (item or weapon): ~r~'..itemType, nil, _inputText)
                if pressed then
                    if type then
                        if type == "item" or type == "weapon" then
                            itemType = type
                        else
                            notify("The item must be a 'item' or a 'weapon'")
                        end 
                    end
                end
                local pressed, name = WarMenu.InputButton('Add name: ~r~'..itemName, nil, _inputText)
                if pressed then
                    if name then
                        itemName = name
                    end
                end
                local pressed, price = WarMenu.InputButton('Add price: ~r~'..itemPrice, nil, _inputText)
                if pressed then
                    if price then
                        itemPrice = price
                    end
                end
                local pressed, label = WarMenu.InputButton('Add label: ~r~'..itemLabel, nil, _inputText)
                if pressed then
                    if label then
                        itemLabel = label
                    end
                end
                if WarMenu.Button("Submit item") then
                    if itemPrice ~= "" and itemName ~= "" and itemType ~= "" and itemLabel ~= "" then
                        TriggerServerEvent("guille_gangs:server:addItem", itemPrice, itemName, itemType, itemLabel, gang)
                        currentMenu = nil
                        return
                    end
                end
                WarMenu.End()
            elseif WarMenu.Begin("delete") then
                if WarMenu.Button("Are you sure? ~r~[This can not be reversed]") then
                    TriggerServerEvent("guille_gangs:server:deleteGang", gang)
                    currentMenu = nil
                    return
                end
                WarMenu.End()
            elseif WarMenu.Begin("points") then
                if WarMenu.Button("Update points") then
                    newPoints = {}
                    addPoints2(gang)
                    notify("The current points will be deleted")
                    currentMenu = nil
                    return
                end
                if WarMenu.Button("Confirm") then
                    TriggerServerEvent("guille_gangs:server:updatePoints", gang, newPoints)
                end
                WarMenu.End()
            else
                currentMenu = nil
                return
            end
            Citizen.Wait(0)
        end
    end)
end

function addPoints2(gang)
    editingPoints = true
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
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to add the point. Use ~INPUT_CELLPHONE_RIGHT~ and ~INPUT_CELLPHONE_LEFT~ to pass throught points, adding ~r~' ..typePoints[start].. "~w~. Press ~INPUT_FRONTEND_RRIGHT~ to stop.")
            else
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to add the point. Use ~INPUT_CELLPHONE_LEFT~ and ~INPUT_CELLPHONE_RIGHT~ to pass throught points, adding ~r~' ..typePoints[start].. "~w~. Keep pressed ~INPUT_AIM~ or ~INPUT_MAP_POI~ to modify the heading. Press ~INPUT_FRONTEND_RRIGHT~ to stop.")
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
                table.insert(newPoints, {coords = coords, type = typePoints[start], heading = heading})
                ESX.ShowNotification('Point added!')
            end

            if IsControlJustPressed(0, 194) then
                DeleteVehicle(veh)
                Citizen.Wait(250)
                openSelectMenu(gang)
                notify("Remember to confirm the points in ~r~points~w~, if you do not confirm them, they will not be saved")
                editingPoints = false
                break
            end
        end
    end)
end