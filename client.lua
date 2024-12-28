-- state for displaying IDs
local showIDs = false

-- toggle ID 
RegisterCommand('ids', function()
    showIDs = not showIDs -- Toggle state
    if showIDs then
        print("Player IDs are now visible.")
    else
        print("Player IDs are now hidden.")
    end
end, false)

-- IDs above players' heads
CreateThread(function()
    while true do
        if showIDs then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for _, playerId in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(playerId)
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)

                -- display IDs for players within 25 meters
                if distance < 25.0 then
                    -- Get head bone position and add offset
                    local boneIndex = GetPedBoneIndex(targetPed, 12844) -- Head bone index
                    local headCoords = GetWorldPositionOfEntityBone(targetPed, boneIndex)
                    local targetDisplayCoords = vector3(headCoords.x, headCoords.y, headCoords.z + 0.5)

                    -- text above the player's head
                    DrawText3D(targetDisplayCoords, string.format("[ %d ]", GetPlayerServerId(playerId)), 255, 255, 255, 150) -- 50% opacity
                end
            end
        end
        Wait(0) -- every frame
    end
end)

-- draw 3D text
function DrawText3D(coords, text, r, g, b, a)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local distance = #(GetGameplayCamCoords() - coords)
    local scale = 1 / distance * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    -- text is scaled correctly for visibility
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
