--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

local isAdmin = false
local isSpawn = false
local playerLocations = { coords = nil, heading = nil }

local cam = nil
local InSpectatorMode = false
local TargetSpectate = nil
local targetPed = nil
local currentVoiceChannel = nil
local health, maxhealth, armor = nil, nil, nil
local radius = -1
local polarAngleDeg, azimuthAngleDeg = 0, 0

---------------- Net Events ----------------
RegisterNetEvent("FIREAC:allowToOpen")
AddEventHandler("FIREAC:allowToOpen", function()
    isAdmin = true
end)

RegisterNetEvent("FIREAC:sendAllPlayerData")
AddEventHandler("FIREAC:sendAllPlayerData", function(playerList)
    updatePlayerList(playerList)
end)

RegisterNetEvent("FIREAC:openPlayerData")
AddEventHandler("FIREAC:openPlayerData", function(data)
    openPlayerAction(data)
end)

RegisterNetEvent("FIREAC:spectatePlayer")
AddEventHandler("FIREAC:spectatePlayer", function(target, coords)
    if target and coords then
        spectatePlayer(target, coords)
    end
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

RegisterNUICallback("getAllPlayersData", function(data, cb)
    TriggerServerEvent("FIREAC:getAllPlayerData")
    cb("ok")
end)

RegisterNUICallback("getPlayerData", function(data, cb)
    TriggerServerEvent("FIREAC:getPlayerData", data.playerId)
    cb("ok")
end)

RegisterNUICallback("spectate", function(data, cb)
    if InSpectatorMode then
        exitSpectate()
    else
        TriggerServerEvent('FIREAC:requestSpectate', data.playerId)
    end
    cb("ok")
end)

RegisterNUICallback("ban", function(data, cb)
    TriggerServerEvent("FIREAC:banPlayerByAdmin", data.playerId)
    cb("ok")
end)

RegisterNUICallback("addToAdmin", function(data, cb)
    TriggerServerEvent("FIREAC:addPlayerAsAdmin", data.playerId)
    cb("ok")
end)

RegisterNUICallback("addToWhiteList", function(data, cb)
    TriggerServerEvent("FIREAC:addPlayerAsWhiteList", data.playerId)
    cb("ok")
end)

RegisterNUICallback("addToUnban", function(data, cb)
    TriggerServerEvent("FIREAC:addPlayerUnbanAccess", data.playerId)
    cb("ok")
end)

RegisterNUICallback("delete_vehicles", function(data, cb)
    TriggerServerEvent("FIREAC:deleteEntitys", "vehicles")
    cb("ok")
end)

RegisterNUICallback("delete_objects", function(data, cb)
    TriggerServerEvent("FIREAC:deleteEntitys", "props")
    cb("ok")
end)

RegisterNUICallback("delete_peds", function(data, cb)
    TriggerServerEvent("FIREAC:deleteEntitys", "peds")
    cb("ok")
end)

RegisterNUICallback("delete_all_entity", function(data, cb)
    TriggerServerEvent("FIREAC:deleteEntitys", "vehicles")
    TriggerServerEvent("FIREAC:deleteEntitys", "props")
    TriggerServerEvent("FIREAC:deleteEntitys", "peds")
    cb("ok")
end)

RegisterNUICallback("teleportToWaypoint", function(data, cb)
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        SetEntityCoords(PlayerPedId(), GetBlipInfoIdCoord(waypoint))
    end
    cb("ok")
end)

RegisterNUICallback("teleportToCoords", function(data, cb)
    SetEntityCoords(PlayerPedId(), data.x, data.y, data.z)
    cb("ok")
end)

RegisterNUICallback("night", function(data, cb)
    if not GetUsingnightvision() then
        SetNightvision(1)
    else
        SetNightvision(0)
    end
    cb("ok")
end)

RegisterNUICallback("thermal", function(data, cb)
    if not GetUsingseethrough() then
        SetSeethrough(1)
    else
        SetSeethrough(0)
    end
    cb("ok")
end)

---------------- Functions ----------------
function openAdminMenu()
    SendNUIMessage({
        action = "openUI",
    })
    SetNuiFocus(true, true)
end

function openPlayerAction(data)
    SendNUIMessage({
        action = "openPlayerActionMenu",
        data = data
    })
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
end

function updatePlayerList(playerList)
    SendNUIMessage({
        action = "updatePlayerList",
        playerList = playerList,
    })
end

function spectatePlayer(target, coords)
    cam = cam or CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, coords.x, coords.y, coords.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Wait(500)

    local player = GetPlayerFromServerId(target)
    if player == -1 then return end

    local ped = GetPlayerPed(player)
    NetworkSetInSpectatorMode(true, ped)
    InSpectatorMode = true
    TargetSpectate = target
    handelSpectate(player, ped)
end

function updateTargetChecks()
    Citizen.CreateThread(function()
        while InSpectatorMode do
            Citizen.Wait(1000)
            health, maxhealth, armor = GetEntityHealth(targetPed), GetEntityMaxHealth(targetPed), GetPedArmour(targetPed)
            handleVoiceChannel(TargetSpectate)
        end
    end)
end

function handleVoiceChannel(target)
    local channel = MumbleGetVoiceChannelFromServerId(target)
    if currentVoiceChannel ~= channel then
        currentVoiceChannel = channel
        MumbleAddVoiceChannelListen(channel)
    end
end

function handelSpectate(player, ped)
    Citizen.CreateThread(function()
        targetPed = GetPlayerPed(player)
        updateTargetChecks()

        while InSpectatorMode do
            Citizen.Wait(5)
            local coords = GetEntityCoords(targetPed)

            if not DoesEntityExist(ped) then
                exitSpectate()
            end

            DisableControlAction(2, 37, true)

            if IsControlPressed(2, 241) then
                radius = radius + 2.0
            end

            if IsControlPressed(2, 242) then
                radius = radius - 2.0
            end

            radius = math.max(radius, -1)

            local xMagnitude, yMagnitude = GetDisabledControlNormal(0, 1), GetDisabledControlNormal(0, 2)
            polarAngleDeg, azimuthAngleDeg = polarAngleDeg + xMagnitude * 10, azimuthAngleDeg + yMagnitude * 10

            polarAngleDeg = (polarAngleDeg >= 360) and 0 or polarAngleDeg
            azimuthAngleDeg = (azimuthAngleDeg >= 360) and 0 or azimuthAngleDeg

            local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)

            SetCamCoord(cam, nextCamLocation.x, nextCamLocation.y, nextCamLocation.z)
            PointCamAtEntity(cam, targetPed)

            if health and maxhealth and armor then
                Draw({
                    'Health' .. ': ~g~' .. health .. '/' .. maxhealth,
                    'Armor' .. ': ~b~' .. armor,
                    "To ~r~ exit ~s~ press spectate button again"
                })
            end
        end
    end)
end

function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
    local polarAngleRad, azimuthAngleRad = polarAngleDeg * math.pi / 180.0, azimuthAngleDeg * math.pi / 180.0

    local pos = {
        x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
        y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
        z = entityPosition.z - radius * math.cos(azimuthAngleRad)
    }

    return pos
end

function Draw(text)
    for i, theText in pairs(text) do
        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.0, 0.30)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(theText)
        EndTextCommandDisplayText(0.3, 0.7 + (i / 30))
    end
end

function exitSpectate()
    if InSpectatorMode then
        InSpectatorMode, TargetSpectate, targetPed = false, nil, nil
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 0, true, true)
        NetworkSetInSpectatorMode(false)

        if currentVoiceChannel then
            local serverId = GetPlayerServerId(ply)
            MumbleRemoveVoiceChannelListen(serverId)
            currentVoiceChannel = nil
        end
    end
end

---------------- Thread ----------------
Citizen.CreateThread(function()
    if not isSpawn then
        isSpawn = true
        TriggerServerEvent("FIREAC:checkIsAdmin")
    end
end)
