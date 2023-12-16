--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

local isAdmin = false
local isSpawn = false

RegisterNetEvent('FIREAC:allowToOpen')
AddEventHandler('FIREAC:allowToOpen', function()
    isAdmin = true
end)

RegisterCommand('fireacmenu', function()
    if isAdmin then
        openAdminMenu()
    end
end, false)

RegisterKeyMapping("fireacmenu", "FIREAC admin menu", "keyboard", FIREAC.AdminMenu.Key)

RegisterNUICallback('onCloseMenu', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('getAdminStatus', function()
    updateAdminStatus()
end)

function openAdminMenu()
    SendNUIMessage({
        action = 'openUI',
    })
    SetNuiFocus(true, true)
end

function updateAdminStatus()
    SendNUIMessage({
        action = 'updateData',
        godmode = GetPlayerInvincible(PlayerId()),
        invisible = IsEntityVisible(PlayerPedId())
    })
end

Citizen.CreateThread(function()
    if not isSpawn then
        isSpawn = true
        TriggerServerEvent('FIREAC:checkIsAdmin')
    end
end)
