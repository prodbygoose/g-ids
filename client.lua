Config = Config or {}

local showIDs = false
local idThread

RegisterCommand(Config.ToggleCommand, function()
    showIDs = not showIDs 
    if showIDs then
        StartIDThread() 
    else

        if idThread then
            TerminateThread(idThread)
            idThread = nil
        end
    end
end, false)

function StartIDThread()
    idThread = Citizen.CreateThread(function()
        while showIDs do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local activePlayers = GetActivePlayers()
            local numPlayers = #activePlayers

            for i = 1, numPlayers do
                local playerId = activePlayers[i]
                local targetPed = GetPlayerPed(playerId)
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)

                if IsEntityOnScreen(targetPed) and not IsEntityOccluded(targetPed) and HasEntityClearLosToEntity(playerPed, targetPed, 17) then
                    if distance < Config.DisplayDistance then
                        local boneIndex = GetPedBoneIndex(targetPed, 12844) 
                        local headCoords = GetWorldPositionOfEntityBone(targetPed, boneIndex)
                        local targetDisplayCoords = vector3(headCoords.x, headCoords.y, headCoords.z + 0.5)
                        DrawText3D(targetDisplayCoords, string.format("[ %d ]", GetPlayerServerId(playerId)), 255, 255, 255, 150) -- 50% opacity
                    end
                end
            end
            Wait(0) 
        end
    end)
end

function DrawText3D(coords, text, r, g, b, a)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local distance = #(GetGameplayCamCoords() - coords)
    local scale = 1 / distance * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    scale = scale * 2

    if onScreen then
        SetTextScale(0.35 * scale, 0.35 * scale)
        SetTextFont(1)
        SetTextProportional(1)
        SetTextColour(r, g, b, a)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end
