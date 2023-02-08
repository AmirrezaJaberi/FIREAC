--------[-----------------------------------]--------
--------[-----------------------------------]--------
--------[---- Copyright 2022 by FIREAC® ----]--------
--------[-----------------------------------]--------
--------[------ Dev By Amirreza Jaberi -----]--------
--------[-----------------------------------]--------

local SPAWN    = false
local TRACK    = 0

--【 𝗦𝗽𝗮𝘄𝗻 𝗠𝗮𝗻𝗮𝗴𝗲𝗺𝗲𝗻𝘁 】--
AddEventHandler('playerSpawned', function(data)
    Wait(5000)
    if SPAWN == false then
        SPAWN = false
        Wait(100)
        TriggerServerEvent('FIREAC:CheckIsAdmin')
        Wait(10000)
        while IsPlayerSwitchInProgress() do Wait(7500) end
        Wait(100)
        SPAWN = true
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(9)
        local PED = PlayerPedId()
        while IsPlayerSwitchInProgress() or IsPedFalling(PED) do
            Citizen.Wait(7500)
        end
        if FIREAC.AntiTeleport then
            if not IsPedInAnyVehicle(PED, false) and SPAWN and not IsPlayerSwitchInProgress() and not IsPlayerCamControlDisabled() then
                local _pos = GetEntityCoords(PED)
                Citizen.Wait(3000)
                local _newped = PlayerPedId()
                local _newpos = GetEntityCoords(_newped)
                local _distance = #(vector3(_pos) - vector3(_newpos))
                if _distance > FIREAC.MaxFootDistance and not IsEntityDead(PED) and not IsPedInParachuteFreeFall(PED) and not IsPedJumpingOutOfVehicle(PED) and PED == _newped and SPAWN == true and not IsPlayerSwitchInProgress() and not IsPlayerCamControlDisabled() then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TeleportPunishment, "Anti Teleport", "Used teleport hacks")
                end
            end
        end
        if FIREAC.AntiSuperJump then
            if DoesEntityExist(PED) and SPAWN and not IsPlayerSwitchInProgress() then
                local JUPING = IsPedJumping(PED)
                if JUPING then
                    TriggerServerEvent('FIREAC:CheckJumping', FIREAC.JumpPunishment, "Anti Superjump", "Used superjump hacks")
                end
            end
        end
    end
end)

--【 𝗖𝗵𝗲𝗰𝗸 𝗧𝗵r𝗲𝗮𝗱 1 】--
Citizen.CreateThread(function()
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
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpectatePunishment, "Anti Spectate", "Spectated another player")
                end
            end
            if FIREAC.AntiTrackPlayer then
                for i = 1, #PLS do
                    local TPED = GetPlayerPed(PLS[i])
                    if TPED ~= PED then
                        if DoesBlipExist(TPED) then
                            TRACK = TRACK + 1
                        end
                    end
                end
                if TRACK >= FIREAC.MaxTrack then
                    TriggerServerEvent('FIREAC:BanFromClient',  FIREAC.TrackPunishment, "Anti Track Player", "Tracked **"..TRACK.."** players") -- needs edit?
                end
            end
            if FIREAC.AntiHealthHack then
                if HEALTH > FIREAC.MaxHealth then
                    TriggerServerEvent('FIREAC:BanFromClient',  FIREAC.HealthPunishment, "Anti Health Hack", "Used health hacks : **"..HEALTH.."**")
                end
            end
            if FIREAC.AntiArmorHack then
                if ARMOR > FIREAC.MaxArmor then
                    TriggerServerEvent('FIREAC:BanFromClient',  FIREAC.HealthPunishment, "Anti Armor Hack", "Used armor hacks : **"..ARMOR.."**")
                end
            end
            if FIREAC.AntiBlackListWeapon then
                for _, weapon in ipairs(Weapon) do
                    if HasPedGotWeapon(PlayerPedId(), GetHashKey(weapon), false) == 1 then
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Black List Weapon", "Used blacklisted weapon : **"..weapon.."**")
                    end
                end
            end
            local CUHEALTH = GetEntityHealth(PlayerPedId())
            if FIREAC.AntiGodMode then
                if GetPlayerInvincible(PlayerId()) and not IsPlayerCamControlDisabled() and SPAWN then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti Godmode", "Used godmode hacks")
                end
                SetEntityHealth(PlayerPedId(), CUHEALTH - 2)
                Wait(250)
                if not IsPlayerDead(PlayerPedId()) and SPAWN and not IsPlayerCamControlDisabled() then
                    if GetEntityHealth(PlayerPedId()) == CUHEALTH and GetEntityHealth(PlayerPedId()) ~= 0 then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti Godmode", "Used godmode hacks")
                    elseif GetEntityHealth(PlayerPedId()) == CUHEALTH - 2 then
                        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 2)
                    end
                end
            end
            if FIREAC.AntiPlateChanger then
                if VEH ~= nil then
                    if PLATE ~= nil then
                        local RPED = PlayerPedId()
                        if IsPedInAnyVehicle(RPED, false) then
                            local RVEH   = GetVehiclePedIsIn(PED, false)
                            local RPLATE = GetVehicleNumberPlateText(RVEH)
                            local RHASH  = GetHashKey(RVEH)
                            if RPLATE ~= PLATE and RHASH == VEHHASH then
                                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti Plate Changer", "Changed the vehicle plate : **"..PLATE.." --> "..RPLATE.."**")
                            else
                                Wait(0)
                            end
                        else
                            Wait(0)
                        end
                        else
                        Wait(0)
                    end
                else
                    Wait(0)
                end
            end
            if FIREAC.AntiInfiniteStamina then
                if GetEntitySpeed(PlayerPedId()) > 7 and not IsPedInAnyVehicle(PlayerPedId(), true) and not IsPedFalling(PlayerPedId()) and not IsPedInParachuteFreeFall(PlayerPedId()) and not IsPedJumpingOutOfVehicle(PlayerPedId()) and not IsPedRagdoll(PlayerPedId()) then
                    local staminalevel = GetPlayerSprintStaminaRemaining(PlayerId())
                    if tonumber(staminalevel) == tonumber(0.0) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InfinitePunishment, "Anti Infinite Stamina", "Used stamina hacks")
                    end
                end
            end
            if FIREAC.AntiRagdoll then
                if SPAWN then
                    if not CanPedRagdoll(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId(), true) and not IsEntityDead(PlayerPedId()) and not IsPedJumpingOutOfVehicle(PlayerPedId()) and not IsPedJacking(PlayerPedId()) and IsPedRagdoll(PlayerPedId()) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InfinitePunishment, "Anti Ragdoll", "Used ragdoll hack")
                    end
                end
            end
            if FIREAC.AntiNightVision then
                if GetUsingnightvision(true) and not IsPedInAnyHeli(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.VisionPunishment, "Anti Night Vision", "Used night vision hack")
                end
            end
            if FIREAC.AntiNightVision then
                if GetUsingseethrough(true) and not IsPedInAnyHeli(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.VisionPunishment, "Anti Thermal Vision", "Used thermal vision hack")
                end
            end
            Wait(2000)
            if FIREAC.AntiInvisible then
                if SPAWN then
                    if (not IsEntityVisible(PlayerPedId()) and not IsEntityVisibleToScript(PlayerPedId())) or (GetEntityAlpha(PlayerPedId()) <= 150 and GetEntityAlpha(PlayerPedId()) ~= 0) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InvisiblePunishment, "Anti Invisble", "Used invisibility hacks")
                    end
                else
                    Wait(1000)
                end
            end
            if FIREAC.AntiBlackListPlate then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    for _, plate in ipairs(Plate) do
                         NPLATE = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false), false)
                        if NPLATE == plate then
                           TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PlatePunishment, "Anti Black List Plate", "Used blacklisted plate : "..plate.."") -- might work, needs check
                        end
                    end
                end
            end
            if FIREAC.AntiRainbowVehicle then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    local VEH = GetVehiclePedIsIn(PlayerPedId(), false)
                    if DoesEntityExist(VEH) then
                        local C1r, C1g, C1b = GetVehicleCustomPrimaryColour(VEH)
                        Wait(1000)
                        local C2r, C2g, C2b = GetVehicleCustomPrimaryColour(VEH)
                        Wait(2000)
                        local C3r, C3g, C3b = GetVehicleCustomPrimaryColour(VEH)
                        if C1r ~= nil then
                            if C1r ~= C2r and C2r ~= C3r and C1g ~= C2g and C3g ~= C2g and C1b ~= C2b and C3b ~= C2b then
                                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.RainbowPunishment, "Anti Rainbow", "Used rainbow hacks")
                            end 
                        end
                    end
                else
                    Wait(0)
                end
            end
            if FIREAC.AntiNoclip then
                if not IsPedInAnyVehicle(PlayerPedId(), false) and GetEntityHeightAboveGround(PlayerPedId()) > 4.0 and not IsPedFalling(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.NoclipPunishment, "Anti Noclip", "Used noclip hack")
                end
            end
            if FIREAC.AntiFreeCam then
                local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()) - GetFinalRenderedCamCoord())
                if (x > 50) or (y > 50) or (z > 50) or (x < -50) or (y < -50) or (z < -50) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.CamPunishment, "Anti Free Cam", "Used freecam hacks")
                end
            end
            if FIREAC.AntiMenyoo then
                if IsPlayerCamControlDisabled() ~= false then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.MenyooPunishment, "Anti Menyoo", "Used menyoo camera hack")
                end
            end
            if FIREAC.AntiAimAssist then
                local aimassiststatus = GetLocalPlayerAimState()
                if aimassiststatus ~= 3 then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AimAssistPunishment, "Anti Aim Assist", "Used aim assist : **"..aimassiststatus.."**")
                end
            end
            if FIREAC.AntiWeaponDamageChanger then
                local WEAPON    = GetSelectedPedWeapon(PlayerPedId())
                local WEPDAMAGE = math.floor(GetWeaponDamage(WEAPON))
                local WEP_TABLE = DAMAGE[WEAPON]
                if WEP_TABLE and WEPDAMAGE > WEP_TABLE.DAMAGE then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Weapon Damage Changer", "Tried to change" .. WEP_TABLE.name .. " damage to " .. WEPDAMAGE .. " (Normal damage is: " .. WEP_TABLE.DAMAGE ..")")
                end
            end
            if FIREAC.AntiWeaponsExplosive then
                local WEAPON    = GetSelectedPedWeapon(PlayerPedId())
                local WEAPON_DAMAEG = GetWeaponDamageType(WEAPON)
                N_0x4757f00bc6323cfe(GetHashKey("WEAPON_EXPLOSION"), 0.0) 
                if WEAPON_DAMAEG == 4 or WEAPON_DAMAEG == 5 or WEAPON_DAMAEG == 6 or WEAPON_DAMAEG == 13 then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Weapon Explosive", "Tried to use explosive weapon damage")
                end
            end
            if FIREAC.AntiPedChanger then
                for i, value in ipairs(WhiteListPeds) do
                    if not GetEntityModel(PlayerPedId()) == GetHashKey(value) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedChangePunishment, "Anti Ped Changer", "Tried to change ped to "..value.."!")
                    end
                end
            end
            if FIREAC.AntiBlacklistTasks then
                for _,task in pairs(Tasks) do
                    if GetIsTaskActive(PlayerPedId(), task) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TasksPunishment, "Anti Black List Tasks", "Tried to play task in server "..task.."!")
                    end
                end
            end
            if FIREAC.AntiBlacklistAnims then
                for _,anim in pairs(Anims) do
                    if IsEntityPlayingAnim(PlayerPedId(), anim[1], anim[2], 3) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AnimsPunishment, "Anti Black List Animation", "Tried to play blacklisted animation "..anim[1]" and "..anim[2].."")
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
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedFlagPunishment, "Anti Tiny Ped", "Tried to turn into tiny ped")
                end
                Wait(100)
            end
            if FIREAC.AntiTinyPed then
                local Tiny = GetPedConfigFlag(PlayerPedId(), 223, true)
                if Tiny then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedFlagPunishment, "Anti Tiny Ped", "Tried to turn into tiny ped")
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
        local PED   = PlayerPedId()
        local JUMP  = IsPedJumping(PED)
        if FIREAC.AntiChangeSpeed then
            if SPAWN then
                if IsPedInAnyVehicle(PED, false) then
                    local VEH       = GetVehiclePedIsIn(PED, false)
                    local MAX_SPEED = GetVehicleEstimatedMaxSpeed(VEH)
                    local VEHSPED   = GetEntitySpeed(VEH)
                    local TOTAL     = MAX_SPEED + 10
                    if VEHSPED > TOTAL then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpeedPunishment, "Anti Speed Changer", "Tried to change the vehicle speed : **".. VEHSPED * 3.6 .." KM**")
                    end
                else
                    local ENSPEED = GetEntitySpeed(PED)
                    if IsPedRunning(PED) and ENSPEED > 9 and not JUMP then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpeedPunishment, "Anti Fast Run", "Tried to change the walk speed : **".. ENSPEED .."**") 
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
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TeleportPunishment, "Anti Teleport", "Tried teleporting in vehicle")
                end
            end
        end
        Wait(0)
    end
end)

--【 𝗦𝘁𝗼𝗽 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 】--
AddEventHandler("onClientResourceStop", function(RES)
    if FIREAC.AntiResourceStopper or FIREAC.AntiResourceRestarter then
        if RES == "FIREAC" then TriggerServerEvent('FIREAC:BanFromClient', FIREAC.ResourcePunishment, "Anti Resource Stopper", "Tried to stop resource : **"..RES.."** !") CancelEvent() end
        if SPAWN then
            TriggerServerEvent('FIREAC:BanFromClient', FIREAC.ResourcePunishment, "Anti Resource Stopper", "Tried to stop resource : **"..RES.."** !")
        end
    end
end)

--【 𝗦𝘁𝗮𝗿𝘁 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 】--
AddEventHandler('onClientResourceStart', function (RES)
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
                TriggerServerEvent("FIREAC:BanFromClient", FIREAC.ResourcePunishment, "Anti Resource Starter", "Tried to start resource : **"..RES.."** !")
                break
            end
        end
    end)
end
--【 𝗔𝗻𝘁𝗶 𝗦𝘂𝗶𝗰𝗶𝗱𝗲 】--
AddEventHandler("gameEventTriggered", function(name, args)
    local PLID     = PlayerId()
    local PED      = PlayerPedId()
    local ENOWNER  = GetPlayerServerId(NetworkGetEntityOwner(args[2]))
    local ENOWNER1 = NetworkGetEntityOwner(args[1])
    local ARMED     = false
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
    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PickupPunishment, "Anti Collected Pickup", "Tried to collect a pickup : "..json.encode(args).."")
    end
end)
