-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2026 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0

local state = {
    ready = false,
    spawnSerial = 0,
    graceUntil = 0,
    pausedUntil = 0,
    baselineModel = nil,
    lastPed = 0,
    lastCoords = nil,
    lastPositionAt = 0,
    lastVehicle = 0,
    lastPlate = nil,
    lastPrimaryColour = nil,
    reportCooldown = {},
    evidence = {},
    lastCameraMode = nil,
    cameraChangedAt = 0,
    knownResources = {},
    readyStarting = false,
    lastReadyAt = 0,
    hasPlayerSpawned = false,
    lastSpawnEventAt = 0,
    frameworkLoaded = false,
    frameworkType = "standalone",
}

local function now()
    return GetGameTimer()
end

local function detectionConfig(name, fallback)
    if FIREAC.Detection and FIREAC.Detection[name] ~= nil then
        return FIREAC.Detection[name]
    end
    return fallback
end

local function extendGrace(duration)
    local ms = tonumber(duration) or detectionConfig("RespawnGraceMs", 10000)
    state.graceUntil = math.max(state.graceUntil, now() + ms)
    state.evidence = {}
    state.lastCoords = nil
    state.lastPositionAt = 0
end

local function validPed()
    local ped = PlayerPedId()
    return ped ~= 0 and DoesEntityExist(ped) and NetworkIsPlayerActive(PlayerId()), ped
end

local function resourceStarted(name)
    if type(name) ~= "string" or name == "" then return false end
    local ok, stateName = pcall(GetResourceState, name)
    return ok and stateName == "started"
end

local function detectFramework()
    if resourceStarted("qb-core") then return "qbcore" end
    if resourceStarted("es_extended") then return "esx" end
    return "standalone"
end

local function hasCollisionAndControl(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return false end
    if IsPlayerSwitchInProgress() or IsPauseMenuActive() then return false end
    if IsScreenFadedOut() or IsScreenFadingOut() or IsScreenFadingIn() then return false end
    if not HasCollisionLoadedAroundEntity(ped) then return false end
    if not IsPlayerControlOn(PlayerId()) then return false end
    return true
end

local function gameplaySettled(ped)
    local ok
    ok, ped = validPed()
    if not ok then return false, ped end

    state.frameworkType = detectFramework()

    if detectionConfig("RequirePlayerSpawned", true) and not state.hasPlayerSpawned then
        return false, ped
    end

    if detectionConfig("RequireFrameworkLoaded", true)
        and state.frameworkType ~= "standalone"
        and not state.frameworkLoaded then
        return false, ped
    end

    if not hasCollisionAndControl(ped) then
        return false, ped
    end

    local settleMs = tonumber(detectionConfig("PostSpawnSettleMs", 18000)) or 18000
    if state.lastSpawnEventAt > 0 and now() - state.lastSpawnEventAt < settleMs then
        return false, ped
    end

    return true, ped
end

local function checksAllowed()
    local ok, ped = gameplaySettled()
    if not ok or not state.ready then return false, ped end
    if now() < state.graceUntil or now() < state.pausedUntil then return false, ped end
    if IsEntityDead(ped) or IsPedFatallyInjured(ped) then return false, ped end
    return true, ped
end

local function clearEvidence(key)
    state.evidence[key] = nil
end

local function report(punishment, reason, details, key, threshold, cooldown)
    if FIREAC_CHECK_TEMP_WHITELIST() then return end

    key = key or reason
    threshold = tonumber(threshold) or detectionConfig("EvidenceThreshold", 3)
    cooldown = tonumber(cooldown) or detectionConfig("ClientReportCooldownMs", 10000)

    local t = now()
    local ev = state.evidence[key]
    if not ev or t - ev.startedAt > detectionConfig("EvidenceWindowMs", 15000) then
        ev = { count = 0, startedAt = t }
        state.evidence[key] = ev
    end

    ev.count = ev.count + 1
    if ev.count < threshold then return end

    local last = state.reportCooldown[key] or 0
    if t - last < cooldown then return end

    state.reportCooldown[key] = t
    state.evidence[key] = nil
    TriggerServerEvent("FIREAC:reportDetection", punishment, reason, tostring(details or "No details"))
end

local function snapshotKnownResources()
    local count = tonumber(GetNumResources()) or 0
    for index = 0, count - 1 do
        local resource = GetResourceByFindIndex(index)
        if type(resource) == "string" and resource ~= "" then state.knownResources[resource] = true end
    end
end

local function markReady(reason)
    if state.readyStarting then return end
    if state.ready and now() - state.lastReadyAt < 1500 then return end
    state.readyStarting = true
    CreateThread(function()
        local maxWait = tonumber(detectionConfig("ReadyMaxWaitMs", 120000)) or 120000
        local startedAt = now()
        local ok, ped = gameplaySettled()

        while not ok and now() - startedAt < maxWait do
            Wait(500)
            ok, ped = gameplaySettled()
        end

        if not ok then
            state.readyStarting = false
            return
        end

        state.spawnSerial = state.spawnSerial + 1
        state.ready = true
        state.readyStarting = false
        state.lastReadyAt = now()
        state.lastPed = ped
        state.baselineModel = GetEntityModel(ped)
        extendGrace(detectionConfig("PostReadyGraceMs", detectionConfig("SpawnGraceMs", 20000)))
        TriggerServerEvent("FIREAC:clientReady", state.spawnSerial, reason or "runtime")
        TriggerServerEvent("FIREAC:checkIsAdmin")
    end)
end

local function noteSpawn(reason)
    state.hasPlayerSpawned = true
    state.lastSpawnEventAt = now()
    state.ready = false
    state.evidence = {}
    extendGrace(detectionConfig("PostSpawnSettleMs", 18000) + detectionConfig("PostReadyGraceMs", 20000))
    markReady(reason or "playerSpawned")
end

local function noteFrameworkLoaded(framework)
    state.frameworkType = framework or detectFramework()
    state.frameworkLoaded = true
    extendGrace(detectionConfig("FrameworkLoadGraceMs", 12000))
    markReady("frameworkLoaded:" .. tostring(state.frameworkType))
end

AddEventHandler("playerSpawned", function()
    noteSpawn("playerSpawned")
end)

RegisterNetEvent("esx:playerLoaded", function()
    noteFrameworkLoaded("esx")
end)

RegisterNetEvent("esx:onPlayerSpawn", function()
    state.frameworkLoaded = true
    noteSpawn("esx:onPlayerSpawn")
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    noteFrameworkLoaded("qbcore")
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    state.ready = false
    state.frameworkLoaded = false
    state.hasPlayerSpawned = false
    extendGrace(detectionConfig("FrameworkLoadGraceMs", 12000))
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        snapshotKnownResources()
        state.frameworkType = detectFramework()

        CreateThread(function()
            Wait(tonumber(detectionConfig("ResourceRestartAssumeSpawnedMs", 8000)) or 8000)
            local ok, ped = validPed()
            if ok and hasCollisionAndControl(ped) then
                state.hasPlayerSpawned = true
                state.lastSpawnEventAt = now() - (tonumber(detectionConfig("PostSpawnSettleMs", 18000)) or 18000)
                if state.frameworkType ~= "standalone" then state.frameworkLoaded = true end
                markReady("resourceRestartStable")
            end
        end)
        return
    end

    if FIREAC.AntiInject and state.ready and not state.knownResources[resourceName] then
        TriggerServerEvent("FIREAC:AntiInject", tostring(resourceName), "unexpected client-only resource start")
    end
    state.knownResources[resourceName] = true
end)

RegisterNetEvent("FIREAC:clientGrace", function(duration)
    extendGrace(math.min(math.max(tonumber(duration) or 10000, 1000), 600000))
end)

CreateThread(function()
    while true do
        Wait(1500)
        local allowed, ped = checksAllowed()
        if not allowed then goto continue end

        if ped ~= state.lastPed then
            state.lastPed = ped
            state.baselineModel = GetEntityModel(ped)
            extendGrace(detectionConfig("PedChangeGraceMs", 10000))
            goto continue
        end

        local cameraMode = GetFollowPedCamViewMode()
        if state.lastCameraMode ~= nil and cameraMode ~= state.lastCameraMode then
            state.cameraChangedAt = now()
        end
        state.lastCameraMode = cameraMode

        if FIREAC.AntiHealthHack then
            local health = GetEntityHealth(ped)
            if health > (tonumber(FIREAC.MaxHealth) or 200) then
                report(FIREAC.HealthPunishment, "Anti Health Hack", ("Health: %s"):format(health), "health", 2)
            else
                clearEvidence("health")
            end
        end

        if FIREAC.AntiArmorHack then
            local armour = GetPedArmour(ped)
            if armour > (tonumber(FIREAC.MaxArmor) or 100) then
                report(FIREAC.ArmorPunishment, "Anti Armor Hack", ("Armour: %s"):format(armour), "armour", 2)
            else
                clearEvidence("armour")
            end
        end

        if FIREAC.AntiSpectate then
            if NetworkIsInSpectatorMode() then
                report(FIREAC.SpectatePunishment or FIREAC.SpactatePunishment or "BAN", "Anti Spectate", "Unexpected spectator mode", "spectate", 3)
            else
                clearEvidence("spectate")
            end
        end

        if FIREAC.AntiGodMode then
            local cameraSettled = now() - state.cameraChangedAt > detectionConfig("CameraGraceMs", 2500)
            local readySettled = now() - state.lastReadyAt > detectionConfig("GodmodeAfterReadyMs", 12000)
            local gameplaySafe = hasCollisionAndControl(ped)
                and not IsEntityPositionFrozen(ped)
                and not IsPedRagdoll(ped)
                and not IsPedFalling(ped)
                and not IsPedInParachuteFreeFall(ped)
                and not IsCutsceneActive()
            local uiSafe = not IsNuiFocused() and not IsCinematicCamRendering() and cameraSettled and readySettled and gameplaySafe
            if uiSafe then
                local invincible = GetPlayerInvincible(PlayerId()) == true
                local damageDisabled = not GetEntityCanBeDamaged(ped)
                local bulletProof, fireProof, explosionProof, collisionProof, meleeProof, _, _, drownProof = GetEntityProofs(ped)
                local fullProofs = bulletProof and fireProof and explosionProof and collisionProof and meleeProof and drownProof
                if invincible or damageDisabled or fullProofs then
                    report(FIREAC.GodPunishment, "Anti Godmode",
                        ("invincible=%s damageDisabled=%s fullProofs=%s"):format(tostring(invincible), tostring(damageDisabled), tostring(fullProofs)),
                        "godmode", detectionConfig("GodmodeSamples", 4), 15000)
                else
                    clearEvidence("godmode")
                end
            else
                clearEvidence("godmode")
            end
        end

        if FIREAC.AntiInvisible then
            local alpha = GetEntityAlpha(ped)
            local invisible = (not IsEntityVisible(ped) and not IsEntityVisibleToScript(ped)) or (alpha > 0 and alpha < 120)
            if invisible then
                report(FIREAC.InvisiblePunishment, "Anti Invisible", ("Entity alpha: %s"):format(alpha), "invisible", 4)
            else
                clearEvidence("invisible")
            end
        end

        if FIREAC.AntiTinyPed then
            if GetPedConfigFlag(ped, 223, true) then
                report(FIREAC.PedFlagPunishment, "Anti Tiny Ped", "Tiny ped flag remained enabled", "tinyped", 3)
            else
                clearEvidence("tinyped")
            end
        end

        if FIREAC.AntiPedChanger and state.baselineModel then
            local model = GetEntityModel(ped)
            if model ~= state.baselineModel then
                local blocked = false
                if type(Peds) == "table" then
                    for _, name in ipairs(Peds) do
                        if model == GetHashKey(name) then
                            blocked = true
                            break
                        end
                    end
                end

                if blocked then
                    report(FIREAC.PedChangePunishment, "Anti Ped Changer",
                        ("Blocked player model: %s"):format(model), "pedmodel", 3, 20000)
                else
                    state.baselineModel = model
                    state.graceUntil = math.max(state.graceUntil, now() + detectionConfig("PedChangeGraceMs", 10000))
                    clearEvidence("pedmodel")
                end
            else
                clearEvidence("pedmodel")
            end
        end

        if FIREAC.AntiFreeCam then
            local playerCoords = GetEntityCoords(ped)
            local camCoords = GetFinalRenderedCamCoord()
            local distance = #(playerCoords - camCoords)
            if distance > 55.0 and not IsCinematicCamRendering() and not IsNuiFocused() then
                report(FIREAC.CamPunishment, "Anti Free Cam", ("Camera distance: %.2f"):format(distance), "freecam", 4)
            else
                clearEvidence("freecam")
            end
        end

        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        local allowed, ped = checksAllowed()
        if not allowed then
            state.lastCoords = nil
            state.lastPositionAt = 0
            goto continue
        end

        local coords = GetEntityCoords(ped)
        local t = now()
        if state.lastCoords and state.lastPositionAt > 0 then
            local elapsed = math.max((t - state.lastPositionAt) / 1000.0, 0.1)
            local distance = #(coords - state.lastCoords)
            local inVehicle = IsPedInAnyVehicle(ped, false)
            local exempt = IsPedFalling(ped) or IsPedRagdoll(ped) or IsPedClimbing(ped) or IsPedVaulting(ped)
                or IsPedInParachuteFreeFall(ped) or IsPedJumpingOutOfVehicle(ped)
                or IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped)
                or not HasCollisionLoadedAroundEntity(ped)

            if FIREAC.AntiTeleport and not exempt then
                local limit = inVehicle and (tonumber(FIREAC.MaxVehicleDistance) or 600) or (tonumber(FIREAC.MaxFootDistance) or 200)
                local scaledLimit = math.max(limit, GetEntitySpeed(ped) * elapsed * 4.0 + 35.0)
                if distance > scaledLimit then
                    report(FIREAC.TeleportPunishment, "Anti Teleport",
                        ("Moved %.2fm in %.2fs (limit %.2fm)"):format(distance, elapsed, scaledLimit), "teleport", 2, 15000)
                else
                    clearEvidence("teleport")
                end
            end

            if FIREAC.AntiNoclip and not inVehicle then
                local height = GetEntityHeightAboveGround(ped)
                if distance > 12.0 and height > 5.0 and not exempt then
                    report(FIREAC.NoclipPunishment, "Anti Noclip", ("Distance %.2f, height %.2f"):format(distance, height), "noclip", 3)
                else
                    clearEvidence("noclip")
                end
            end
        end

        state.lastCoords = coords
        state.lastPositionAt = t
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(750)
        local allowed, ped = checksAllowed()
        if allowed and FIREAC.AntiSuperJump and IsPedJumping(ped) then
            TriggerServerEvent("FIREAC:CheckJumping")
            Wait(2000)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(2500)
        local allowed, ped = checksAllowed()
        if not allowed then goto continue end

        if FIREAC.AntiInfinityAmmo then
            SetPedInfiniteAmmoClip(ped, false)
        end

        if FIREAC.AntiBlackListWeapon and type(Weapon) == "table" then
            local selected = GetSelectedPedWeapon(ped)
            for _, weaponName in ipairs(Weapon) do
                if selected == GetHashKey(weaponName) then
                    RemoveWeaponFromPed(ped, selected)
                    report(FIREAC.WeaponPunishment, "Anti Black List Weapon", "Weapon: " .. tostring(weaponName), "weapon:" .. tostring(selected), 1)
                    break
                end
            end
        end

        if FIREAC.AntiWeaponDamageChanger and type(DAMAGE) == "table" then
            local weapon = GetSelectedPedWeapon(ped)
            local expected = DAMAGE[weapon]
            if expected and expected.DAMAGE then
                local actual = math.floor(GetWeaponDamage(weapon))
                if actual > expected.DAMAGE + 1 then
                    report(FIREAC.DamagePunishment or FIREAC.WeaponPunishment, "Anti Weapon Damage Changer",
                        ("%s damage %s, expected %s"):format(expected.name or weapon, actual, expected.DAMAGE), "damage:" .. tostring(weapon), 3)
                end
            end
        end

        if FIREAC.AntiInfiniteStamina and not IsPedInAnyVehicle(ped, false) and IsPedSprinting(ped) then
            local stamina = GetPlayerSprintStaminaRemaining(PlayerId())
            if stamina >= 99.5 and GetEntitySpeed(ped) > 6.5 then
                report(FIREAC.InfinitePunishment, "Anti Infinite Stamina", ("Stamina stayed at %.2f"):format(stamina), "stamina", 8, 30000)
            else
                clearEvidence("stamina")
            end
        end

        if FIREAC.AntiNightVision and GetUsingnightvision() and not IsPedInAnyHeli(ped) then
            report(FIREAC.VisionPunishment, "Anti Night Vision", "Night vision enabled outside an allowed helicopter", "nightvision", 3)
        else
            clearEvidence("nightvision")
        end

        if FIREAC.AntiThermalVision and GetUsingseethrough() and not IsPedInAnyHeli(ped) then
            report(FIREAC.VisionPunishment, "Anti Thermal Vision", "Thermal vision enabled outside an allowed helicopter", "thermal", 3)
        else
            clearEvidence("thermal")
        end

        if FIREAC.AntiBlacklistTasks and type(Tasks) == "table" then
            for _, taskId in ipairs(Tasks) do
                if GetIsTaskActive(ped, taskId) then
                    report(FIREAC.TasksPunishment, "Anti Black List Tasks", "Task: " .. tostring(taskId), "task:" .. tostring(taskId), 2)
                    break
                end
            end
        end

        if FIREAC.AntiBlacklistAnims and type(Anims) == "table" then
            for _, anim in ipairs(Anims) do
                local dict = type(anim) == "table" and (anim.dict or anim[1]) or nil
                local name = type(anim) == "table" and (anim.anim or anim[2]) or nil
                if type(dict) == "string" and type(name) == "string" and IsEntityPlayingAnim(ped, dict, name, 3) then
                    report(FIREAC.AnimsPunishment, "Anti Black List Animation", dict .. "/" .. name,
                        "anim:" .. dict .. ":" .. name, 2)
                    ClearPedTasks(ped)
                    break
                end
            end
        end

        ::continue::
    end
end)

CreateThread(function()
    local rainbowChanges = 0
    local rainbowWindow = 0
    while true do
        Wait(1000)
        local allowed, ped = checksAllowed()
        if not allowed or not IsPedInAnyVehicle(ped, false) then
            state.lastVehicle = 0
            state.lastPlate = nil
            state.lastPrimaryColour = nil
            rainbowChanges = 0
            goto continue
        end

        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= state.lastVehicle then
            state.lastVehicle = vehicle
            state.lastPlate = GetVehicleNumberPlateText(vehicle)
            local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
            state.lastPrimaryColour = { r, g, b }
            rainbowWindow = now()
            rainbowChanges = 0
            goto continue
        end

        if FIREAC.AntiPlateChanger then
            local plate = GetVehicleNumberPlateText(vehicle)
            if state.lastPlate and plate ~= state.lastPlate then
                report(FIREAC.PlatePunishment, "Anti Plate Changer", state.lastPlate .. " -> " .. plate, "plate", 2)
                state.lastPlate = plate
            else
                clearEvidence("plate")
            end
        end

        if FIREAC.AntiBlackListPlate and type(Plate) == "table" then
            local currentPlate = (GetVehicleNumberPlateText(vehicle) or ""):gsub("%s+", "")
            for _, blocked in ipairs(Plate) do
                if currentPlate:upper() == tostring(blocked):gsub("%s+", ""):upper() then
                    report(FIREAC.PlatePunishment, "Anti Black List Plate", "Plate: " .. currentPlate, "blockedplate", 1)
                    break
                end
            end
        end

        if FIREAC.AntiRainbowVehicle then
            local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
            local old = state.lastPrimaryColour
            if old and (r ~= old[1] or g ~= old[2] or b ~= old[3]) then
                if now() - rainbowWindow > 5000 then
                    rainbowWindow = now()
                    rainbowChanges = 0
                end
                rainbowChanges = rainbowChanges + 1
                state.lastPrimaryColour = { r, g, b }
                if rainbowChanges >= 4 then
                    report(FIREAC.RainbowPunishment, "Anti Rainbow", "Vehicle colour changed rapidly", "rainbow", 2, 20000)
                    rainbowChanges = 0
                end
            end
        end

        if FIREAC.AntiChangeSpeed then
            local speed = GetEntitySpeed(vehicle)
            local maxSpeed = GetVehicleEstimatedMaxSpeed(vehicle)
            if maxSpeed > 1.0 and speed > maxSpeed + 18.0 then
                report(FIREAC.SpeedPunishment, "Anti Speed Changer", ("%.1f km/h, estimated max %.1f km/h"):format(speed * 3.6, maxSpeed * 3.6), "vehiclespeed", 4)
            else
                clearEvidence("vehiclespeed")
            end
        end

        ::continue::
    end
end)

AddEventHandler("gameEventTriggered", function(name, args)
    if not state.ready or now() < state.graceUntil then return end

    if FIREAC.AntiPickupCollect and name == "CEventNetworkPlayerCollectedPickup" then
        report(FIREAC.PickupPunishment, "Anti Collected Pickup", json.encode(args), "pickup", 2)
    end

    if FIREAC.AntiSuicide and name == "CEventNetworkEntityDamage" and args and args[1] == PlayerPedId() and args[2] == PlayerPedId() then
        report(FIREAC.SuicidePunishment, "Anti Suicide", "Self-inflicted network damage", "suicide", 2)
    end
end)

function FIREAC_ACTION(punishment, reason, details)
    report(punishment, reason, details, reason, 1)
end

function FIREAC_CHANGE_TEMP_WHHITELIST(status, durationMs)
    if status == true then
        local duration = math.min(math.max(tonumber(durationMs) or 60000, 1000), 600000)
        state.pausedUntil = now() + duration
    else
        state.pausedUntil = 0
    end
end

function FIREAC_CHANGE_TEMP_WHITELIST(status, durationMs)
    return FIREAC_CHANGE_TEMP_WHHITELIST(status, durationMs)
end

function FIREAC_CHECK_TEMP_WHITELIST()
    return now() < state.pausedUntil
end
