function notify(txt)
    SetNotificationTextEntry('STRING')
	AddTextComponentString(txt)
	DrawNotification(false, true)
end

function ShowFloatingHelpNotification(msg, coords)
	SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z + 0.7)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(2, false, true, -1)
end

function loadanimdict(dictname)
	if not HasAnimDictLoaded(dictname) then
		RequestAnimDict(dictname) 
		while not HasAnimDictLoaded(dictname) do 
			Citizen.Wait(1)
		end
	end
end
