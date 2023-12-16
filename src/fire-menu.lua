--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

local isAdmin = false
local isSpawn = false
local playerLocations = { coords = nil, heading = nil }

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

RegisterNUICallback("giveAllWeapon", function(data, cb)
    local weapons = { 'WEAPON_UNARMED', 'WEAPON_KNIFE', 'WEAPON_KNUCKLE', 'WEAPON_NIGHTSTICK', 'WEAPON_HAMMER',
        'WEAPON_BAT',
        'WEAPON_GOLFCLUB', 'WEAPON_CROWBAR', 'WEAPON_BOTTLE', 'WEAPON_DAGGER', 'WEAPON_HATCHET', 'WEAPON_MACHETE',
        'WEAPON_FLASHLIGHT', 'WEAPON_SWITCHBLADE', 'WEAPON_PISTOL', 'WEAPON_PISTOL_MK2', 'WEAPON_COMBATPISTOL',
        'WEAPON_APPISTOL', 'WEAPON_PISTOL50', 'WEAPON_SNSPISTOL', 'WEAPON_HEAVYPISTOL', 'WEAPON_VINTAGEPISTOL',
        'WEAPON_STUNGUN', 'WEAPON_FLAREGUN', 'WEAPON_MARKSMANPISTOL', 'WEAPON_REVOLVER', 'WEAPON_MICROSMG', 'WEAPON_SMG',
        'WEAPON_MINISMG', 'WEAPON_SMG_MK2', 'WEAPON_ASSAULTSMG', 'WEAPON_MG', 'WEAPON_COMBATMG', 'WEAPON_COMBATMG_MK2',
        'WEAPON_COMBATPDW', 'WEAPON_GUSENBERG', 'WEAPON_RAYPISTOL', 'WEAPON_MACHINEPISTOL', 'WEAPON_ASSAULTRIFLE',
        'WEAPON_ASSAULTRIFLE_MK2', 'WEAPON_CARBINERIFLE', 'WEAPON_CARBINERIFLE_MK2', 'WEAPON_ADVANCEDRIFLE',
        'WEAPON_SPECIALCARBINE', 'WEAPON_BULLPUPRIFLE', 'WEAPON_COMPACTRIFLE', 'WEAPON_PUMPSHOTGUN',
        'WEAPON_SAWNOFFSHOTGUN',
        'WEAPON_BULLPUPSHOTGUN', 'WEAPON_ASSAULTSHOTGUN', 'WEAPON_MUSKET', 'WEAPON_HEAVYSHOTGUN', 'WEAPON_DBSHOTGUN',
        'WEAPON_SNIPERRIFLE', 'WEAPON_HEAVYSNIPER', 'WEAPON_HEAVYSNIPER_MK2', 'WEAPON_MARKSMANRIFLE',
        'WEAPON_GRENADELAUNCHER', 'WEAPON_GRENADELAUNCHER_SMOKE', 'WEAPON_RPG', 'WEAPON_STINGER', 'WEAPON_FIREWORK',
        'WEAPON_HOMINGLAUNCHER', 'WEAPON_GRENADE', 'WEAPON_STICKYBOMB', 'WEAPON_PROXMINE', 'WEAPON_MINIGUN',
        'WEAPON_RAILGUN', 'WEAPON_POOLCUE', 'WEAPON_BZGAS', 'WEAPON_SMOKEGRENADE', 'WEAPON_MOLOTOV',
        'WEAPON_FIREEXTINGUISHER', 'WEAPON_PETROLCAN', 'WEAPON_SNOWBALL', 'WEAPON_FLARE', 'WEAPON_BALL' }
    for index, weapon in ipairs(weapons) do
        local weaponHash = GetHashKey(weapon)
        GiveWeaponToPed(PlayerPedId(), weaponHash, 3000)
    end
    cb("ok")
end)

RegisterNUICallback("removeAllWeapon", function(data, cb)
    RemoveAllPedWeapons(PlayerPedId(), true)
    cb("ok")
end)

RegisterNUICallback("getPlayerCoords", function(data, cb)
    local playerCoord = GetEntityCoords(PlayerPedId())
    local headingCoord = GetEntityHeading(PlayerPedId())

    playerLocations.coords = playerCoord
    playerLocations.heading = headingCoord

    updatePlayerCoords()

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
        action = "updateAdminStatus",
        godmode = GetPlayerInvincible(PlayerId()),
        visible = IsEntityVisible(PlayerPedId())
    })
end

function updatePlayerCoords()
    SendNUIMessage({
        action = "updatePlayerCoords",
        location = vector4(playerLocations.coords.x, playerLocations.coords.y, playerLocations.coords.z,
            playerLocations.heading),
    })
    print('are')
end

---------------- Thread ----------------
Citizen.CreateThread(function()
    if not isSpawn then
        isSpawn = true
        TriggerServerEvent("FIREAC:checkIsAdmin")
    end
end)
