local gangName, rankNum, gangData, bossRank = nil, nil, nil, nil
local changing = false
local handcuff = false
isThis = {}
RegisterNetEvent("guille_gangs:client:getGang")
AddEventHandler("guille_gangs:client:getGang", function()
    changing = true
    Citizen.Wait(500)
    gangName, rankNum, gangData, bossRank = nil, nil, {}, nil
    getPoints()
end)

function getPoints()
    Citizen.Wait(1500)
    log("[INFO] Getting points")
    ESX.TriggerServerCallback('guille_gangs:server:getGangsData', function(gang, rank, data, boss)
        if gang then
            gangName = gang
            rankNum = rank
            gangData = data
            bossRank = boss
            enablePoints()
        end
    end)
end

function enablePoints()
    local xPlayer = ESX.GetPlayerData()
    local isBoss = false
    changing = false
    for key, val in pairs(gangData.members) do
        if val.member.steam == xPlayer.identifier then
            if tonumber(val.member.rank) == #gangData.ranks then
                isBoss = true
            end
        end
    end
    Citizen.CreateThread(function()
        while true do
            local wait = 1500
            local ped = PlayerPedId()
            local plyCoords = GetEntityCoords(ped)
            if changing then
                break
            end

            for k, v in pairs(gangData.points) do
                local dist = GetDistanceBetweenCoords(v.coords.x, v.coords.y, v.coords.z, plyCoords, true)
                if dist < 20 then
                    wait = 0
                    if not editingPoints then 
                        DrawMarker(1, v.coords.x, v.coords.y, v.coords.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 233, 0, 255, 0, 0, 0, 0, 0, 0, 0)
                        if dist < 1.5 and not isThis.menuOpened then
                            if v.type == "Save Vehicles" then
                                ShowFloatingHelpNotification(Config['saveVehNotif'], vector3(v.coords.x, v.coords.y, v.coords.z))
                                if IsControlJustPressed(1, 38) then
                                    saveVeh()
                                end
                            elseif v.type == "Get Vehicles" then
                                ShowFloatingHelpNotification(Config['getVehNotif'], vector3(v.coords.x, v.coords.y, v.coords.z))
                                if IsControlJustPressed(1, 38) then
                                    openVehMenu()
                                end
                            elseif v.type == "Armory" then
                                ShowFloatingHelpNotification(Config['armorNotif'], vector3(v.coords.x, v.coords.y, v.coords.z))
                                if IsControlJustPressed(1, 38) then
                                    openGangInventory()
                                end
                            elseif v.type == "Boss" then
                                if isBoss then
                                    ShowFloatingHelpNotification(Config['bossNotif'], vector3(v.coords.x, v.coords.y, v.coords.z))
                                    if IsControlJustPressed(1, 38) then
                                        openBossMenu()
                                    end
                                else
                                    ShowFloatingHelpNotification(Config['notBossNotif'], vector3(v.coords.x, v.coords.y, v.coords.z))
                                end
                            elseif v.type == "Things to do" then
                                ShowFloatingHelpNotification(Config['toDoNotif'], vector3(v.coords.x, v.coords.y, v.coords.z))
                            elseif v.type == "Shop" then
                                ShowFloatingHelpNotification(Config['shopNotif'], vector3(v.coords.x, v.coords.y, v.coords.z))
                                if IsControlJustPressed(1, 38) then
                                    openShop()
                                end
                            end
                        end
                    end
                end
            end
            Citizen.Wait(wait)
        end
    end)
end

function openVehMenu()
    local data = {}
    if #gangData.vehicles == 0 then
        return
    end
    local cb = "vehs"
    for k, v in pairs(gangData.vehicles) do
        table.insert(data, {text = firstToUpper(v.vehicle), toDo = v.vehicle})
    end
    TriggerEvent("guille_cont:client:open", _U("veh_menu"), data, cb, false)
    return
end

function openBossMenu()
    local data = {}
    if #gangData.members == 0 then
        return
    end
    local cb = "member"
    for k, v in pairs(gangData.members) do
        --
        table.insert(data, {text = v.member.name.. " - " ..v.member.rank, toDo = v.member.steam})
    end
    TriggerEvent("guille_cont:client:open", _U("click_to_ex"), data, cb, false)
end

RegisterNUICallback("member", function(cb)
    TriggerServerEvent("guille_gangs:server:removeGangMember", cb.execute, gangData.gang, true)
end)

RegisterNUICallback("vehs", function(cb)
    local hash = GetHashKey(cb.execute)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(1)
    end
    for k, v in pairs(gangData.points) do
        if v.type == "Get Vehicles" then
            veh = CreateVehicle(hash, v.coords.x, v.coords.y, v.coords.z, v.heading, true, true)
        end
    end
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    SetVehicleCustomPrimaryColour(veh, tonumber(gangData.colors.r), tonumber(gangData.colors.g), tonumber(gangData.colors.b))
end)


function saveVeh()
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        local veh, dist = ESX.Game.GetClosestVehicle(GetEntityCoords(ped))
        if dist < 2 then
            local model = GetEntityModel(veh)
            local carname = GetDisplayNameFromVehicleModel(model)
            TaskLeaveVehicle(ped, veh, 0)
            Citizen.Wait(3000)
            NetworkFadeOutEntity(veh, false, true)
            Citizen.Wait(1000)
            DeleteVehicle(veh)
            notify(_U("you_deleted") ..firstToUpper(carname))
        else
            ESX.ShowNotification(_U("not_in_veh"))
        end
    end)
end

function openShop()
    local data = {}
    if #gangData.shop == 0 then
        return
    end
    local cb = "item"
    for k, v in pairs(gangData.shop) do
        table.insert(data, {text = v.label.."<span style='color:green'>"..v.price.."$</span>", toDo = v.name})
    end
    TriggerEvent("guille_cont:client:open", _U("shop_menu"), data, cb, false)
end

RegisterNUICallback("item", function(cb)
    for k, v in pairs(gangData.shop) do
        if v.name == cb.execute then
            TriggerServerEvent("guille_gangs:server:buyItem", v.type, v.name, v.price)
            break
        end
    end
end)

function openGangInventory()
    local elements = {}
    table.insert(elements, { label = _U("put_it"), value = "put" })
    table.insert(elements, { label = _U("get_it"), value = "get" })
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gang_inv', {
        title = _U("gang_inv"),
        align = 'bottom-right',
        elements = elements
    }, function(data, menu)
        local v = data.current.value
        if v == "put" then
            PutStock()
        elseif v == "get" then
            GetStock()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function PutStock()
    ESX.TriggerServerCallback('guille_gangs:server:getPlyInv', function(accounts, items, weapons)
        local elements = {}
        table.insert(elements, {label = _U("--Accounts--")})
        for k, v in pairs(accounts) do
            if v.name ~= "bank" then
                table.insert(elements, {itemL = v.label, label = v.label.." - "..v.money.."$" , type = "account", quantity = v.money, name = v.name})
            end
        end
        table.insert(elements, {label = _U("--Items--")})
        for k, v in pairs(items) do
            if v.count >= 1 then
                table.insert(elements, {itemL = v.label,  label = v.label.." - x"..v.count, type = "item", quantity = v.count, name = v.name})
            end
        end
        table.insert(elements, {label = _U("--Weapons--")})
        for k, v in pairs(weapons) do
            table.insert(elements, {itemL = v.label, label = v.label.." - x"..v.ammo, type = "weapon", quantity = v.ammo, name = v.name})
        end
        ESX.UI.Menu.Open('default',GetCurrentResourceName(),"my_inv",
        { 
        title = _U("your_inv"), 
        align = "bottom-right", 
        elements = elements 
        }, function(data, menu)
        if data.current.type == "account" then
            ESX.UI.Menu.Open('dialog',GetCurrentResourceName(),"def_count",
            { 
            title = _U("how_mon"), 
            align = "middle", 
            elements = elements 
            }, function(data2, menu2)
                local count = tonumber(data2.value)
                if count == nil or count == 0 then
                    notify(_U('inv_ammount'))
                else
                    if count <= data.current.quantity then
                        menu2.close()
                        TriggerServerEvent('guille_gangs:server:addItemToInv', data.current.type, data.current.name, count, data.current.itemL, gangName)
                        PutStock()
                    else
                        notify(_U('inv_ammount'))
                    end
                end
            end, function(data2, menu2) 
                menu2.close()
                PutStock()
            end)
        elseif data.current.type == "item" then
            ESX.UI.Menu.Open('dialog',GetCurrentResourceName(),"def_count",
            { 
            title = _U("How_much_items?"), 
            align = "middle", 
            elements = elements 
            }, function(data2, menu2)
                local count = tonumber(data2.value)
                if count == nil or count == 0 then
                    notify(_U('inv_ammount'))
                else
                    if count <= data.current.quantity then
                        menu2.close()
                        TriggerServerEvent('guille_gangs:server:addItemToInv', data.current.type, data.current.name, count, data.current.itemL, gangName)
                        PutStock()
                    else
                        notify(_U('inv_ammount'))
                    end
                end
            end, function(data2, menu2) 
                menu2.close()
                PutStock()
            end)
        elseif data.current.type == "weapon" then
            TriggerServerEvent('guille_gangs:server:addItemToInv', data.current.type, data.current.name, data.current.quantity, data.current.itemL,  gangName)
            menu.close()
            PutStock()
        end
        end, function(data, menu) 
            menu.close() 
        end)
    end)
end

function GetStock()
    ESX.UI.Menu.CloseAll()
    ESX.TriggerServerCallback('guille_gangs:server:getGangInv', function(inv)
        local elements = {}
        for k, v in pairs(inv) do
            
            if v.type == "account" then
                table.insert(elements, {label = v.label.." - "..v.count.."$" , type = v.type, quantity = v.count, name = v.name})
            elseif v.type == "item" then
                table.insert(elements, {label = v.label.." - x"..v.count , type = v.type, quantity = v.count, name = v.name})
            elseif v.type == "weapon" then
                table.insert(elements, {label = v.label.." - x"..v.count , type = v.type, quantity = v.count, name = v.name})
            end
        end
        ESX.UI.Menu.Open('default',GetCurrentResourceName(),"name",
        { 
        title = _U("gang_inv"), 
        align = "bottom-right", 
        elements = elements 
        }, function(data, menu)
            if data.current.type ~= "weapon" then
                ESX.UI.Menu.Open('dialog',GetCurrentResourceName(),"def_count",
                { 
                title = _U("How_much_items?"), 
                align = "middle", 
                elements = elements 
                }, function(data2, menu2)
                    local count = tonumber(data2.value)
                    if count == nil or count == 0 then
                        notify(_U('inv_ammount'))
                    else
                        if count <= data.current.quantity then
                            TriggerServerEvent("guille_gangs:server:removeItemInv", data.current.type, data.current.name, count, gangName)
                            menu.close() 
                            menu2.close()
                            GetStock()
                        else
                            notify(_U('inv_ammount'))
                        end
                    end
                end, function(data2, menu2) 
                    menu2.close()
                    GetStock()
                end)
            else
                TriggerServerEvent("guille_gangs:server:removeItemInv", data.current.type, data.current.name, data.current.quantity, gangName)
                menu.close() 
                GetStock()
            end
        end, function(data, menu) 
            menu.close() 
        end)
    end, gangName)
end

local isDragging = false

RegisterCommand('gangmenu', function()
    if gangName ~= nil then
        local ped = PlayerPedId()
        local elements = {}
        table.insert(elements, { label = _U("Search"), value = "search" })
        table.insert(elements, { label = _U("Handcuff"), value = "handcuff" })
        table.insert(elements, { label = _U("Unhandcuff"), value = "unarrest" })
        table.insert(elements, { label = _U("add_veh"), value = "vehiclein" })
        table.insert(elements, { label = _U("out_from_veh"), value = "vehicleout" })
        table.insert(elements, { label = _U("Escort"), value = "escort" })
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_gang', {
        title = (gangName.. _U("acts")),
        align = 'top-right',
        elements = elements
        }, function(data, menu)
            local v = data.current.value
            if v == 'handcuff' then
                local player, distance = ESX.Game.GetClosestPlayer()
                local playerheading = GetEntityHeading(ped)
                local playerlocation = GetEntityForwardVector(PlayerPedId())
                local playerCoords = GetEntityCoords(ped)
                if distance < 3 and distance ~= -1  and player then
                    TriggerServerEvent('guille_gangs:requestarrest', GetPlayerServerId(player), playerheading, playerCoords, playerlocation)
                end
            elseif v == 'unarrest' then
                local player, distance = ESX.Game.GetClosestPlayer()
                local playerheading = GetEntityHeading(ped)
                local playerlocation = GetEntityForwardVector(PlayerPedId())
                local playerCoords = GetEntityCoords(ped)
                if distance < 3 and distance ~= -1  and player then
                    TriggerServerEvent('guille_gangs:requestrelease', GetPlayerServerId(player), playerheading, playerCoords, playerlocation)
                else
                    ESX.ShowNotification(_U("not_near"))
                end
            elseif v == 'search' then
                local player, distance = ESX.Game.GetClosestPlayer()
                if distance < 3 and distance ~= -1 and player then
                    OpenBodySearchMenu(player)
                else
                    ESX.ShowNotification(_U("not_near"))
                end
            elseif v == "vehiclein" then
                local player, distance = ESX.Game.GetClosestPlayer()
                if distance < 3 and distance ~= -1 and player then
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent('guille_gangs:putinvehicle', GetPlayerServerId(player))
                end
            elseif v == "vehicleout" then
                local player, distance = ESX.Game.GetClosestPlayer()
                if distance < 3 and distance ~= -1 and player then
                    TriggerServerEvent('guille_gangs:outfromveh', GetPlayerServerId(player))
                end
            elseif v == "escort" then
                local player, distance = ESX.Game.GetClosestPlayer()
                if distance < 3 and distance ~= -1  and player then
                    TriggerServerEvent('guille_gangs:escort', GetPlayerServerId(player))
                    if not isDragging then
                        ESX.Streaming.RequestAnimDict('switch@trevor@escorted_out', function()
                            TaskPlayAnim(PlayerPedId(), 'switch@trevor@escorted_out', '001215_02_trvs_12_escorted_out_idle_guard2', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                        end)
                        isDragging = true
                    else
                        Wait(500)
                        ClearPedTasks(PlayerPedId())
                        isDragging = false
                    end
                end
            end
        end, function(data, menu)
            menu.close()
        end)
    end
end, false)

RegisterKeyMapping('gangmenu', (_U("open_gang_me")), 'keyboard', 'F11')

RegisterNetEvent('guille_gangs:getarrested')
AddEventHandler('guille_gangs:getarrested', function(playerheading, playercoords, playerlocation)
	playerPed = GetPlayerPed(-1)
	SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(GetPlayerPed(-1), x, y, z - 1)
	SetEntityHeading(GetPlayerPed(-1), playerheading)
	Citizen.Wait(250)
	loadanimdict('mp_arrest_paired')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750 , 2, 0, 0, 0, 0)
	Citizen.Wait(3760)	
	handcuff = true
	loadanimdict('mp_arresting')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
end)

RegisterNetEvent('guille_gangs:doarrested')
AddEventHandler('guille_gangs:doarrested', function()
	Citizen.Wait(250)
	loadanimdict('mp_arrest_paired')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
	Citizen.Wait(3000)
end) 

RegisterNetEvent('guille_gangs:getuncuffed')
AddEventHandler('guille_gangs:getuncuffed', function(playerheading, playercoords, playerlocation)
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(GetPlayerPed(-1), x, y, z - 1)
	SetEntityHeading(GetPlayerPed(-1), playerheading)
	Citizen.Wait(250)
	loadanimdict('mp_arresting')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'b_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
	Citizen.Wait(5500)
	handcuff = false
	ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('guille_gangs:douncuffing')
AddEventHandler('guille_gangs:douncuffing', function()
	Citizen.Wait(250)
	loadanimdict('mp_arresting')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'a_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
	Citizen.Wait(5500)
	ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('guille_gangs:putInVehicle')
AddEventHandler('guille_gangs:putInVehicle', function()
	if handcuff then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if IsAnyVehicleNearPoint(coords, 5.0) then
			local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

			if DoesEntityExist(vehicle) then
				local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

				for i=maxSeats - 1, 0, -1 do
					if IsVehicleSeatFree(vehicle, i) then
						freeSeat = i
						break
					end
				end

				if freeSeat then
					TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				end
			end
		end
	end
end)

RegisterNetEvent('guille_gangs:OutVehicle')
AddEventHandler('guille_gangs:OutVehicle', function()
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		TaskLeaveVehicle(playerPed, vehicle, 16)
        Citizen.Wait(1000)
        loadanimdict('mp_arresting')
        TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
	end
end)

local drag = false
local dragUser = nil

RegisterNetEvent('guille_gangs:drag')
AddEventHandler('guille_gangs:drag', function(playerWhoDrag)
	if handcuff then
        drag = not drag
        dragUser = playerWhoDrag
	end
end)

Citizen.CreateThread(function()
	local wasDragged

	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if handcuff and drag then
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragUser))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(playerPed, targetPed, 11816, 0.10, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					wasDragged = true
				else
					Citizen.Wait(1000)
				end
			else
				wasDragged = false
				drag = false
				DetachEntity(playerPed, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(playerPed, true, false)
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if handcuff == true then
			--DisableControlAction(0, 1, true) -- Disable pan
			--DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 21, true)
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			--DisableControlAction(0, 32, true) -- W
			--DisableControlAction(0, 34, true) -- A
			--DisableControlAction(0, 31, true) -- S
			--DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			--DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		else
			Citizen.Wait(1500)
		end
	end
end)

function OpenBodySearchMenu(player)
    ESX.TriggerServerCallback('guille_gangs:getOtherPlayerData', function(data)
        local elements = {}

        for i=1, #data.accounts, 1 do
            if data.accounts[i].name == 'money' and data.accounts[i].money > 0 then
                table.insert(elements, {
                    label    =  _U("take_m")..'<strong><span style="color:green;">' ..ESX.Math.GroupDigits(ESX.Math.Round(data.accounts[i].money)).."$</span></strong>",
                    value    = 'money',
                    itemType = 'item_account',
                    amount   = data.accounts[i].money
                })
            end
            if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
                table.insert(elements, {
                    label    = _U("take_m_black")..'<strong><span style="color:red;">' ..ESX.Math.GroupDigits(ESX.Math.Round(data.accounts[i].money)).."$</span></strong>",
                    value    = 'black_money',
                    itemType = 'item_account',
                    amount   = data.accounts[i].money
                })
            end
        end

        table.insert(elements, {label = '-- Weapons --'})

        for i=1, #data.weapons, 1 do
            table.insert(elements, {
                label    = _U("take_wweap") ..ESX.GetWeaponLabel(data.weapons[i].name).. " - " ..data.weapons[i].ammo .." bala(s)",
                value    = data.weapons[i].name,
                itemType = 'item_weapon',
                amount   = data.weapons[i].ammo
            })
        end

        table.insert(elements, {label = ('-- Inventario --')})

        for i=1, #data.inventory, 1 do
            if data.inventory[i].count > 0 then
                table.insert(elements, {
                    label    = _U("take_item_rob") .. data.inventory[i].label ..' x'..data.inventory[i].count,
                    value    = data.inventory[i].name,
                    itemType = 'item_standard',
                    amount   = data.inventory[i].count
                })
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
            title    = _U('Search'),
            align    = 'bottom-right',
            elements = elements
        }, function(data, menu)
            if data.current.value then
                TriggerServerEvent('guille_gangs:server:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
                OpenBodySearchMenu(player)
            end
        end, function(data, menu)
            menu.close()
        end)
    end, GetPlayerServerId(player))
    RequestAnimDict('anim@gangops@facility@servers@bodysearch@')
    while not HasAnimDictLoaded('anim@gangops@facility@servers@bodysearch@') do Wait(0) end
        TaskPlayAnim(GetPlayerPed(-1), 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 1.0, 3000, 49, 0, 0, 0, 0)

    Wait(3000)
	
end
