--
-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2024 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0
--

local SPAWN = false
local CHECK_SPAWN = true
local TRACK = 0
local WHITELIST = false

-- SPAWN Initialization:
-- This section initializes the spawn process based on configuration settings.

Citizen.CreateThread(function()
    if FIREAC.Spawn.LongSpawnMode then
        Citizen.Wait(2000)
        while not NetworkIsPlayerActive(PlayerId()) or IsPlayerSwitchInProgress() do
            Citizen.Wait(1000)
        end
        Citizen.Wait(4000)
        SPAWN = true
        CHECK_SPAWN = false
    else
        while not NetworkIsPlayerActive(PlayerId()) or IsPlayerSwitchInProgress() do
            Citizen.Wait(0)
        end
        SPAWN = true
        CHECK_SPAWN = false
    end
end)

-- Admin Check Thread:
-- This thread periodically checks if the player is an admin.
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

-- Anti Teleport & Anti Super Jump Thread:
-- This thread continuously checks for teleportation and super jump hacks.

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local doesPlayerExist = DoesEntityExist(playerPed)
        local isPlayerInVehicle = IsPedInAnyVehicle(playerPed, false)
        local isSpawned = SPAWN
        local isPlayerSwitchInProgress = IsPlayerSwitchInProgress()
        local isCameraControlDisabled = IsPlayerCamControlDisabled()

        -- Anti Teleport Check:
        if FIREAC.AntiTeleport and not isPlayerInVehicle and isSpawned and not isPlayerSwitchInProgress and not isCameraControlDisabled then
            local currentPosition = GetEntityCoords(playerPed)
            Citizen.Wait(3000)
            local newPlayerPed = PlayerPedId()
            local newPosition = GetEntityCoords(newPlayerPed)
            local distance = #(vector3(currentPosition) - vector3(newPosition))

            if distance > FIREAC.MaxFootDistance and not IsEntityDead(playerPed) and not IsPedInParachuteFreeFall(playerPed) and not IsPedJumpingOutOfVehicle(playerPed) and playerPed == newPlayerPed then
                FIREAC_ACTION(FIREAC.TeleportPunishment, "Anti Teleport", "Used teleport hacks")
            end
        end

        -- Anti Super Jump Check:
        if FIREAC.AntiSuperJump and doesPlayerExist and isSpawned and not isPlayerSwitchInProgress then
            local isJumping = IsPedJumping(playerPed)

            if isJumping then
                TriggerServerEvent('FIREAC:CheckJumping', FIREAC.JumpPunishment, "Anti Superjump", "Used superjump hacks")
            end
        end
    end
end)

-- Citizen thread for continuous checks and actions
Citizen.CreateThread(function()
    -- Initialize local variables
    local lastCoords = nil
    local isFirstAttempt = true

    -- Main loop for continuous checks
    while true do
        Wait(5000) -- Wait for 5 seconds for performance reasons

        local PED = PlayerPedId()
        local COORDS = GetEntityCoords(PED)
        local PLS = GetActivePlayers()
        local HEALTH = GetEntityHealth(PED)
        local ARMOR = GetPedArmour(PED)
        local VEH = nil
        local PLATE = nil
        local VEHHASH = nil

        if not IsPlayerSwitchInProgress() then
            -- Check if player is in a vehicle
            if IsPedInAnyVehicle(PED, false) then
                VEH = GetVehiclePedIsIn(PED, false)
                PLATE = GetVehicleNumberPlateText(VEH)
                VEHHASH = GetHashKey(VEH)
            end

            -- Anti-Spectate check
            if FIREAC.AntiSpectate then
                if NetworkIsInSpectatorMode() then
                    FIREAC_ACTION(FIREAC.SpectatePunishment, "Anti Spectate", "Spectated another player")
                end
            end

            -- Anti-Track-Player check
            if FIREAC.AntiTrackPlayer then
                local playerPed = PlayerPedId()
                local trackCount = 0

                -- Count players with blips on the radar
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

                -- Punish if player is tracking too many others
                if trackCount >= FIREAC.MaxTrack then
                    FIREAC_ACTION(FIREAC.TrackPunishment, "Anti Track Player", "Tracked " .. trackCount .. " players")
                end
            end

            -- Anti-Health-Hack check
            if FIREAC.AntiHealthHack then
                if HEALTH > FIREAC.MaxHealth then
                    FIREAC_ACTION(FIREAC.HealthPunishment, "Anti Health Hack", "Used health hacks: " .. HEALTH)
                end
            end

            -- Anti-Armor-Hack check
            if FIREAC.AntiArmorHack then
                if ARMOR > FIREAC.MaxArmor then
                    FIREAC_ACTION(FIREAC.HealthPunishment, "Anti Armor Hack", "Used armor hacks: " .. ARMOR)
                end
            end

            -- Anti-BlackList-Weapon check
            if FIREAC.AntiBlackListWeapon then
                for _, weapon in ipairs(Weapon) do
                    local currentWeaponHash = GetSelectedPedWeapon(PlayerPedId())
                    if currentWeaponHash == GetHashKey(weapon) then
                        -- Remove weapons and punish if blacklisted weapon is used
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        FIREAC_ACTION(FIREAC.WeaponPunishment, "Anti Black List Weapon",
                            "Used blacklisted weapon: " .. weapon)
                        break
                    end
                end
            end

            -- Anti-GodMode check
            if FIREAC.AntiGodMode then
                if NetworkIsPlayerActive(PlayerId()) then
                    if not IsNuiFocused() then
                        if IsScreenFadedIn() then
                            local retval, bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof =
                                GetEntityProofs(PlayerPedId())

                            -- Check various godmode conditions and punish if detected
                            if GetPlayerInvincible(PlayerId()) or GetPlayerInvincible_2(PlayerId()) then
                                if SPAWN then
                                    FIREAC_ACTION(FIREAC.GodPunishment, "Anti Godmode", "Used godmode hacks")
                                end
                            end

                            if retval == 1 and bulletProof == 1 and fireProof == 1 and explosionProof == 1 and collisionProof == 1 and steamProof == 1 and p7 == 1 and drownProof == 1 then
                                FIREAC_ACTION(FIREAC.GodPunishment, "Anti Godmode", "Used godmode hacks")
                            end

                            if not GetEntityCanBeDamaged(PlayerPedId()) then
                                FIREAC_ACTION(FIREAC.GodPunishment, "Anti Godmode", "Used godmode hacks")
                            end
                        end
                    end
                end
            end

            -- Anti-Plate-Changer check
            if FIREAC.AntiPlateChanger then
                local ped = PlayerPedId()

                if IsPedInAnyVehicle(ped, false) then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    local plate = GetVehicleNumberPlateText(vehicle)
                    local hash = GetHashKey(vehicle)

                    -- Punish if vehicle plate is changed
                    if plate and hash and VEH == vehicle and PLATE ~= plate then
                        FIREAC_ACTION(FIREAC.GodPunishment, "Anti Plate Changer",
                            "Changed the vehicle plate: " .. PLATE .. " --> " .. plate)
                    end

                    VEH = vehicle
                    PLATE = plate
                else
                    VEH = nil
                    PLATE = nil
                end
            end

            -- Anti-Infinite-Stamina check
            if FIREAC.AntiInfiniteStamina then
                if not IsPedInAnyVehicle(PlayerPedId(), true)
                    and not IsPedRagdoll(PlayerPedId())
                    and not IsPedFalling(PlayerPedId())
                    and not IsPedJumpingOutOfVehicle(PlayerPedId())
                    and not IsPedInParachuteFreeFall(PlayerPedId())
                    and GetEntitySpeed(PlayerPedId()) > 7
                then
                    local staminaLevel = GetPlayerSprintStaminaRemaining(PlayerId())

                    -- Punish if infinite stamina is detected
                    if tonumber(staminaLevel) == 0.0 then
                        FIREAC_ACTION(FIREAC.InfinitePunishment, "Anti Infinite Stamina", "Used stamina hacks")
                    end
                end
            end

            -- Anti-Ragdoll check
            if FIREAC.AntiRagdoll then
                if SPAWN and IsPedRagdoll(PlayerPedId()) and not CanPedRagdoll(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId(), true)
                    and not IsEntityDead(PlayerPedId()) and not IsPedJumpingOutOfVehicle(PlayerPedId()) and not IsPedJacking(PlayerPedId())
                then
                    -- Punish if ragdoll hack is detected
                    FIREAC_ACTION(FIREAC.InfinitePunishment, "Anti Ragdoll", "Used ragdoll hack")
                end
            end

            -- Anti-Night-Vision check
            if FIREAC.AntiNightVision then
                if GetUsingnightvision(true) and not IsPedInAnyHeli(PlayerPedId()) then
                    -- Punish if night vision hack is detected
                    FIREAC_ACTION(FIREAC.VisionPunishment, "Anti Night Vision", "Used night vision hack")
                end

                if GetUsingseethrough(true) and not IsPedInAnyHeli(PlayerPedId()) then
                    -- Punish if thermal vision hack is detected
                    FIREAC_ACTION(FIREAC.VisionPunishment, "Anti Thermal Vision", "Used thermal vision hack")
                end
            end

            Wait(2000) -- Wait for 2 seconds before additional checks

            -- Anti-Invisible check
            if FIREAC.AntiInvisible then
                if SPAWN and ((not IsEntityVisible(PlayerPedId()) and not IsEntityVisibleToScript(PlayerPedId()))
                        or (GetEntityAlpha(PlayerPedId()) <= 150 and GetEntityAlpha(PlayerPedId()) ~= 0))
                then
                    Citizen.Wait(1000)
                    -- Punish if invisibility hack is detected
                    FIREAC_ACTION(FIREAC.InvisiblePunishment, "Anti Invisble", "Used invisibility hacks")
                end
            end

            -- Anti-BlackList-Plate check
            if FIREAC.AntiBlackListPlate then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    local currentPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false), false)

                    -- Check if the vehicle plate is blacklisted
                    for i, plate in ipairs(Plate) do
                        if currentPlate == plate then
                            FIREAC_ACTION(FIREAC.PlatePunishment, "Anti Black List Plate",
                                "Used blacklisted plate: " .. plate)
                        end
                    end
                end
            end

            -- Anti-Rainbow-Vehicle check
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
                                    -- Punish if rainbow vehicle hack is detected
                                    FIREAC_ACTION(FIREAC.RainbowPunishment, "Anti Rainbow", "Used rainbow hacks")
                                end
                            end
                        end
                    end
                end
            end

            -- Anti-Noclip check
            if FIREAC.AntiNoclip then
                if not IsPedInAnyVehicle(PlayerPedId(), false) then
                    local coords = GetEntityCoords(PlayerPedId())

                    if isFirstAttempt then
                        lastCoords = coords
                        isFirstAttempt = false
                    end

                    -- Punish if noclip hack is detected
                    if #(coords - lastCoords) > 10.0 and GetEntityHeightAboveGround(PlayerPedId()) > 4.0 and not IsPedFalling(PlayerPedId()) then
                        FIREAC_ACTION(FIREAC.NoclipPunishment, "Anti Noclip", "Used noclip hack")
                    end

                    lastCoords = coords
                end
            end

            -- Anti-FreeCam check
            if FIREAC.AntiFreeCam then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local camCoords = GetFinalRenderedCamCoord()
                local distance = #(playerCoords - camCoords)

                -- Punish if freecam hack is detected
                if distance > 50 and not IsCinematicCamRendering() then
                    FIREAC_ACTION(FIREAC.CamPunishment, "Anti Free Cam", "Used freecam hacks")
                end
            end

            -- Anti-Menyoo check
            if FIREAC.AntiMenyoo then
                if IsPlayerCamControlDisabled() ~= false then
                    -- Punish if Menyoo camera hack is detected
                    FIREAC_ACTION(FIREAC.MenyooPunishment, "Anti Menyoo", "Used menyoo camera hack")
                end
            end

            -- Anti-Aim-Assist check
            if FIREAC.AntiAimAssist then
                local aimassiststatus = GetLocalPlayerAimState()

                -- Punish if aim assist is detected
                if aimassiststatus ~= 3 then
                    FIREAC_ACTION(FIREAC.AimAssistPunishment, "Anti Aim Assist", "Used aim assist: " .. aimassiststatus)
                end
            end

            -- Anti-Weapon-Damage-Changer check
            if FIREAC.AntiWeaponDamageChanger then
                local weapon = GetSelectedPedWeapon(PlayerPedId())
                local weaponDamage = math.floor(GetWeaponDamage(weapon))
                local weaponData = DAMAGE[weapon]

                -- Punish if weapon damage exceeds the normal value
                if weaponData and weaponDamage > weaponData.DAMAGE then
                    local weaponName = weaponData.name
                    local normalDamage = weaponData.DAMAGE
                    local message = string.format("Tried to change %s damage to %d (Normal damage is: %d)", weaponName,
                        weaponDamage, normalDamage)
                    FIREAC_ACTION(FIREAC.WeaponPunishment, "Anti Weapon Damage Changer", message)
                end
            end

            -- Anti-Weapons-Explosive check
            if FIREAC.AntiWeaponsExplosive then
                local weapon = GetSelectedPedWeapon(PlayerPedId())
                local damageType = GetWeaponDamageType(weapon)
                N_0x4757f00bc6323cfe(GetHashKey("WEAPON_EXPLOSION"), 0.0)

                local explosiveDamageTypes = { 4, 5, 6, 13 }
                local isExplosive = false

                -- Check if the weapon is explosive
                for _, damage in ipairs(explosiveDamageTypes) do
                    if damage == damageType then
                        isExplosive = true
                        break
                    end
                end

                -- Punish if explosive weapon is used
                if isExplosive then
                    local weaponName = GetWeapontypeModel(weapon)
                    local message = string.format("Tried to use %s (explosive) weapon", weaponName)
                    FIREAC_ACTION(FIREAC.WeaponPunishment, "Anti Weapon Explosive", message)
                end
            end

            -- Anti-Ped-Changer check
            if FIREAC.AntiPedChanger then
                local playerPedModel = GetEntityModel(PlayerPedId())
                local isWhitelisted = false

                -- Check if the ped model is whitelisted
                for _, whitelistedModel in ipairs(WhiteListPeds) do
                    if playerPedModel == GetHashKey(whitelistedModel) then
                        isWhitelisted = true
                        break
                    end
                end

                -- Punish if ped model is changed to a non-whitelisted model
                if not isWhitelisted then
                    local message = string.format("Tried to change ped to %s", tostring(playerPedModel))
                    FIREAC_ACTION(FIREAC.PedChangePunishment, "Anti Ped Changer", message)
                end
            end

            -- Anti-Blacklist-Tasks check
            if FIREAC.AntiBlacklistTasks then
                local playerPed = PlayerPedId()

                -- Check if any blacklisted task is active
                for _, taskName in ipairs(Tasks) do
                    if GetIsTaskActive(playerPed, taskName) then
                        local message = string.format("Tried to play blacklisted task: %s", taskName)
                        FIREAC_ACTION(FIREAC.TasksPunishment, "Anti Black List Tasks", message)
                    end
                end
            end

            -- Anti-Blacklist-Anims check
            if FIREAC.AntiBlacklistAnims then
                local playerPed = PlayerPedId()

                -- Check if any blacklisted animation is playing
                for _, anim in ipairs(Anims) do
                    local dict, animName = anim.dict, anim.anim
                    if IsEntityPlayingAnim(playerPed, dict, animName, 3) then
                        local message = string.format("Tried to play blacklisted animation %s and %s", dict, animName)
                        FIREAC_ACTION(FIREAC.AnimsPunishment, "Anti Black List Animation", message)
                        ClearPedTasks(playerPed)
                    end
                end

                Wait(100)
            end

            -- Anti-Tiny-Ped check
            if FIREAC.AntiTinyPed then
                local Tiny = GetPedConfigFlag(PlayerPedId(), 223, true)

                -- Punish if player tries to turn into a tiny ped
                if Tiny then
                    FIREAC_ACTION(FIREAC.PedFlagPunishment, "Anti Tiny Ped", "Tried to turn into tiny ped")
                end
                Wait(100)
            end

            Wait(2000) -- Wait for 2 seconds before restarting the loop
        end
    end
end)

-- Create a thread for various security checks and actions
Citizen.CreateThread(function()
    local waitTime = 3000

    while SPAWN do
        -- Wait for a specified time
        Wait(waitTime)

        -- Security check: If SafePlayers is enabled, set entity proofs to prevent certain effects
        if FIREAC.SafePlayers then
            SetEntityProofs(PlayerPedId(), false, true, true, false, false, false, false, false)
        end

        -- Security check: If AntiInfinityAmmo is enabled, disable infinite ammo clip for the player
        if FIREAC.AntiInfinityAmmo then
            SetPedInfiniteAmmoClip(PlayerPedId(), false)
        end

        -- Security check: If AntiChangeSpeed is enabled, monitor and take action if the player attempts to change speed
        if FIREAC.AntiChangeSpeed then
            local ped = PlayerPedId()

            if not IsPedInAnyVehicle(ped, false) then
                local speed = GetEntitySpeed(ped)

                if IsPedRunning(ped) and speed > 9 and not IsPedJumping(ped) then
                    local message = string.format("Tried to change the walk speed: **%.2f**", speed)
                    FIREAC_ACTION(FIREAC.SpeedPunishment, "Anti Fast Run", message)
                end
            else
                local vehicle = GetVehiclePedIsIn(ped, false)

                if DoesEntityExist(vehicle) then
                    local maxSpeed = GetVehicleEstimatedMaxSpeed(vehicle)
                    local speed    = GetEntitySpeed(vehicle)
                    local total    = maxSpeed + 10

                    if speed > total then
                        local message = string.format("Tried to change the vehicle speed: **%.2f KM**", speed * 3.6)
                        FIREAC_ACTION(FIREAC.SpeedPunishment, "Anti Speed Changer", message)
                    end
                end
            end
        end

        -- Security check: If AntiTeleport is enabled, monitor and take action if the player attempts to teleport
        if FIREAC.AntiTeleport then
            while IsPlayerSwitchInProgress() do
                Wait(5000)
            end

            local coords = GetEntityCoords(PlayerPedId())

            if IsPedInAnyVehicle(PlayerPedId(), false) and not IsPedFalling(PlayerPedId()) then
                Wait(1000)

                local newCoords = GetEntityCoords(PlayerPedId())
                local distance  = Vdist(coords, newCoords)

                if distance >= FIREAC.MaxVehicleDistance then
                    FIREAC_ACTION(FIREAC.TeleportPunishment, "Anti Teleport",
                        "Tried teleporting in a vehicle")
                end
            end
        end

        -- Allow other threads to execute
        Wait(0)
    end
end)

-- Network event registration for checking status
RegisterNetEvent('FIREAC:checkStatus')
AddEventHandler('FIREAC:checkStatus', function(data)
    -- Trigger server event to pass script information
    TriggerServerEvent('FIREAC:passScriptInfo', data.name, data.path)
end)

-- Event handler for resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    -- If AntiResourceStarter or AntiResourceRestarter is enabled, check for resource start attempts
    if FIREAC.AntiResourceStarter or FIREAC.AntiResourceRestarter then
        Citizen.CreateThread(function()
            while true do
                Wait(1000)
                -- Check if the player is walking or in camera view mode
                if IsPedWalking(PlayerPedId()) or GetCamActiveViewModeContext() then
                    local message = string.format("Tried to start resource: **%s**!", resourceName)
                    -- Trigger server event to apply punishment for resource starter attempts
                    TriggerServerEvent("FIREAC:BanFromClient", FIREAC.ResourcePunishment, "Anti Resource Starter",
                        message)
                    break
                end
            end
        end)
    end

    -- If the current resource is the main script, trigger server event to check for admin status
    if resourceName == GetCurrentResourceName() then
        TriggerServerEvent('FIREAC:CheckIsAdmin')
    end
end)

-- Event handler for game events
AddEventHandler("gameEventTriggered", function(name, args)
    -- Check for AntiSuicide condition
    if FIREAC.AntiSuicide and name == "CEventNetworkEntityDamage" then
        local playerPed = PlayerPedId()
        local attacker  = NetworkGetEntityOwner(args[1])
        local weapon    = args[7]
        local isFall    = weapon == GetHashKey('WEAPON_FALL')

        -- Check if the event corresponds to a suicide attempt
        if args[1] == playerPed and args[2] == -1 and #args == 14 and
            args[3] == 0 and args[4] == 0 and args[5] == 0 and args[6] == 1 and
            isFall and args[8] == 0 and args[9] == 0 and
            args[10] == 0 and args[11] == 0 and args[12] == 0 and args[13] == 0 then
            -- If the conditions are met, trigger an action for Anti Suicide
            FIREAC_ACTION(FIREAC.SuicidePunishment, "Anti Suicide", "Tried to suicide")
        end
    end

    -- Check for AntiPickupCollect condition
    if FIREAC.AntiPickupCollect and name == 'CEventNetworkPlayerCollectedPickup' then
        local message = string.format("Tried to collect a pickup: **%s**", json.encode(args))
        -- If the conditions are met, trigger an action for Anti Pickup Collect
        FIREAC_ACTION(FIREAC.PickupPunishment, "Anti Collected Pickup", message)
    end
end)

-- Functions for actions

-- Function to perform FIREAC action
function FIREAC_ACTION(punishment, reason, details)
    -- Check temporary whitelist status before triggering the server event
    if FIREAC_CHECK_TEMP_WHITELIST() == false then
        TriggerServerEvent('FIREAC:BanFromClient', punishment, reason, details)
    end
end

-- Function to change temporary whitelist status
function FIREAC_CHANGE_TEMP_WHHITELIST(STATUS)
    if STATUS == true then
        WHITELIST = STATUS
    elseif STATUS == false then
        WHITELIST = STATUS
    end
end

-- Function to check temporary whitelist status
function FIREAC_CHECK_TEMP_WHITELIST()
    return WHITELIST
end
