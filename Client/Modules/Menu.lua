
local GUI = {}
GUI.Time = 0



RegisterNetEvent("guille_cont:client:open")
AddEventHandler("guille_cont:client:open", function(title, data, cb, useCoords, coords)
    local datas = -1
    if title == nil then
        log("error", "Title does not exist")
        return
    end
    if useCoords == nil then
        log("error", "Using coords not set, it must be true or false")
        return
    end
    for k,v in pairs(data) do
        datas = datas + 1
        if v.toDo == nil then
            log("error", "The data toDo does not exist in table data, read the guille_contextmenu docs")
            return
        end
        v.toDo = v.toDo:gsub('"', "'")
    end
    if useCoords then
        log("info", "Menu created")
        local _, screenPox, ScreenPoy = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 1.5)
        SendNUIMessage({
            title = title;
            data = data;
            cb = cb;
            x = screenPox * 100;
            y = ScreenPoy * 100;
            useCoords = useCoords;
        })
    else
        log("Menu created")
        SendNUIMessage({
            title = title;
            data = data;
            cb = cb;
            useCoords = useCoords;
        })
        isThis.menuOpened = true
        TriggerEvent("openMenu", datas)
    end 
end)

RegisterNUICallback("close", function(cb)
    PlaySoundFrontend(-1, 'Highlight_Cancel','DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    isThis.menuOpened = false
end)

RegisterNetEvent("openMenu")
AddEventHandler("openMenu", function(num)
    local selected = 0
    Citizen.CreateThread(function()
        Citizen.Wait(500)
        while isThis.menuOpened do
            if IsControlJustPressed(0, 18) and (GetGameTimer() - GUI.Time) > 500 then
                SendNUIMessage({
                    toExecute = tostring(selected);
                })
            end

            if IsControlJustPressed(0, 177) and (GetGameTimer() - GUI.Time) > 150 then
                SendNUIMessage({
                    move = "no"
                })
            end

            if IsControlJustPressed(0, 27) and (GetGameTimer() - GUI.Time) > 150 then
                -- SUBIR
                if selected == 0 then
                    selected = num
                    SendNUIMessage({
                        selected = tostring(num);
                    })
                
                elseif selected ~= 0 then
                    selected = selected - 1
                    SendNUIMessage({
                        selected = tostring(selected);
                    })
                end
            end

            if IsControlJustPressed(0, 173) and (GetGameTimer() - GUI.Time) > 150 then
                -- BAJAR
                if selected == num then
                    selected = 0
                    SendNUIMessage({
                        selected = tostring(0);
                    })
                elseif selected ~= num then
                    selected = selected + 1
                    SendNUIMessage({
                        selected = tostring(selected);
                    })
                end
                
            end
            Citizen.Wait(0)
        end
    end)
end)