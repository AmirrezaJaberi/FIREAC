-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2024 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

-- Variable declarations
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

-- Event: Allow opening the admin menu
RegisterNetEvent("FIREAC:allowToOpen")
AddEventHandler("FIREAC:allowToOpen", function()
    isAdmin = true
end)

-- Event: Receive player data for the admin menu
RegisterNetEvent("FIREAC:sendAllPlayerData")
AddEventHandler("FIREAC:sendAllPlayerData", function(playerList)
    updatePlayerList(playerList)
end)

-- Event: Open player data menu in the admin UI
RegisterNetEvent("FIREAC:openPlayerData")
AddEventHandler("FIREAC:openPlayerData", function(data)
    openPlayerAction(data)
end)

-- Event: Spectate a player
RegisterNetEvent("FIREAC:spectatePlayer")
AddEventHandler("FIREAC:spectatePlayer", function(target, coords)
    if target and coords then
        spectatePlayer(target, coords)
    end
end)

-- Event: Update ban list data
RegisterNetEvent("FIREAC:updateBanListData")
AddEventHandler("FIREAC:updateBanListData", function(banList)
    updateBanListData(banList)
end)

-- Event: Update admin data
RegisterNetEvent("FIREAC:updateAdminData")
AddEventHandler("FIREAC:updateAdminData", function(adminList)
    updateAdminData(adminList)
end)

-- Event: Update unban access data
RegisterNetEvent("FIREAC:updateUnbanAccess")
AddEventHandler("FIREAC:updateUnbanAccess", function(unbanList)
    updateUnbanAccess(unbanList)
end)

-- Event: Update whitelist data
RegisterNetEvent("FIREAC:updateWhiteList")
AddEventHandler("FIREAC:updateWhiteList", function(whiteList)
    updateWhiteList(whiteList)
end)

---------------- Open Menu ----------------

-- Register the command to open the admin menu
RegisterCommand("fireacmenu", function()
    if isAdmin then
        openAdminMenu()
    end
end, false)

-- Register the key mapping to open the admin menu
RegisterKeyMapping("fireacmenu", "FIREAC admin menu", "keyboard", FIREAC.AdminMenu.Key)

---------------- NUI Call Backs ----------------

-- Callback: Close menu
RegisterNUICallback("onCloseMenu", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

-- Callback: Get admin status
RegisterNUICallback("getAdminStatus", function(data, cb)
    updateAdminStatus()
    cb("ok")
end)

-- Callback: Toggle god mode
RegisterNUICallback("godmode", function(data, cb)
    local playerPed = PlayerPedId()
    local invincible = not GetPlayerInvincible(PlayerId())

    SetEntityInvincible(playerPed, invincible)

    cb("ok")
end)

-- Callback: Toggle invisibility
RegisterNUICallback("invisible", function(data, cb)
    local playerPed = PlayerPedId()
    local visible = IsEntityVisible(playerPed)

    SetEntityVisible(playerPed, not visible)

    cb("ok")
end)

-- Callback: Suicide
RegisterNUICallback("suicide", function(data, cb)
    local playerPed = PlayerPedId()

    SetEntityHealth(playerPed, 0)
    cb("ok")
end)

-- Callback: Heal
RegisterNUICallback("heal", function(data, cb)
    local playerPed = PlayerPedId()

    SetEntityHealth(playerPed, GetPedMaxHealth(playerPed))
    cb("ok")
end)

-- Callback: Give all weapons
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

-- Callback: Remove all weapons
RegisterNUICallback("removeAllWeapon", function(data, cb)
    RemoveAllPedWeapons(PlayerPedId(), true)
    cb("ok")
end)

-- Callback: Get player coordinates
RegisterNUICallback("getPlayerCoords", function(data, cb)
    local playerCoord = GetEntityCoords(PlayerPedId())
    local headingCoord = GetEntityHeading(PlayerPedId())

    playerLocations.coords = playerCoord
    playerLocations.heading = headingCoord

    updatePlayerCoords()

    cb("ok")
end)

-- Callback: Get all players' data
RegisterNUICallback("getAllPlayersData", function(data, cb)
    TriggerServerEvent("FIREAC:getAllPlayerData")
    cb("ok")
end)

-- Callback: Get player data
RegisterNUICallback("getPlayerData", function(data, cb)
    TriggerServerEvent("FIREAC:getPlayerData", data.playerId)
    cb("ok")
end)

-- Callback: Spectate
RegisterNUICallback("spectate", function(data, cb)
    if InSpectatorMode then
        exitSpectate()
    else
        TriggerServerEvent('FIREAC:requestSpectate', data.playerId)
    end
    cb("ok")
end)

-- Callback: Ban player
RegisterNUICallback("ban", function(data, cb)
    TriggerServerEvent("FIREAC:banPlayerByAdmin", data.playerId)
    cb("ok")
end)

-- Callback: Add player to admin
RegisterNUICallback("addToAdmin", function(data, cb)
    TriggerServerEvent("FIREAC:addPlayerAsAdmin", data.playerId)
    cb("ok")
end)

-- Callback: Add player to whitelist
RegisterNUICallback("addToWhiteList", function(data, cb)
    TriggerServerEvent("FIREAC:addPlayerAsWhiteList", data.playerId)
    cb("ok")
end)

-- Callback: Add player to unban access
RegisterNUICallback("addToUnban", function(data, cb)
    TriggerServerEvent("FIREAC:addPlayerUnbanAccess", data.playerId)
    cb("ok")
end)

-- Callback: Delete vehicles
RegisterNUICallback("delete_vehicles", function(data, cb)
    TriggerServerEvent("FIREAC:deleteEntitys", "vehicles")
    cb("ok")
end)

-- Callback: Delete objects
RegisterNUICallback("delete_objects", function(data, cb)
    TriggerServerEvent("FIREAC:deleteEntitys", "props")
    cb("ok")
end)

-- Callback: Delete peds
RegisterNUICallback("delete_peds", function(data, cb)
    TriggerServerEvent("FIREAC:deleteEntitys", "peds")
    cb("ok")
end)

-- Callback: Delete all entities
RegisterNUICallback("delete_all_entity", function(data, cb)
    TriggerServerEvent("FIREAC:deleteEntitys", "vehicles")
    TriggerServerEvent("FIREAC:deleteEntitys", "props")
    TriggerServerEvent("FIREAC:deleteEntitys", "peds")
    cb("ok")
end)

-- Callback: Teleport to waypoint
RegisterNUICallback("teleportToWaypoint", function(data, cb)
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        SetEntityCoords(PlayerPedId(), GetBlipInfoIdCoord(waypoint))
    end
    cb("ok")
end)

-- Callback: Teleport to coordinates
RegisterNUICallback("teleportToCoords", function(data, cb)
    SetEntityCoords(PlayerPedId(), data.x, data.y, data.z)
    cb("ok")
end)

-- Callback: Toggle night vision
RegisterNUICallback("night", function(data, cb)
    if not GetUsingnightvision() then
        SetNightvision(1)
    else
        SetNightvision(0)
    end
    cb("ok")
end)

-- Callback: Toggle thermal vision
RegisterNUICallback("thermal", function(data, cb)
    if not GetUsingseethrough() then
        SetSeethrough(1)
    else
        SetSeethrough(0)
    end
    cb("ok")
end)

-- Callback: Spawn vehicle for self
RegisterNUICallback("spawnVehicleForSelf", function(data, cb)
    TriggerServerEvent("FIREAC:spawnVehicle", data)
    cb("ok")
end)

-- Callback: Spawn vehicle for others
RegisterNUICallback("spawnVehicleOthers", function(data, cb)
    TriggerServerEvent("FIREAC:spawnVehicle", data)
    cb("ok")
end)

-- Callback: Get ban list data
RegisterNUICallback("getBanListData", function(data, cb)
    TriggerServerEvent("FIREAC:getBanListData")
    cb("ok")
end)

-- Callback: Unban selected player
RegisterNUICallback("unbanSelectedPlayer", function(data, cb)
    TriggerServerEvent("FIREAC:unbanSelectedPlayer", data.banID)
    cb("ok")
end)

-- Callback: Get admin list data
RegisterNUICallback("getAdminListData", function(data, cb)
    TriggerServerEvent("FIREAC:getAdminListData")
    cb("ok")
end)

-- Callback: Remove selected admin
RegisterNUICallback("removeSelectedAdmin", function(data, cb)
    TriggerServerEvent("FIREAC:removeSelectedAdmin", data.id)
    cb("ok")
end)

-- Callback to get unban access data
RegisterNUICallback("getUnbanAccessData", function(data, cb)
    -- Trigger server event to get unban access data
    TriggerServerEvent("FIREAC:getUnbanAccessData")
    cb("ok")
end)

-- Callback to remove unban access for a player
RegisterNUICallback("removeUnbanAccess", function(data, cb)
    -- Trigger server event to remove unban access for the specified player
    TriggerServerEvent("FIREAC:removeUnbanAccess", data.id)
    cb("ok")
end)

-- Callback to get whitelist data
RegisterNUICallback("getWhitelistData", function(data, cb)
    -- Trigger server event to get whitelist data
    TriggerServerEvent("FIREAC:getWhitelistData")
    cb("ok")
end)

-- Callback to remove a user from the whitelist
RegisterNUICallback("removeWhitelistUser", function(data, cb)
    -- Trigger server event to remove the specified user from the whitelist
    TriggerServerEvent("FIREAC:removeWhitelistUser", data.id)
    cb("ok")
end)

---------------- Functions ----------------

-- Function to open the admin menu
function openAdminMenu()
    -- Send NUI message to open the UI
    SendNUIMessage({
        action = "openUI",
    })
    -- Set focus on NUI
    SetNuiFocus(true, true)
end

-- Function to open the player action menu
function openPlayerAction(data)
    -- Send NUI message to open the player action menu with provided data
    SendNUIMessage({
        action = "openPlayerActionMenu",
        data = data
    })
end

-- Function to update admin status
function updateAdminStatus()
    -- Send NUI message to update admin status with godmode and visibility
    SendNUIMessage({
        action = "updateAdminStatus",
        godmode = GetPlayerInvincible(PlayerId()),
        visible = IsEntityVisible(PlayerPedId())
    })
end

-- Function to update player coordinates
function updatePlayerCoords()
    -- Send NUI message to update player coordinates
    SendNUIMessage({
        action = "updatePlayerCoords",
        location = vector4(playerLocations.coords.x, playerLocations.coords.y, playerLocations.coords.z,
            playerLocations.heading),
    })
end

-- Function to update player list
function updatePlayerList(playerList)
    -- Send NUI message to update player list
    SendNUIMessage({
        action = "updatePlayerList",
        playerList = playerList,
    })
end

-- Function to update ban list data
function updateBanListData(banList)
    -- Send NUI message to update ban list
    SendNUIMessage({
        action = "updateBanList",
        banList = banList,
    })
end

-- Function to update admin data
function updateAdminData(adminList)
    -- Send NUI message to update admin data
    SendNUIMessage({
        action = "updateAdminData",
        adminList = adminList,
    })
end

-- Function to update unban access data
function updateUnbanAccess(unbanList)
    -- Send NUI message to update unban access data
    SendNUIMessage({
        action = "updateUnbanAccess",
        unbanList = unbanList,
    })
end

-- Function to update whitelist data
function updateWhiteList(whiteList)
    -- Send NUI message to update whitelist data
    SendNUIMessage({
        action = "updateWhiteList",
        whiteList = whiteList,
    })
end

-- Function to spectate a player
function spectatePlayer(target, coords)
    -- Initialize camera
    cam = cam or CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, coords.x, coords.y, coords.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Wait(500)

    -- Get player ID from server ID
    local player = GetPlayerFromServerId(target)
    if player == -1 then return end

    -- Get player ped
    local ped = GetPlayerPed(player)
    NetworkSetInSpectatorMode(true, ped)
    InSpectatorMode = true
    TargetSpectate = target
    handelSpectate(player, ped)
end

-- Function to update target checks during spectate
function updateTargetChecks()
    Citizen.CreateThread(function()
        while InSpectatorMode do
            Citizen.Wait(1000)
            health, maxhealth, armor = GetEntityHealth(targetPed), GetEntityMaxHealth(targetPed), GetPedArmour(targetPed)
            handleVoiceChannel(TargetSpectate)
        end
    end)
end

-- Function to handle voice channel during spectate
function handleVoiceChannel(target)
    local channel = MumbleGetVoiceChannelFromServerId(target)
    if currentVoiceChannel ~= channel then
        currentVoiceChannel = channel
        MumbleAddVoiceChannelListen(channel)
    end
end

-- Function to handle spectate
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

-- Function to convert polar coordinates to world coordinates
function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
    local polarAngleRad, azimuthAngleRad = polarAngleDeg * math.pi / 180.0, azimuthAngleDeg * math.pi / 180.0

    local pos = {
        x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
        y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
        z = entityPosition.z - radius * math.cos(azimuthAngleRad)
    }

    return pos
end

-- Function to draw text on the screen
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

-- Function to exit spectate mode
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

-- Citizen thread to check if spawned
Citizen.CreateThread(function()
    if not isSpawn then
        isSpawn = true
        -- Trigger server event to check if the player is an admin
        TriggerServerEvent("FIREAC:checkIsAdmin")
    end
end)
