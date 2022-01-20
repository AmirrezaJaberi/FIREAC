--[[[
        -----------------------------------
        -----------------------------------
        ---- Copyright 2022 by FIREAC® ----
        -----------------------------------
        ------ Dev By AmIrReZa#2080 -------
        -----------------------------------

]]

local SPAWN    = false
local TRACK    = 0
local lastcoordsx = nil
local lastcoordsy = nil

--【 𝗦𝗽𝗮𝘄𝗻 𝗠𝗮𝗻𝗮𝗴𝗲𝗺𝗲𝗻𝘁 】--
AddEventHandler('playerSpawned', function()
    Wait(2000)
    if SPAWN == false then
        Wait(10000)
        while IsPlayerSwitchInProgress() do
            Wait(1000)
        end
        TriggerServerEvent('FIREAC:CheckIsAdmin')
        SPAWN = true
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(9)
        local PED = PlayerPedId()
        while IsPlayerSwitchInProgress() or IsPedFalling(PED) do
            Citizen.Wait(5000)
        end
        if FIREAC.AntiTeleport then
            if not IsPedInAnyVehicle(PED, false) and SPAWN and not IsPlayerSwitchInProgress() then
                local _pos = GetEntityCoords(PED)
                Citizen.Wait(3000)
                local _newped = PlayerPedId()
                local _newpos = GetEntityCoords(_newped)
                local _distance = #(vector3(_pos) - vector3(_newpos))
                if _distance > FIREAC.MaxFootDistence and not IsEntityDead(PED) and not IsPedInParachuteFreeFall(PED) and not IsPedJumpingOutOfVehicle(PED) and PED == _newped and SPAWN == true and not IsPlayerSwitchInProgress() then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TeleportPunishment, "Anti Teleport", "Try For Teleport in Server")
                end
            end 
        end
        if FIREAC.AntiSuperJump then
            if DoesEntityExist(PED) and SPAWN and not IsPlayerSwitchInProgress() then
                local JUPING = IsPedJumping(PED)
                if JUPING then
                    TriggerServerEvent('FIREAC:CheckJumping', FIREAC.JumpPunishment, "Anti SuperJump", "Try For Superjump in server")
                end
            end
        end
    end
end)

--【 𝗖𝗵𝗲𝗰𝗸 𝗧𝗵𝗲𝗮𝗿𝗱 1 】--
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
            if FIREAC.AntiSpactate then
                if NetworkIsInSpectatorMode() then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpactatePunishment, "Anti Spactate", "Try For Spactate on other player")
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
                    TriggerServerEvent('FIREAC:BanFromClient',  FIREAC.TrackPunishment, "Anti Track Player", "Try For Track **"..TRACK.."** Player's")
                end
            end
            if FIREAC.AntiHealthHack then
                if HEALTH > FIREAC.MaxHealth then
                    TriggerServerEvent('FIREAC:BanFromClient',  FIREAC.HealthPunishment, "Anti Health Hack", "Try For Hack Health : **"..HEALTH.."**")
                end
            end
            if FIREAC.AntiArmorHack then
                if ARMOR > FIREAC.MaxArmor then
                    TriggerServerEvent('FIREAC:BanFromClient',  FIREAC.HealthPunishment, "Anti Armor Hack", "Try For Hack Armor : **"..ARMOR.."**")
                end
            end
            if FIREAC.AntiBlackListWeapon then
                for _, weapon in ipairs(Weapon) do
                    if HasPedGotWeapon(PlayerPedId(), GetHashKey(weapon), false) == 1 then
                        RemoveAllPedWeapons(PlayerPedId(), true)
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Black List Weapon", "Try For Add Black List Weapon: **"..weapon.."**")
                    end
                end
            end
            local CUHEALTH = GetEntityHealth(PlayerPedId())
            if FIREAC.AntiGodMode then
                if GetPlayerInvincible(PlayerId()) and SPAWN then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti GodeMod", "Try For GodeMode Ped in server")
                end
                SetEntityHealth(PlayerPedId(), CUHEALTH - 2)
                Wait(250)
                if not IsPlayerDead(PlayerPedId()) then
                    if GetEntityHealth(PlayerPedId()) == CUHEALTH and GetEntityHealth(PlayerPedId()) ~= 0 then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti GodeMod", "Try For GodeMode Ped in server")
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
                                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.GodPunishment, "Anti Plate Changer", "Try For Change Plate : **"..PLATE.." --> "..RPLATE.."**")
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
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InfinitePunishment, "Anti Infinite Stamina", "Try For Enable Infinite Stamina")
                    end
                end
            end
            if FIREAC.AntiRagdoll then
                if not CanPedRagdoll(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId(), true) and not IsEntityDead(PlayerPedId()) and not IsPedJumpingOutOfVehicle(PlayerPedId()) and not IsPedJacking(PlayerPedId()) and IsPedRagdoll(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InfinitePunishment, "Anti Ragdoll", "Try For Enable Ragdoll by cheat menu")
                end
            end
            if FIREAC.AntiNightVision then
                if GetUsingnightvision(true) and not IsPedInAnyHeli(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.VisionPunishment, "Anti Night Vision", "Try For Enable Night Vision")
                end
            end
            if FIREAC.AntiNightVision then
                if GetUsingseethrough(true) and not IsPedInAnyHeli(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.VisionPunishment, "Anti Termal Vision", "Try For Enable Termal Vision")
                end
            end
            Wait(2000)
            if FIREAC.AntiInvisble then
                while IsPlayerSwitchInProgress() do
                    Wait(5000)
                end
                local entityalpha = GetEntityAlpha(PlayerPedId())
                if not IsEntityVisible(PlayerPedId()) or not IsEntityVisibleToScript(PlayerPedId()) or entityalpha <= 150 and SPAWN and not IsPlayerSwitchInProgress() then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.InvisiblePunishment, "Anti Invisble", "Try For Invisible in server")
                end
            end
            if FIREAC.AntiBlackListPlate then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    for _, plate in ipairs(Plate) do
                         NPLATE = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false), false)
                        if NPLATE == plate then
                           TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PlatePunishment, "Anti Black List Plate", "Try for spawn vehicle by blacklist plate !")
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
                                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.RainbowPunishment, "Anti Rainbow", "Try for rainbow rgb vehicle color !")
                            end 
                        end
                    end
                else
                    Wait(0)
                end
            end
            if FIREAC.AntiFreeCam then
                local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()) - GetFinalRenderedCamCoord())
                if (x > 50) or (y > 50) or (z > 50) or (x < -50) or (y < -50) or (z < -50) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.CamPunishment, "Anti Free Cam", "Try For going to freecam")
                end
            end
            if FIREAC.AntiMenyoo then
                if IsPlayerCamControlDisabled() ~= false then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.MenyooPunishment, "Anti Menyoo", "Try For going to menyoo (other cam)")
                end
            end
            if FIREAC.AntiAimAssist then
                local aimassiststatus = GetLocalPlayerAimState()
                if aimassiststatus ~= 3 then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AimAssistPunishment, "Anti Aim Assist", "Try For Use Aim Assist : **"..aimassiststatus.."**")
                end
            end
            if FIREAC.AntiWeaponDamageChanger then
                local WEAPON    = GetSelectedPedWeapon(PlayerPedId())
                local WEPDAMAGE = math.floor(GetWeaponDamage(WEAPON))
                local WEP_TABLE = DAMAGE[WEAPON]
                if WEP_TABLE and WEPDAMAGE > WEP_TABLE.DAMAGE then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Weapon Damage Changer", "Tried to change" .. WEP_TABLE.name .. " Damage to " .. WEPDAMAGE .. " (Normal Damage Is: " .. WEP_TABLE.DAMAGE ..")")
                end
            end
            if FIREAC.AntiWeaponsExplosive then
                local WEAPON    = GetSelectedPedWeapon(PlayerPedId())
                local WEAPON_DAMAEG = GetWeaponDamageType(WEAPON)
                N_0x4757f00bc6323cfe(GetHashKey("WEAPON_EXPLOSION"), 0.0) 
                if WEAPON_DAMAEG == 4 or WEAPON_DAMAEG == 5 or WEAPON_DAMAEG == 6 or WEAPON_DAMAEG == 13 then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.WeaponPunishment, "Anti Weapon Explosive", "Tried to use explosive weapon damage!")
                end
            end
            if FIREAC.AntiPedChanger then
                local PPED    = PlayerPedId()
                local ENMODEL = GetEntityModel(PPED)
                for i, value in ipairs(WhiteListPeds) do
                    if not GetEntityModel(ENMODEL) == GetHashKey(WhiteListPeds) then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedChangePunishment, "Anti Ped Changer", "Tried to change ped to "..ENMODEL.."!")
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
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AnimsPunishment, "Anti Black List Animation", "Tried to play black list animation "..anim[1]" and "..anim[2].."")
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
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedFlagPunishment, "Anti Tiny Ped", "Tried to Tiny Self Ped")
                end
                Wait(100)
            end
            if FIREAC.AntiTinyPed then
                local Tiny = GetPedConfigFlag(PlayerPedId(), 223, true)
                if Tiny then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PedFlagPunishment, "Anti Tiny Ped", "Tried to Tiny Self Ped")
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
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpeedPunishment, "Anti Speed Changer", "Try For Change Speed Vehicle : **".. VEHSPED * 3.6 .." KM**")
                    end
                else
                    local ENSPEED = GetEntitySpeed(PED)
                    if IsPedRunning(PED) and ENSPEED > 9 and not JUMP then
                        TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SpeedPunishment, "Anti Fast Run", "Try For Change Speed Ped : **".. ENSPEED .."**") 
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
                if IsPedInAnyVehicle(PlayerPedId(), false) and DISTENCE >= FIREAC.MaxVehicleDistence and not IsPedFalling(PlayerPedId()) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.TeleportPunishment, "Anti Teleport", "Try for teleport in server (by vehicle)")
                end
            end
        end
        if IsAimCamActive() then
            local _isaiming, _entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if _isaiming and _entity then
                if IsEntityAPed(_entity) and not IsEntityDead(_entity) and not IsPedStill(_entity) and not IsPedStopped(_entity) and not IsPedInAnyVehicle(_entity, false) then
                    local _entitycoords = GetEntityCoords(_entity)
                    local retval, screenx, screeny = GetScreenCoordFromWorldCoord(_entitycoords.x, _entitycoords.y, _entitycoords.z)
                    if screenx == lastcoordsx or screeny == lastcoordsy then
                        if FIREAC.AntiAimBot  then
                            TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AimBotPunishment, "Anti AimBot", "Try for enable aim bot in server")
                        end
                    end
                    lastcoordsx = screenx
                    lastcoordsy = screeny
                end
            end
        end
        Wait(0)
    end
end)

--【 𝗦𝘁𝗼𝗽 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 】--
AddEventHandler("onClientResourceStop", function(RES)
    if FIREAC.AntiResourceStoper or FIREAC.AntiResourceRestarter then
        if RES == "FIREAC" then TriggerServerEvent('FIREAC:BanFromClient', FIREAC.ResourcePunishment, "Anti Resource Stopper", "Try for stop resource : **"..RES.."** !") CancelEvent() end
        if SPAWN then
            TriggerServerEvent('FIREAC:BanFromClient', FIREAC.ResourcePunishment, "Anti Resource Stopper", "Try for stop resource : **"..RES.."** !")
        end
    end
end)

--【 𝗦𝘁𝗮𝗿𝘁 𝗥𝗲𝘀𝗼𝘂𝗿𝗰𝗲 】--
AddEventHandler('onClientResourceStart', function (RES)
    while IsPlayerSwitchInProgress() do
        Wait(1000)
    end
    if not IsPlayerSwitchInProgress() then
        SPAWN = true
    end
    TriggerServerEvent('FIREAC:CheckIsAdmin')
    if FIREAC.AntiResourceStarter or FIREAC.AntiResourceRestarter then
        if SPAWN then
            TriggerServerEvent('FIREAC:BanFromClient', FIREAC.ResourcePunishment, "Anti Resource Starter", "Try for start resource : **"..RES.."** !")
        end
    end
end)

--【 𝗔𝗻𝘁𝗶 𝗦𝘂𝗶𝗰𝗶𝗱𝗲 】--
AddEventHandler("gameEventTriggered", function(name, args)
    local PLID     = PlayerId()
    local ENOWNER  = GetPlayerServerId(NetworkGetEntityOwner(args[2]))
    local ENOWNER1 = NetworkGetEntityOwner(args[1])
    local BUILD     = GetConvarInt('sv_enforceGameBuild', 2189)
    while IsPlayerSwitchInProgress() do
        Citizen.Wait(5000)
    end
    if ENOWNER == GetPlayerServerId(PlayerId()) or args[2] == -1 and FIREAC.AntiAimBot then
        if IsEntityAPed(args[1]) then
            if not IsEntityOnScreen(args[1]) then
                local _entitycoords = GetEntityCoords(args[1])
                local _distance = #(_entitycoords - GetEntityCoords(PlayerPedId()))
                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AimBotPunishment, "Anti Aim Hacking", "Shot Player Without Being On His Screen (DIS : ".._distance..")")
            end
            if isarmed and lastentityplayeraimedat ~= args[1] and IsPedAPlayer(args[1]) and PLID ~= ENOWNER1 then
                TriggerServerEvent('FIREAC:BanFromClient', FIREAC.AimBotPunishment, "Anti AimBot", "Try for enable aim bot in server")
                Citizen.Wait(3000)
            end
        end
    end
    if FIREAC.AntiSuicide then
        if name == 'CEventNetworkEntityDamage' and args[2] == -1 and not IsEntityDead(args[1]) then
            if BUILD == 2189 then
                if args[7] == tonumber(-842959696) and ENOWNER1 == PlayerId() and IsEntityDead(args[1]) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SuiPunishment, "Anti Suicide", "Try Kill (Suicide) Player")
                end
            else
                if args[5] == tonumber(-842959696) and ENOWNER1 == PlayerId() and IsEntityDead(args[1]) then
                    TriggerServerEvent('FIREAC:BanFromClient', FIREAC.SuiPunishment, "Anti Suicide", "Try Kill (Suicide) Player")
                end
            end
        end
    end
    if name == 'CEventNetworkPlayerCollectedPickup' then
        if FIREAC.AntiCollectedPickup then
            TriggerServerEvent('FIREAC:BanFromClient', FIREAC.PickupePunishment, "Anti Collected Pickup", "Try Collected Pickup : "..json.encode(args).."")
        end
    end
end)