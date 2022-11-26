--------[-----------------------------------]--------
--------[-----------------------------------]--------
--------[---- Copyright 2022 by FIREAC® ----]--------
--------[-----------------------------------]--------
--------[------ Dev By Amirreza Jaberi -----]--------
--------[-----------------------------------]--------

local Access          = false
local isusingfuncs    = false
local isnoclipping    = false
local noclipspeed     = 1
local isnoclippingveh = false
local noclipveh       = 1
local playerid        = nil
local Players         = {}
local InSpectatorMode = false
local SpacateCoords   = nil
local TargetSpectate  = nil

RegisterNetEvent('FIREAC:AddAdminOption')
AddEventHandler('FIREAC:AddAdminOption', function (DATA)
    if DATA ~= nil then
        DrawNotificationForPlayer('~h~~o~FIREAC:~s~~g~~h~ You Are Joined As Administrator !~s~')
        Access = true
    end
end)

RegisterNetEvent('FIREAC:GetPlayerList')
AddEventHandler('FIREAC:GetPlayerList', function (PLIST)
    Players = PLIST
end)

RegisterNetEvent('FIREAC:SpectatePlayer')
AddEventHandler('FIREAC:SpectatePlayer', function(TARGET ,COORDS)
    if COORDS ~= nil then
        FIREAC_SPECTATE(TARGET, COORDS)
    end
end)

Citizen.CreateThread(function()
    Wait(1000)
    while true do
        Citizen.Wait(0)
        if Access then
            if isusingfuncs then
                if isnoclipping then
                    local _ped = PlayerPedId()
                    local _pcoords = GetEntityCoords(_ped)
                    local _x = _pcoords.x
                    local _y = _pcoords.y
                    local _z = _pcoords.z
                    local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(PlayerPedId())
                    local pitch = GetGameplayCamRelativePitch()
                    local x = -math.sin(heading*math.pi/180.0)
                    local y = math.cos(heading*math.pi/180.0)
                    local z = math.sin(pitch*math.pi/180.0)
                    local len = math.sqrt(x*x+y*y+z*z)
                    if len ~= 0 then
                      x = x/len
                      y = y/len
                      z = z/len
                    end
                    local _camx = x
                    local _camy = y
                    local _camz = z
                    if IsControlPressed(0, 32) then
                        _x = _x + noclipspeed * _camx
                        _y = _y + noclipspeed * _camy
                        _z = _z + noclipspeed * _camz
                    elseif IsControlPressed(0, 33) then
                        _x = _x - noclipspeed * _camx
                        _y = _y - noclipspeed * _camy
                        _z = _z - noclipspeed * _camz
                    end
                    SetEntityVisible(_ped, false)
                    SetEntityVelocity(_ped, 0.05,  0.05,  0.05)
                    SetEntityCoordsNoOffset(_ped, _x, _y, _z, true, true, true) 
                end
                if isnoclippingveh then
                    local _ped = GetVehiclePedIsIn(PlayerPedId(), false)
                    local _pcoords = GetEntityCoords(_ped)
                    local _x = _pcoords.x
                    local _y = _pcoords.y
                    local _z = _pcoords.z
                    local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(PlayerPedId())
                    local pitch = GetGameplayCamRelativePitch()
                    local x = -math.sin(heading*math.pi/180.0)
                    local y = math.cos(heading*math.pi/180.0)
                    local z = math.sin(pitch*math.pi/180.0)
                    local len = math.sqrt(x*x+y*y+z*z)
                    if len ~= 0 then
                      x = x/len
                      y = y/len
                      z = z/len
                    end
                    local _camx = x
                    local _camy = y
                    local _camz = z
                    if IsControlPressed(0, 32) then
                        _x = _x + noclipveh * _camx
                        _y = _y + noclipveh * _camy
                        _z = _z + noclipveh * _camz
                    elseif IsControlPressed(0, 33) then
                        _x = _x - noclipveh * _camx
                        _y = _y - noclipveh * _camy
                        _z = _z - noclipveh * _camz
                    end
                    SetEntityVisible(_ped, false)
                    SetEntityVelocity(_ped, 0.05,  0.05,  0.05)
                    SetEntityCoordsNoOffset(_ped, _x, _y, _z, true, true, true) 
                end
            end
        else
            break
        end
    end
end)
-- MENU 2
local menu2 = MenuV:CreateMenu(false, 'FIREAC Admin Tools', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'FIREAC: Admin Menu')
local menu2_noclip = menu2:AddCheckbox({ icon = ''..Emoji.Beard..'', label = 'NoClip', description = 'Activate/Deactivate NoClip', value = 'n' })
local menu2_range = menu2:AddRange({ icon = ''..Emoji.Speed..'', label = 'NoClip Speed', description = 'Set Noclip Speed', min = 0, max = 10, value = 0, saveOnUpdate = true })
local menu2_godmode = menu2:AddCheckbox({ icon = ''..Emoji.GodMode..'', label = 'GodMode', description = 'Activate/Deactivate GodMode',value = 'n' })
local menu2_invisible = menu2:AddCheckbox({ icon = ''..Emoji.Ghost..'', description = 'Activate/Deactivate Invisibility', label = 'Invisible', value = 'n' })
local menu2_suicide = menu2:AddButton({ icon = ''..Emoji.Kill..'', description = 'Kill player', label = 'Suicide' })
local menu2_revive = menu2:AddButton({ icon = ''..Emoji.RGB..'️', description = 'Revive yourself', label = 'Revive' })
local menu2_healplayer = menu2:AddButton({ icon = ''..Emoji.Heal..'', description = 'Heal yourself', label = 'Heal' })
local menu2_givearmor = menu2:AddButton({ icon = ''..Emoji.Armor..'', description = 'Give Yourself Armor', label = 'Give Armor' })
local menu2_giveallweapons = menu2:AddButton({ icon = ''..Emoji.Weapon..'', description = 'Give All Weapons to Yourself', label = 'Give All Weapons' })
local menu2_removeallweapons = menu2:AddButton({ icon = ''..Emoji.No..'', description = 'Remove All of Your Weapons', label = 'Remove All Weapons' })
local menu2_showcoords = menu2:AddButton({ icon = ''..Emoji.Coords..'', description = 'Print Player Coords (F8)', label = 'Print Coords (F8)' })
menu2_noclip:On('check', function(item)
    isusingfuncs = true
    isnoclipping = true
end)
menu2_noclip:On('uncheck', function(item)
    isusingfuncs = false
    isnoclipping = false
    SetEntityVisible(PlayerPedId(), true)
end)
menu2_range:On('change', function(item, newValue, oldValue)
    noclipspeed = newValue
end)
menu2_godmode:On('check', function(item)
    SetEntityInvincible(PlayerPedId(), true)
end)
menu2_godmode:On('uncheck', function(item)
    SetEntityInvincible(PlayerPedId(), false)
end)
menu2_invisible:On('check', function(item)
    SetEntityVisible(PlayerPedId(), false)
end)
menu2_invisible:On('uncheck', function(item)
    SetEntityVisible(PlayerPedId(), true)
end)
menu2_suicide:On('select', function(item)
    SetEntityHealth(PlayerPedId(), 0)
end)
menu2_revive:On('select', function(item)
    TriggerEvent('esx_ambulancejob:revive') -- Change trigger if needed
end)
menu2_healplayer:On('select', function(item)
    local _ped = PlayerPedId()
    SetEntityHealth(_ped, 200)
    ClearPedBloodDamage(_ped)
    ResetPedVisibleDamage(_ped)
    ClearPedLastWeaponDamage(_ped)
end)
menu2_givearmor:On('select', function(item)
    SetPedArmour(PlayerPedId(), 100)
end)
local weapons = {'WEAPON_UNARMED', 'WEAPON_KNIFE', 'WEAPON_KNUCKLE', 'WEAPON_NIGHTSTICK', 'WEAPON_HAMMER', 'WEAPON_BAT', 'WEAPON_GOLFCLUB', 'WEAPON_CROWBAR', 'WEAPON_BOTTLE', 'WEAPON_DAGGER', 'WEAPON_HATCHET', 'WEAPON_MACHETE', 'WEAPON_FLASHLIGHT', 'WEAPON_SWITCHBLADE', 'WEAPON_PISTOL', 'WEAPON_PISTOL_MK2', 'WEAPON_COMBATPISTOL', 'WEAPON_APPISTOL', 'WEAPON_PISTOL50', 'WEAPON_SNSPISTOL', 'WEAPON_HEAVYPISTOL', 'WEAPON_VINTAGEPISTOL', 'WEAPON_STUNGUN', 'WEAPON_FLAREGUN', 'WEAPON_MARKSMANPISTOL', 'WEAPON_REVOLVER', 'WEAPON_MICROSMG', 'WEAPON_SMG', 'WEAPON_MINISMG', 'WEAPON_SMG_MK2', 'WEAPON_ASSAULTSMG', 'WEAPON_MG', 'WEAPON_COMBATMG', 'WEAPON_COMBATMG_MK2', 'WEAPON_COMBATPDW', 'WEAPON_GUSENBERG', 'WEAPON_RAYPISTOL', 'WEAPON_MACHINEPISTOL', 'WEAPON_ASSAULTRIFLE', 'WEAPON_ASSAULTRIFLE_MK2', 'WEAPON_CARBINERIFLE', 'WEAPON_CARBINERIFLE_MK2', 'WEAPON_ADVANCEDRIFLE', 'WEAPON_SPECIALCARBINE', 'WEAPON_BULLPUPRIFLE', 'WEAPON_COMPACTRIFLE', 'WEAPON_PUMPSHOTGUN', 'WEAPON_SAWNOFFSHOTGUN', 'WEAPON_BULLPUPSHOTGUN', 'WEAPON_ASSAULTSHOTGUN', 'WEAPON_MUSKET', 'WEAPON_HEAVYSHOTGUN', 'WEAPON_DBSHOTGUN', 'WEAPON_SNIPERRIFLE', 'WEAPON_HEAVYSNIPER', 'WEAPON_HEAVYSNIPER_MK2', 'WEAPON_MARKSMANRIFLE', 'WEAPON_GRENADELAUNCHER', 'WEAPON_GRENADELAUNCHER_SMOKE', 'WEAPON_RPG', 'WEAPON_STINGER', 'WEAPON_FIREWORK', 'WEAPON_HOMINGLAUNCHER', 'WEAPON_GRENADE', 'WEAPON_STICKYBOMB', 'WEAPON_PROXMINE', 'WEAPON_MINIGUN', 'WEAPON_RAILGUN', 'WEAPON_POOLCUE', 'WEAPON_BZGAS', 'WEAPON_SMOKEGRENADE', 'WEAPON_MOLOTOV', 'WEAPON_FIREEXTINGUISHER', 'WEAPON_PETROLCAN', 'WEAPON_SNOWBALL', 'WEAPON_FLARE', 'WEAPON_BALL'}
menu2_giveallweapons:On('select', function(item)
    for _, weapon in pairs(weapons) do
        local _whash = GetHashKey(weapon)
        GiveWeaponToPed(PlayerPedId(), _whash, 3000)
    end
end)
menu2_removeallweapons:On('select', function(item)
    for _, weapon in pairs(weapons) do
        local _whash = GetHashKey(weapon)
        RemoveWeaponFromPed(PlayerPedId(), _whash)
    end
end)

menu2_showcoords:On('select', function(item)
    local _coords = GetEntityCoords(PlayerPedId())
    print(_coords)
end)

-- MENU 7
local menu7            = MenuV:CreateMenu(false, 'Player Menu', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'Connected Players')
local menu7_screenshot = menu7:AddButton({ icon = ''..Emoji.Camera..'', label = 'ScreenShot', value = menu7_screenshot, description = 'Get Screenshot From Player By Menu'})
local menu7_ban        = menu7:AddButton({ icon = ''..Emoji.Ban..'', label = 'Ban',        value = menu7_ban, description = 'Ban Player By Menu'})
local menu7_Spectate   = menu7:AddCheckbox({ icon = ''..Emoji.Glasses..'', label = 'Spectate', description = 'Spectate a Player', value = 'n' })
menu7_screenshot:On('select', function(item)
    TriggerServerEvent('FIREAC:GetScreenShot', playerid)
end)
menu7_ban:On('select', function(item)
    TriggerServerEvent('FIREAC:BanByMenu', playerid)
end)

menu7_Spectate:On('check', function(item)
    TriggerServerEvent('FIREAC:ReqSpectate', playerid)
end)

menu7_Spectate:On('uncheck', function(item)
	FIREAC_RESETCAMERA()
end)

-- MENU 3
local menu3 = MenuV:CreateMenu(false, 'FIREAC: Connected Players', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'FIREAC: Connected Players')
menu3:On('open', function(m)
    m:ClearItems()
    TriggerServerEvent('FIREAC:MenuOpened')
    Citizen.Wait(500)
    for k,v in pairs(Players) do
        local player = menu3:AddButton({ icon = ''..Emoji.Bot..'', label = v.name, value = menu7, description = 'Server ID: '..v.id})
        if player then
            playerid = v.id
        end
    end
end)

-- MENU 4
local menu4 = MenuV:CreateMenu(false, 'FIREAC Server Tools', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'FIREAC: Server Tools')
local menu4_deletevehicles = menu4:AddButton({ icon = ''..Emoji.Car..'', label = 'Delete All Vehicles', description = 'Delete All Vehicles in Server', value = menu4_deletevehicles })
local menu4_deleteprops = menu4:AddButton({ icon = ''..Emoji.Buling..'', label = 'Delete All Props', value = deleteprops, description = 'Delete all Entities in Server' })
local menu4_deletepeds = menu4:AddButton({ icon = ''..Emoji.Peds..'', label = 'Delete All Peds', value = menu4_deletepeds, description = 'Delete all Peds in server' })
local menu4_deleteall = menu4:AddButton({ icon = ''..Emoji.RGB..'', label = 'Delete All Enitiy', value = menu4_deleteall, description = 'Delete all Entity in server' })
menu4_deletevehicles:On('select', function(item)
    TriggerServerEvent('FIREAC:DeleteEntitys', 'VEHCILE')
end)

menu4_deleteprops:On('select', function(item)
    TriggerServerEvent('FIREAC:DeleteEntitys', 'PROP')
end)

menu4_deletepeds:On('select', function(item)
    TriggerServerEvent('FIREAC:DeleteEntitys', 'PEDS')
end)

menu4_deleteall:On('select', function(item)
    TriggerServerEvent('FIREAC:DeleteEntitys', 'VEHCILE')
    Wait(1000)
    TriggerServerEvent('FIREAC:DeleteEntitys', 'PROP')
    Wait(1000)
    TriggerServerEvent('FIREAC:DeleteEntitys', 'PEDS')
end)

-- MENU 5
local menu5 = MenuV:CreateMenu(false, 'FIREAC Teleport Options', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'FIREAC: Teleport Options')
local menu5_tptowaypoint = menu5:AddButton({ icon = ''..Emoji.Abnamat..'', label = 'TP To Waypoint', description = 'TP To Waypoint' })
menu5_tptowaypoint:On('select', function(item) -- Thanks to Qalle (ESX_Marker for this :) (https://github.com/qalle-git/esx_marker)
    local _waypoint = GetFirstBlipInfoId(8)

    if DoesBlipExist(_waypoint) then
        local waypointCoords = GetBlipInfoIdCoord(_waypoint)

        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords['x'], waypointCoords['y'], height + 0.0)

            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords['x'], waypointCoords['y'], height + 0.0)

            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords['x'], waypointCoords['y'], height + 0.0)
                break
            end

            Citizen.Wait(5)
        end
    end
end)

-- MENU 6
local menu6 = MenuV:CreateMenu(false, 'FIREAC Vehicle Tools', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'FIREAC: Vehicle Tools')
local menu6_fixcar = menu6:AddButton({ icon = ''..Emoji.Fix..'', label = 'Fix Car', description = 'Fix Car' })
local menu6_godmode = menu6:AddCheckbox({ icon = ''..Emoji.GodMode..'', label = 'GodMode', description = 'GodMode', value = 'n' })
local menu6_noclip = menu6:AddCheckbox({ icon = ''..Emoji.Beard..'', label = 'NoClip (Vehicle)', description = 'Noclip with a Vehicle', value = 'n' })
local menu6_nocliprange = menu6:AddRange({ icon = ''..Emoji.Speed..'', label = 'Noclip Speed', min = 0, max = 10, value = 0, saveOnUpdate = true, description = 'Set NoClip Speed' })
local menu6_engineboost = menu6:AddRange({ icon = ''..Emoji.Engine..'', label = 'Engine Boost', min = 0, max = 10, value = 0, saveOnUpdate = true, description = 'Set Vehicle Engine Boost' })
menu6_fixcar:On('select', function(item)
    local _ped = PlayerPedId()
    local _vehiclein = GetVehiclePedIsIn(_ped)
    SetVehicleFixed(_vehiclein)
    SetVehicleDeformationFixed(_vehiclein)
    SetVehicleUndriveable(_vehiclein, false)
    SetVehicleEngineOn(_vehiclein, true, true)
end)
menu6_godmode:On('check', function(item)
    local _ped = PlayerPedId()
    local _vehiclein = GetVehiclePedIsIn(_ped)
    SetEntityInvinicible(_vehiclein, true)
end)
menu6_godmode:On('uncheck', function(item)
    local _ped = PlayerPedId()
    local _vehiclein = GetVehiclePedIsIn(_ped)
    SetEntityInvinicible(_vehiclein, false)
end)
menu6_noclip:On('check', function(item)
    isusingfuncs = true
    isnoclippingveh = true
end)
menu6_noclip:On('uncheck', function(item)
    isusingfuncs = false
    isnoclippingveh = false
    SetEntityVisible(PlayerPedId(), true)
    local _vehiclein = GetVehiclePedIsIn(PlayerPedId())
    SetEntityVisible(_vehiclein, true)
end)
menu6_nocliprange:On('change', function(item, newValue, oldValue)
    noclipveh = newValue
end)
menu6_engineboost:On('change', function(item, newValue, oldValue)
    local _veh = GetVehiclePedIsIn(PlayerPedId())
    local _boost = 1.0
    if newValue ~= 1 then
        _boost = newValue * 50.0
    end 
    SetVehicleEnginePowerMultiplier(_veh, _boost)
end)

-- MENU 7
local menu7 = MenuV:CreateMenu(false, 'FIREAC Admin Tools', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'FIREAC: TP Tools Tools')
local menu7_acinfo = menu7:AddButton({ icon = ''..Emoji.info..'', label = 'Version: 6.0', description = 'https://discord.gg/drwWFkfu6x' })
local menu7_creatorac = menu7:AddButton({ icon = ''..Emoji.info..'', label = 'FIREAC Dev: Amirreza Jaberi', description = 'https://discord.gg/drwWFkfu6x' })

-- NEW MENUS (Augusto/Mopped7)

-- Menu 8 (Skin do PED)
local menu8 = MenuV:CreateMenu(false, 'Change PED Skin', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'Change Characters skin')
local menu8_padraom = menu8:AddButton({ icon = ''..Emoji.Boy..'', label = 'MP Male', description = 'Change skin to MP Male' })
local menu8_padraof = menu8:AddButton({ icon = ''..Emoji.Girl..'', label = 'MP Female', description = 'Change skin to MP Female' })
local menu8_monkey = menu8:AddButton({ icon = ''..Emoji.Monkey..'', label = 'Monkey', description = 'Change skin to Monkey' })
local menu8_rato = menu8:AddButton({ icon = ''..Emoji.Mouse..' ', label = 'Rat', description = 'Change skin to Rat' })
local menu8_dog = menu8:AddButton({ icon = ''..Emoji.Dog..' ', label = 'Dog', description = 'Change skin to Dog' })
local menu8_cat = menu8:AddButton({ icon = ''..Emoji.Cat..' ', label = 'Cat', description = 'Change skin to Cat' })
menu8_padraom:On('select', function(item)
    local modelo = GetHashKey('mp_m_freemode_01')
    while not HasModelLoaded(modelo) do
        RequestModel(modelo)
        Citizen.Wait(10)
    end

    if HasModelLoaded(modelo) then
        SetPlayerModel(PlayerId(),modelo)
        SetModelAsNoLongerNeeded(modelo)
    end
end)

menu8_padraof:On('select', function(item)
    local modelo = GetHashKey('mp_f_freemode_01')
    while not HasModelLoaded(modelo) do
        RequestModel(modelo)
        Citizen.Wait(10)
    end

    if HasModelLoaded(modelo) then
        SetPlayerModel(PlayerId(),modelo)
        SetModelAsNoLongerNeeded(modelo)
    end
end)

menu8_monkey:On('select', function(item)
    local modelo = GetHashKey('a_c_chimp')
    while not HasModelLoaded(modelo) do
        RequestModel(modelo)
        Citizen.Wait(10)
    end

    if HasModelLoaded(modelo) then
        SetPlayerModel(PlayerId(),modelo)
        SetModelAsNoLongerNeeded(modelo)
    end
end)

menu8_rato:On('select', function(item)
    local modelo = GetHashKey('a_c_rat')
    while not HasModelLoaded(modelo) do
        RequestModel(modelo)
        Citizen.Wait(10)
    end

    if HasModelLoaded(modelo) then
        SetPlayerModel(PlayerId(),modelo)
        SetModelAsNoLongerNeeded(modelo)
    end
end)

menu8_dog:On('select', function(item)
    local modelo = GetHashKey('a_c_poodle')
    while not HasModelLoaded(modelo) do
        RequestModel(modelo)
        Citizen.Wait(10)
    end

    if HasModelLoaded(modelo) then
        SetPlayerModel(PlayerId(),modelo)
        SetModelAsNoLongerNeeded(modelo)
    end
end)

menu8_cat:On('select', function(item)
    local modelo = GetHashKey('a_c_cat_01')
    while not HasModelLoaded(modelo) do
        RequestModel(modelo)
        Citizen.Wait(10)
    end

    if HasModelLoaded(modelo) then
        SetPlayerModel(PlayerId(),modelo)
        SetModelAsNoLongerNeeded(modelo)
    end
end)


-- Menu 9

local menu9 = MenuV:CreateMenu(false, 'Vision Menu', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'Activate/Deactivate Vision Menu')
local menu9_visaonoturna = menu9:AddCheckbox({ icon = ''..Emoji.Night..'', label = 'Night Vision', description = 'Activate/Deactivate Night Vision', value = 'n' })
local menu9_visaotermica = menu9:AddCheckbox({ icon = ''..Emoji.Fire..'', label = 'Thermal Vision', description = 'Activate/deactivate Thermal Vision', value = 'n' })

menu9_visaonoturna:On('check', function(item)
    SetNightvision(1)
end)
menu9_visaonoturna:On('uncheck', function(item)
    SetNightvision(0)
end)

menu9_visaotermica:On('check', function(item)
    SetSeethrough(1)
end)
menu9_visaotermica:On('uncheck', function(item)
    SetSeethrough(0)
end)

-- PRINCIPAL MENU
local menu = MenuV:CreateMenu(false, ''..Emoji.Fire..' FIREAC Admin Menu '..Emoji.Fire..'', 'centerright', 51, 102, 255, 'size-125', 'default_native', 'menuv', 'FIREAC: Main Menu')
local menu_admintools = menu:AddButton({ icon = ''..Emoji.Fire..'', label = 'Admin Tools', value = menu2, description = 'Open Admin Tools' })
local menu_connectedplayers = menu:AddButton({ icon = ''..Emoji.Player..'', label = 'Connected Players', value = menu3, description = 'See the Player List' })
local menu_servertools = menu:AddButton({ icon = ''..Emoji.Bot..'', label = 'Server Tools', value = menu4, description = 'Open Server Tools' })
local menu_tpoptions = menu:AddButton({ icon = ''..Emoji.Abnamat..'', label = 'Teleport Options', value = menu5, description = 'Open Teleport Options' })
local menu_skin = menu:AddButton({ icon = ''..Emoji.Cloth..'', label = 'Ped Menu', value = menu8, description = 'Change your Ped/Skin' })
local menu_visaoconfig = menu:AddButton({ icon = ''..Emoji.Vision..'', label = 'Vision Menu', value = menu9, description = 'Activate/Deactivate Vision Mods' })
local menu_vehicleoptions = menu:AddButton({ icon = ''..Emoji.Vehicle..'', label = 'Vehicle Options', value = menu6, description = 'Open Vehicle Options' })
local menu_infoanticheat = menu:AddButton({ icon = ''..Emoji.info..'', label = 'Information', value = menu7, description = 'See the Anticheat Version' })


function TeleportToPlayer(SV_ID)
    TriggerServerEvent('FIREAC:TeleportToPlayer', SV_ID)
end

function DrawNotificationForPlayer(text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function updateTargetChecks()
	Citizen.CreateThread(function()
		while InSpectatorMode do
		  	Citizen.Wait(1000)
			health = GetEntityHealth(targetPed)
			maxhealth = GetEntityMaxHealth(targetPed)
			armor = GetPedArmour(targetPed)
			handleVoiceChannel(TargetSpectate)
		end
	end)
end

function FIREAC_RESETCAMERA()
	if InSpectatorMode then
		InSpectatorMode = false
		TargetSpectate  = nil
		targetPed = nil
		SetCamActive(cam, false)
		RenderScriptCams(false, false, 0, true, true)
		NetworkSetInSpectatorMode(false)
		if currentVoiceChannel then
			MumbleRemoveVoiceChannelListen(channel)
			currentVoiceChannel = nil
		end
	end
end

function FIREAC_SPECTATE(target, coords)
	if not DoesCamExist(cam) then
		cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
	end
	SetCamCoord(cam, coords.x, coords.y, coords.z)
	SetCamActive(cam, true)
	RenderScriptCams(true, false, 0, true, true)
	SetCamCoord(cam, coords.x, coords.y, coords.z)
	Wait(500)
	local player = GetPlayerFromServerId(target)
	if player == -1 then return ESX.ShowNotification('~h~~o~[FIREAC]:~s~Player Not Found !') end
	local ped = GetPlayerPed(player)
	NetworkSetInSpectatorMode(true, ped)
	InSpectatorMode = true
	TargetSpectate  = target
	FIREAC_DOSPECTATE(player, ped)
end

function FIREAC_DOSPECTATE(player, ped)
	Citizen.CreateThread(function()
		local thePlayer = player
		targetPed = GetPlayerPed(thePlayer)
		updateTargetChecks()

		while InSpectatorMode do
		  Citizen.Wait(5)
			  local coords = GetEntityCoords(targetPed)
			  if not DoesEntityExist(ped) then
				ESX.ShowNotification('~h~Player left or teleporteed!')
				FIREAC_RESETCAMERA()
			  end

			  DisableControlAction(2, 37, true) 
			  if IsControlPressed(2, 241) then
				  radius = radius + 2.0
			  end
  
			  if IsControlPressed(2, 242) then
				  radius = radius - 2.0
			  end
  
			  if radius > -1 then
				  radius = -1
			  end
  
			  local xMagnitude = GetDisabledControlNormal(0, 1);
			  local yMagnitude = GetDisabledControlNormal(0, 2);
  
			  polarAngleDeg = polarAngleDeg + xMagnitude * 10;
  
			  if polarAngleDeg >= 360 then
				  polarAngleDeg = 0
			  end
  
			  azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10;
  
			  if azimuthAngleDeg >= 360 then
				  azimuthAngleDeg = 0;
			  end
  
			  local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)
			  
			  SetCamCoord(cam,  nextCamLocation.x,  nextCamLocation.y,  nextCamLocation.z)
			  PointCamAtEntity(cam,  targetPed)
			  
			  if health and maxhealth and armor then
				  Draw({
					  'Health'..': ~g~' .. health .. '/' .. maxhealth,
					  'Armor'..': ~b~' .. armor
				  })
			  end

		end
  end)
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
		SetTextEntry('STRING')
		AddTextComponentString(theText)
		EndTextCommandDisplayText(0.3, 0.7+(i/30))
	end
end

RegisterCommand('fireacmenu', function()
    if Access then
        TriggerServerEvent('FIREAC:MenuOpened')
		menu:Open()
    end
end, false)

RegisterKeyMapping('fireacmenu', 'FIREAC Admin Menu', 'keyboard', FIREAC.AdminMenu.Key)
