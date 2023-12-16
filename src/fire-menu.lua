--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

local isAdmin = false
local isSpawn = false

---------------- Net Events ----------------
RegisterNetEvent("FIREAC:allowToOpen")
AddEventHandler("FIREAC:allowToOpen", function()
    isAdmin = true
end)

---------------- Open Menu ----------------
RegisterCommand("fireacmenu", function()
    if isAdmin then
        openAdminMenu()
    end
end, false)

RegisterKeyMapping("fireacmenu", "FIREAC admin menu", "keyboard", FIREAC.AdminMenu.Key)

---------------- NUI Call Backs ----------------
RegisterNUICallback("onCloseMenu", function(data, cb)
    SetNuiFocus(false, false)

    cb("ok")
end)

RegisterNUICallback("getAdminStatus", function(data, cb)
    updateAdminStatus()

    cb("ok")
end)

RegisterNUICallback("godmode", function(data, cb)
    local playerPed = PlayerPedId()
    local invincible = not GetPlayerInvincible(PlayerId())

    SetEntityInvincible(playerPed, invincible)

    cb("ok")
end)

RegisterNUICallback("invisible", function(data, cb)
    local playerPed = PlayerPedId()
    local visible = IsEntityVisible(playerPed)

    SetEntityVisible(playerPed, not visible)

    cb("ok")
end)

RegisterNUICallback("suicide", function(data, cb)
    local playerPed = PlayerPedId()

    SetEntityHealth(playerPed, 0)
    cb("ok")
end)

RegisterNUICallback("heal", function(data, cb)
    local playerPed = PlayerPedId()

    SetEntityHealth(playerPed, GetPedMaxHealth(playerPed))
    cb("ok")
end)

---------------- Functions ----------------
function openAdminMenu()
    SendNUIMessage({
        action = "openUI",
    })
    SetNuiFocus(true, true)
end

function updateAdminStatus()
    SendNUIMessage({
        action = "updateData",
        godmode = GetPlayerInvincible(PlayerId()),
        visible = IsEntityVisible(PlayerPedId())
    })
end

---------------- Thread ----------------
Citizen.CreateThread(function()
    if not isSpawn then
        isSpawn = true
        TriggerServerEvent("FIREAC:checkIsAdmin")
    end
end)
