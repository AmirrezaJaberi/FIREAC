--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2023 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

local SPAWN = false
local CHECK_SPAWN = true
local TRACK = 0

Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) or IsPlayerSwitchInProgress() do
        Citizen.Wait(0)
    end
    SPAWN = true
    CHECK_SPAWN = false
end)

Citizen.CreateThread(function()
    while true do
        if CHECK_SPAWN and not SPAWN then
            TriggerServerEvent('FIREAC:CheckIsAdmin')
            Wait(10000)
            SPAWN = true
            CHECK_SPAWN = false
            break
        end
        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local doesPlayerExist = DoesEntityExist(playerPed)
        local isPlayerInVehicle = IsPedInAnyVehicle(playerPed, false)
        local isSpawned = SPAWN
        local isPlayerSwitchInProgress = IsPlayerSwitchInProgress()
        local isCameraControlDisabled = IsPlayerCamControlDisabled()

        if FIREAC.AntiTeleport and not isPlayerInVehicle and isSpawned and not isPlayerSwitchInProgress and not isCameraControlDisabled then
            local currentPosition = GetEntityCoords(playerPed)
            Citizen.Wait(3000)
            local newPlayerPed = PlayerPedId()
            local newPosition = GetEntityCoords(newPlayerPed)
            local distance = #(vector3(currentPosition) - vector3(newPosition))

            if distance > FIREAC.MaxFootDistance and not IsEntityDead(playerPed) and not IsPedInParachuteFreeFall(playerPed) and not IsPedJumpingOutOfVehicle(playerPed) and playerPed == newPlayerPed then
                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TeleportPunishment, "Anti Teleport",
                    "Used teleport hacks")
            end
        end

        if FIREAC.AntiSuperJump and doesPlayerExist and isSpawned and not isPlayerSwitchInProgress then
            local isJumping = IsPedJumping(playerPed)

            if isJumping then
                TriggerServerEvent('FIREAC:CheckJumping', FIREAC.JumpPunishment, "Anti Superjump", "Used superjump hacks")
            end
        end
    end
end)

--【 𝗖𝗵𝗲𝗰𝗸 𝗧𝗵r𝗲𝗮𝗱 1 】--
Citizen.CreateThread(function()
    local lastCoords = nil
    local isFirstAttempt = true
    while true do
        Wait(5000)
        local PED     = PlayerPedId()
        local COORDS  = GetEntityCoords(PED)
        local PLS     = GetActivePlayers()
        local HEALTH  = GetEntityHealth(PED)
        local ARMOR   = GetPedArmour(PED)
        local VEH     = nil
        local PLATE   = nil
        local VEHHASH = nil
        if not IsPlayerSwitchInProgress() then
            if IsPedInAnyVehicle(PED, false) then
                VEH     = GetVehiclePedIsIn(PED, false)
                PLATE   = GetVehicleNumberPlateText(VEH)
                VEHHASH = GetHashKey(VEH)
            end
            if FIREAC.AntiSpectate then
                if NetworkIsInSpectatorMode() then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpectatePunishment, "Anti Spectate",
                        "Spectated another player")
                end
            end
            if FIREAC.AntiTrackPlayer then
                local playerPed = PlayerPedId()
                local trackCount = 0
                for i = 0, 255 do
                    if NetworkIsPlayerActive(i) and i ~= PlayerId() then
                        local otherPlayerPed = GetPlayerPed(i)
                        local otherPlayerBlip = GetBlipFromEntity(otherPlayerPed)
                        if DoesBlipExist(otherPlayerBlip) then
                            local blipInfo = GetBlipInfoIdCoord(otherPlayerBlip)
                            local isSelfPlayerBlip = (blipInfo.id == 1 and blipInfo.x == GetEntityCoords(playerPed))
                            if not isSelfPlayerBlip then
                                trackCount = trackCount + 1
                            end
                        end
                    end
                end

                if trackCount >= FIREAC.MaxTrack then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TrackPunishment, "Anti Track Player",
                        "Tracked **" .. trackCount .. "** players")
                end
            end
            if FIREAC.AntiHealthHack then
                if HEALTH > FIREAC.MaxHealth then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.HealthPunishment, "Anti Health Hack",
                        "Used health hacks : **" .. HEALTH .. "**")
                end
            end
            if FIREAC.AntiArmorHack then
                if ARMOR > FIREAC.MaxArmor then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.HealthPunishment, "Anti Armor Hack",
                        "Used armor hacks : **" .. ARMOR .. "**")
                end
            end
            if FIREAC.AntiBlackListWeapon then
                for _, weapon in ipairs(Weapon) do
                    local currentWeaponHash = GetSelectedPedWeapon(PlayerPedId())
                    if currentWeaponHash == GetHashKey(weapon) then
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Black List Weapon",
                            "Used blacklisted weapon: " .. weapon)
                        break
                    end
                end
            end
            if FIREAC.AntiGodMode then
                if NetworkIsPlayerActive(PlayerId()) then
                    if not IsNuiFocused() then
                        if IsScreenFadedIn() then
                            local retval, bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof =
                                GetEntityProofs(PlayerPedId())
                            if GetPlayerInvincible(PlayerId()) or GetPlayerInvincible_2(PlayerId()) then
                                if SPAWN then
                                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti Godmode",
                                        "Used godmode hacks")
                                end
                            end
                            if retval == 1 and bulletProof == 1 and fireProof == 1 and explosionProof == 1 and collisionProof == 1 and steamProof == 1 and p7 == 1 and drownProof == 1 then
                                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti Godmode",
                                    "Used godmode hacks")
                            end
                            if not GetEntityCanBeDamaged(PlayerPedId()) then
                                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti Godmode",
                                    "Used godmode hacks")
                            end
                        end
                    end
                end
            end
            if FIREAC.AntiPlateChanger then
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    local plate = GetVehicleNumberPlateText(vehicle)
                    local hash = GetHashKey(vehicle)
                    if plate and hash and VEH == vehicle and PLATE ~= plate then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti Plate Changer",
                            "Changed the vehicle plate : **" .. PLATE .. " --> " .. plate .. "**")
                    end
                    VEH = vehicle
                    PLATE = plate
                else
                    VEH = nil
                    PLATE = nil
                end
            end
            if FIREAC.AntiInfiniteStamina then
                if not IsPedInAnyVehicle(PlayerPedId(), true)
                    and not IsPedRagdoll(PlayerPedId())
                    and not IsPedFalling(PlayerPedId())
                    and not IsPedJumpingOutOfVehicle(PlayerPedId())
                    and not IsPedInParachuteFreeFall(PlayerPedId())
                    and GetEntitySpeed(PlayerPedId()) > 7
                then
                    local staminaLevel = GetPlayerSprintStaminaRemaining(PlayerId())
                    if tonumber(staminaLevel) == 0.0 then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InfinitePunishment, "Anti Infinite Stamina",
                            "Used stamina hacks")
                    end
                end
            end
            if FIREAC.AntiRagdoll then
                if SPAWN and IsPedRagdoll(PlayerPedId()) and not CanPedRagdoll(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId(), true)
                    and not IsEntityDead(PlayerPedId()) and not IsPedJumpingOutOfVehicle(PlayerPedId()) and not IsPedJacking(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InfinitePunishment, "Anti Ragdoll",
                        "Used ragdoll hack")
                end
            end
            if FIREAC.AntiNightVision then
                if GetUsingnightvision(true) and not IsPedInAnyHeli(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.VisionPunishment, "Anti Night Vision",
                        "Used night vision hack")
                end
                if GetUsingseethrough(true) and not IsPedInAnyHeli(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.VisionPunishment, "Anti Thermal Vision",
                        "Used thermal vision hack")
                end
            end
            Wait(2000)
            if FIREAC.AntiInvisible then
                if SPAWN and (not IsEntityVisible(PlayerPedId()) and not IsEntityVisibleToScript(PlayerPedId()))
                    or (GetEntityAlpha(PlayerPedId()) <= 150 and GetEntityAlpha(PlayerPedId()) ~= 0) then
                    Citizen.Wait(1000)
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InvisiblePunishment, "Anti Invisble",
                        "Used invisibility hacks")
                end
            end
            if FIREAC.AntiBlackListPlate then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    local currentPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false), false)
                    for i, plate in ipairs(Plate) do
                        if currentPlate == plate then
                            TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PlatePunishment, "Anti Black List Plate",
                                "Used blacklisted plate: " .. plate)
                        end
                    end
                end
            end
            if FIREAC.AntiRainbowVehicle then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    local VEH = GetVehiclePedIsIn(PlayerPedId(), false)
                    if DoesEntityExist(VEH) then
                        local C1r, C1g, C1b = GetVehicleCustomPrimaryColour(VEH)
                        if C1r ~= nil then
                            Wait(1000)
                            local C2r, C2g, C2b = GetVehicleCustomPrimaryColour(VEH)
                            if C2r ~= nil and C1r ~= C2r and C1g ~= C2g and C1b ~= C2b then
                                Wait(2000)
                                local C3r, C3g, C3b = GetVehicleCustomPrimaryColour(VEH)
                                if C3r ~= nil and C2r ~= C3r and C3g ~= C2g and C3b ~= C2b and C1r ~= C3r and C1g ~= C3g and C1b ~= C3b then
                                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.RainbowPunishment, "Anti Rainbow",
                                        "Used rainbow hacks")
                                end
                            end
                        end
                    end
                end
            end
            if FIREAC.AntiNoclip then
                if not IsPedInAnyVehicle(PlayerPedId(), false) then
                    local coords = GetEntityCoords(PlayerPedId())
                    if isFirstAttempt then
                        lastCoords = coords
                        isFirstAttempt = false
                    end

                    if #(coords - lastCoords) > 10.0 and GetEntityHeightAboveGround(PlayerPedId()) > 4.0 and not IsPedFalling(PlayerPedId()) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.NoclipPunishment, "Anti Noclip",
                            "Used noclip hack")
                    end
                    lastCoords = coords
                end
            end
            if FIREAC.AntiFreeCam then
                local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()) - GetFinalRenderedCamCoord())
                if (x > 50) or (y > 50) or (z > 50) or (x < -50) or (y < -50) or (z < -50) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.CamPunishment, "Anti Free Cam",
                        "Used freecam hacks")
                end
            end
            if FIREAC.AntiMenyoo then
                if IsPlayerCamControlDisabled() ~= false then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.MenyooPunishment, "Anti Menyoo",
                        "Used menyoo camera hack")
                end
            end
            if FIREAC.AntiAimAssist then
                local aimassiststatus = GetLocalPlayerAimState()
                if aimassiststatus ~= 3 then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AimAssistPunishment, "Anti Aim Assist",
                        "Used aim assist : **" .. aimassiststatus .. "**")
                end
            end
            if FIREAC.AntiWeaponDamageChanger then
                local WEAPON    = GetSelectedPedWeapon(PlayerPedId())
                local WEPDAMAGE = math.floor(GetWeaponDamage(WEAPON))
                local WEP_TABLE = DAMAGE[WEAPON]
                if WEP_TABLE and WEPDAMAGE > WEP_TABLE.DAMAGE then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Weapon Damage Changer",
                        "Tried to change" ..
                        WEP_TABLE.name .. " damage to " .. WEPDAMAGE .. " (Normal damage is: " .. WEP_TABLE.DAMAGE .. ")")
                end
            end
            if FIREAC.AntiWeaponsExplosive then
                local WEAPON        = GetSelectedPedWeapon(PlayerPedId())
                local WEAPON_DAMAEG = GetWeaponDamageType(WEAPON)
                N_0x4757f00bc6323cfe(GetHashKey("WEAPON_EXPLOSION"), 0.0)
                if WEAPON_DAMAEG == 4 or WEAPON_DAMAEG == 5 or WEAPON_DAMAEG == 6 or WEAPON_DAMAEG == 13 then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Weapon Explosive",
                        "Tried to use explosive weapon damage")
                end
            end
            if FIREAC.AntiPedChanger then
                for i, value in ipairs(WhiteListPeds) do
                    if not GetEntityModel(PlayerPedId()) == GetHashKey(value) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedChangePunishment, "Anti Ped Changer",
                            "Tried to change ped to " .. value .. "!")
                    end
                end
            end
            if FIREAC.AntiBlacklistTasks then
                for _, task in pairs(Tasks) do
                    if GetIsTaskActive(PlayerPedId(), task) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TasksPunishment, "Anti Black List Tasks",
                            "Tried to play task in server " .. task .. "!")
                    end
                end
            end
            if FIREAC.AntiBlacklistAnims then
                for _, anim in pairs(Anims) do
                    if IsEntityPlayingAnim(PlayerPedId(), anim[1], anim[2], 3) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AnimsPunishment, "Anti Black List Animation",
                            "Tried to play blacklisted animation " .. anim[1] " and " .. anim[2] .. "")
                        ClearPedTasksImmediately(PlayerPedId())
                        ClearPedTasks(PlayerPedId())
                        ClearPedSecondaryTask(PlayerPedId())
                    end
                end
                Wait(100)
            end
            if FIREAC.AntiTinyPed then
                local Tiny = GetPedConfigFlag(PlayerPedId(), 223, true)
                if Tiny then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedFlagPunishment, "Anti Tiny Ped",
                        "Tried to turn into tiny ped")
                end
                Wait(100)
            end
            if FIREAC.AntiTinyPed then
                local Tiny = GetPedConfigFlag(PlayerPedId(), 223, true)
                if Tiny then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedFlagPunishment, "Anti Tiny Ped",
                        "Tried to turn into tiny ped")
                end
                Wait(100)
            end
            Wait(2000)
        end
    end
end)

--【 𝗖𝗵𝗲𝗰𝗸 𝗧𝗵𝗲𝗮𝗿𝗱 2 】--
local PCOORDS = {}
Citizen.CreateThread(function()
    local WAIT = 3000
    while SPAWN do
        Wait(WAIT)
        if FIREAC.SafePlayers then
            SetEntityProofs(PlayerPedId(), false, true, true, false, false, false, false, false)
        end
        if FIREAC.AntiInfinityAmmo then
            SetPedInfiniteAmmoClip(PlayerPedId(), false)
        end
        local PED  = PlayerPedId()
        local JUMP = IsPedJumping(PED)
        if FIREAC.AntiChangeSpeed then
            if SPAWN then
                if IsPedInAnyVehicle(PED, false) then
                    local VEH       = GetVehiclePedIsIn(PED, false)
                    local MAX_SPEED = GetVehicleEstimatedMaxSpeed(VEH)
                    local VEHSPED   = GetEntitySpeed(VEH)
                    local TOTAL     = MAX_SPEED + 10
                    if VEHSPED > TOTAL then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpeedPunishment, "Anti Speed Changer",
                            "Tried to change the vehicle speed : **" .. VEHSPED * 3.6 .. " KM**")
                    end
                else
                    local ENSPEED = GetEntitySpeed(PED)
                    if IsPedRunning(PED) and ENSPEED > 9 and not JUMP then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpeedPunishment, "Anti Fast Run",
                            "Tried to change the walk speed : **" .. ENSPEED .. "**")
                    end
                end
            end
        end
        if FIREAC.AntiTeleport then
            while IsPlayerSwitchInProgress() do
                Wait(5000)
            end
            local COORDS = GetEntityCoords(PlayerPedId())
            if IsPedInAnyVehicle(PlayerPedId(), false) and not IsPedFalling(PlayerPedId()) then
                Wait(1000)
                local NEW_COORDS = GetEntityCoords(PlayerPedId())
                local DISTENCE = Vdist(COORDS.x, COORDS.y, COORDS.z, NEW_COORDS.x, NEW_COORDS.y, NEW_COORDS.z)
                if IsPedInAnyVehicle(PlayerPedId(), false) and DISTENCE >= FIREAC.MaxVehicleDistance and not IsPedFalling(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TeleportPunishment, "Anti Teleport",
                        "Tried teleporting in vehicle")
                end
            end
        end
        Wait(0)
    end
end)

--【 𝗦𝘁𝗼𝗽 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 】--
AddEventHandler('onResourceStop', function(resourceName)
    if FIREAC.AntiResourceStopper or FIREAC.AntiResourceRestarter then
        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.ResourcePunishment, "Anti Resource Stopper",
            "Tried to stop resource : **" .. resourceName .. "** !")
    end
end)

--【 𝗦𝘁𝗮𝗿𝘁 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 】--
AddEventHandler('onClientResourceStart', function(RES)
    -- Admin Menu --
    if RES == GetCurrentResourceName() then
        TriggerServerEvent('FIREAC:CheckIsAdmin')
    end
    -- Resource Stopper --
    if FIREAC.AntiResourceStarter or FIREAC.AntiResourceRestarter then
        Citizen.CreateThread(function()
            while true do
                Wait(1000)
                if IsPedWalking(PlayerPedId()) or GetCamActiveViewModeContext() then
                    TriggerServerEvent("FIREAC:BanFromClient", FIREAC.ResourcePunishment, "Anti Resource Starter",
                        "Tried to start resource : **" .. RES .. "** !")
                    break
                end
            end
        end)
    end
end)

--【 𝗔𝗻𝘁𝗶 𝗦𝘂𝗶𝗰𝗶𝗱𝗲 】--
AddEventHandler("gameEventTriggered", function(name, args)
    local PLID     = PlayerId()
    local PED      = PlayerPedId()
    local ENOWNER  = GetPlayerServerId(NetworkGetEntityOwner(args[2]))
    local ENOWNER1 = NetworkGetEntityOwner(args[1])
    local ARMED    = false
    while IsPlayerSwitchInProgress() do
        Wait(7500)
    end

    if FIREAC.AntiSuicide and name == "CEventNetworkEntityDamage" then
        if args[1] == PlayerPedId() and args[2] == -1 and #args == 14 and
            args[3] == 0 and args[4] == 0 and args[5] == 0 and args[6] == 1 and
            args[7] == GetHashKey('WEAPON_FALL') and args[8] == 0 and args[9] == 0 and
            args[10] == 0 and args[11] == 0 and args[12] == 0 and args[13] == 0 then
            TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SuicidePunishment, "Anti Suicide", "Tried to suicide")
        end
    end

    if FIREAC.AntiPickupCollect and name == 'CEventNetworkPlayerCollectedPickup' then
        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PickupPunishment, "Anti Collected Pickup",
            "Tried to collect a pickup : " .. json.encode(args) .. "")
    end
end)
