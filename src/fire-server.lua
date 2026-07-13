-- FIREAC (https://github.com/AmirrezaJaberi/FIREAC)
-- Copyright 2022-2026 by Amirreza Jaberi (https://github.com/AmirrezaJaberi)
-- Licensed under the GNU Affero General Public License v3.0

local COLORS = math.random(1, 9)
local SPAWNED = {}
local SPAMLIST = {}
local TEMP_WHITELIST = {}
local PLAYER_STATE = {}
local PERMISSION_CACHE = {}
local TRUSTED_ADMINS = {}
local invalidatePermissionCache

local function cfg(name, fallback)
    if FIREAC.Detection and FIREAC.Detection[name] ~= nil then
        return FIREAC.Detection[name]
    end
    return fallback
end

local function connectionCfg(name, fallback)
    if FIREAC.Connection and FIREAC.Connection[name] ~= nil then
        return FIREAC.Connection[name]
    end
    return fallback
end

local function runtimeCfg(name, fallback)
    if FIREAC.ServerRuntime and FIREAC.ServerRuntime[name] ~= nil then
        return FIREAC.ServerRuntime[name]
    end
    return fallback
end

local function monotonicMs()
    return GetGameTimer()
end

local function playerState(src)
    src = tonumber(src)
    if not src then return nil end
    PLAYER_STATE[src] = PLAYER_STATE[src] or {
        connectedAt = monotonicMs(),
        readyAt = 0,
        graceUntil = 0,
        reportWindowAt = 0,
        reportCount = 0,
        lastReasonAt = {}
    }
    return PLAYER_STATE[src]
end

AddEventHandler('playerConnecting', function()
    playerState(source)
end)

AddEventHandler('playerDropped', function()
    local src = tonumber(source)
    PLAYER_STATE[src] = nil
    TEMP_WHITELIST[src] = nil
    PERMISSION_CACHE[src] = nil
    TRUSTED_ADMINS[src] = nil
    SPAMLIST[src] = nil
end)

local function fireacNormalizeName(name)
    return tostring(name or ""):lower():gsub("[%s,%-%_]", "")
end

local DB_COLUMN_READY = {}
local function fireacDbName(value)
    local name = tostring(value or "Unknown")
    name = name:gsub("[%c]", " "):gsub("%s+", " "):sub(1, 96)
    if name == "" then name = "Unknown" end
    return name
end

local function fireacEnsureColumn(tableName, columnName, definition)
    tableName, columnName = tostring(tableName or ""), tostring(columnName or "")
    if tableName == "" or columnName == "" then return false end
    local key = tableName .. "." .. columnName
    if DB_COLUMN_READY[key] ~= nil then return DB_COLUMN_READY[key] end

    local p = promise.new()
    MySQL.Async.fetchAll(("SHOW COLUMNS FROM `%s` LIKE @column"):format(tableName), {
        ["@column"] = columnName
    }, function(rows)
        if rows and rows[1] then
            DB_COLUMN_READY[key] = true
            p:resolve(true)
            return
        end
        MySQL.Async.execute(("ALTER TABLE `%s` ADD COLUMN `%s` %s"):format(tableName, columnName, definition), {}, function(rowsChanged)
            DB_COLUMN_READY[key] = true
            p:resolve(true)
        end)
    end)
    return Citizen.Await(p)
end

local function fireacGrantActionGrace(target, durationMs, reason)
    target = tonumber(target)
    if not target or not GetPlayerName(target) then return false end
    durationMs = math.max(5000, math.min(tonumber(durationMs) or 30000, 600000))
    FIREAC_CHANGE_TEMP_WHHITELIST(target, true, durationMs)
    TriggerClientEvent("FIREAC:clientGrace", target, durationMs)
    local st = playerState(target)
    if st then st.graceUntil = math.max(st.graceUntil or 0, monotonicMs() + durationMs) end
    return true
end

local function FIREAC_PostConnectValidation(src, playerName)
    src = tonumber(src)
    if not src or not GetPlayerName(src) then return end

    local okBan, banData = pcall(FIREAC_INBANLIST, src)
    if okBan and banData and banData[1] then
        local reason = tostring(banData[1].REASON or "Unknown")
        local banId = tostring(banData[1].BANID or "N/A")
        print(("^%sFIREAC^0: ^1Blocked banned player ^3%s^0 | Ban ID: %s"):format(COLORS, playerName or GetPlayerName(src) or src, banId))
        DropPlayer(src, ("\n[FIREAC]\nYou are banned from this server.\nReason: %s\nBan ID: #%s"):format(reason, banId))
        return
    elseif not okBan then
        print("^1[FIREAC]^0 Ban-list lookup failed during post-connect validation; player was allowed fail-open.")
    end

    if FIREAC.Connection and FIREAC.Connection.AntiBlackListName and type(Names) == "table" then
        local normalizedName = fireacNormalizeName(playerName or GetPlayerName(src))
        for _, blocked in ipairs(Names) do
            local needle = fireacNormalizeName(blocked)
            if needle ~= "" and normalizedName:find(needle, 1, true) then
                DropPlayer(src, ("\n[FIREAC]\nYour player name contains a blocked term: %s"):format(tostring(blocked)))
                return
            end
        end
    end
end

AddEventHandler('playerJoining', function()
    local src = tonumber(source)
    if not src then return end
    SetTimeout(2500, function()
        FIREAC_PostConnectValidation(src, GetPlayerName(src))
    end)
end)

CreateThread(function()
    Wait(0)
    StartAntiCheat()
end)

local ALLOWED_REPORT_REASONS = {
    ["Anti Health Hack"] = function() return FIREAC.HealthPunishment end,
    ["Anti Armor Hack"] = function() return FIREAC.ArmorPunishment end,
    ["Anti Spectate"] = function() return FIREAC.SpectatePunishment or FIREAC.SpactatePunishment end,
    ["Anti Godmode"] = function() return FIREAC.GodPunishment end,
    ["Anti Invisible"] = function() return FIREAC.InvisiblePunishment end,
    ["Anti Tiny Ped"] = function() return FIREAC.PedFlagPunishment end,
    ["Anti Ped Changer"] = function() return FIREAC.PedChangePunishment end,
    ["Anti Free Cam"] = function() return FIREAC.CamPunishment end,
    ["Anti Teleport"] = function() return FIREAC.TeleportPunishment end,
    ["Anti Noclip"] = function() return FIREAC.NoclipPunishment end,
    ["Anti Black List Weapon"] = function() return FIREAC.WeaponPunishment end,
    ["Anti Weapon Damage Changer"] = function() return FIREAC.DamagePunishment or FIREAC.WeaponPunishment end,
    ["Anti Infinite Stamina"] = function() return FIREAC.InfinitePunishment end,
    ["Anti Night Vision"] = function() return FIREAC.VisionPunishment end,
    ["Anti Thermal Vision"] = function() return FIREAC.VisionPunishment end,
    ["Anti Black List Tasks"] = function() return FIREAC.TasksPunishment end,
    ["Anti Black List Animation"] = function() return FIREAC.AnimsPunishment end,
    ["Anti Plate Changer"] = function() return FIREAC.PlatePunishment end,
    ["Anti Black List Plate"] = function() return FIREAC.PlatePunishment end,
    ["Anti Rainbow"] = function() return FIREAC.RainbowPunishment end,
    ["Anti Speed Changer"] = function() return FIREAC.SpeedPunishment end,
    ["Anti Collected Pickup"] = function() return FIREAC.PickupPunishment end,
    ["Anti Suicide"] = function() return FIREAC.SuicidePunishment end,
}

local function acceptClientReport(src, requestedAction, reason, details)
    src = tonumber(src)
    if not src or src <= 0 or not GetPlayerName(src) then return end
    if FIREAC_IS_TRUSTED and FIREAC_IS_TRUSTED(src) then return end
    if type(reason) ~= "string" or type(details) ~= "string" then return end
    if #reason > 80 or #details > 1200 then return end

    local resolver = ALLOWED_REPORT_REASONS[reason]
    if not resolver then return end

    local st = playerState(src)
    local t = monotonicMs()
    if not st or st.readyAt == 0 or t < st.graceUntil then return end

    local window = cfg("ServerReportWindowMs", 10000)
    if t - st.reportWindowAt > window then
        st.reportWindowAt = t
        st.reportCount = 0
    end
    st.reportCount = st.reportCount + 1
    if st.reportCount > cfg("ServerReportLimit", 6) then
        return
    end

    local last = st.lastReasonAt[reason] or 0
    if t - last < window then return end
    st.lastReasonAt[reason] = t

    local action = tostring(resolver() or requestedAction or "WARN"):upper()
    if action ~= "WARN" and action ~= "KICK" and action ~= "BAN" then action = "WARN" end

    if reason == "Anti Teleport" and FIREAC_ISNEARADMIN(src) then return end
    FIREAC_ACTION(src, action, reason, details)
end

RegisterNetEvent("FIREAC:clientReady", function(spawnSerial, reason)
    local src = tonumber(source)
    local st = playerState(src)
    if not st then return end

    reason = tostring(reason or "unknown"):sub(1, 48)
    local connectedFor = monotonicMs() - (st.connectedAt or monotonicMs())
    local minimumMs = tonumber(cfg("MinimumClientReadyMs", 12000)) or 12000
    if connectedFor < minimumMs then
        return
    end

    st.readyAt = monotonicMs()
    SPAWNED[src] = true
    st.graceUntil = st.readyAt + cfg("PostReadyGraceMs", cfg("SpawnGraceMs", 20000))
    st.spawnSerial = tonumber(spawnSerial) or 0
    st.readyReason = reason
end)

RegisterNetEvent("FIREAC:reportDetection", function(action, reason, details)
    acceptClientReport(source, action, reason, details)
end)

RegisterNetEvent("FIREAC:BanFromClient", function(action, reason, details)
    acceptClientReport(source, action, reason, tostring(details or "legacy report"))
end)

local function verifyInjectionReport(src, resource, info)
    src = tonumber(src)
    if not src or not FIREAC.AntiInject or type(resource) ~= "string" or type(info) ~= "string" then return end
    if FIREAC_IS_TRUSTED(src) then return end
    resource = resource:sub(1, 100)
    info = info:sub(1, 300)
    if resource ~= "" and GetResourceState(resource) == "missing" then
        FIREAC_ACTION(src, FIREAC.InjectPunishment, "Anti Inject",
            ("Unknown client resource `%s`: %s"):format(resource, info))
    end
end

RegisterNetEvent("FIREAC:BanForInject", function(_, details, resource)
    verifyInjectionReport(source, resource, tostring(details or "legacy report"))
end)

RegisterNetEvent("FIREAC:AntiInject", function(resource, info)
    verifyInjectionReport(source, resource, info)
end)

RegisterNetEvent("FIREAC:checkIsAdmin")
AddEventHandler("FIREAC:checkIsAdmin", function()
    local src = tonumber(source)
    if not src then return end
    local allowed = FIREAC.AdminMenu.Enable == true and FIREAC_GETADMINS(src)
    TriggerClientEvent("FIREAC:allowToOpen", src, allowed == true)
end)

RegisterNetEvent("FIREAC:CheckIsAdmin")
AddEventHandler("FIREAC:CheckIsAdmin", function()
    local src = tonumber(source)
    if not src then return end
    local allowed = FIREAC.AdminMenu.Enable == true and FIREAC_GETADMINS(src)
    TriggerClientEvent("FIREAC:allowToOpen", src, allowed == true)
end)

local function fireacCountPlayers()
    local count = 0
    for _, _ in ipairs(GetPlayers()) do
        count = count + 1
    end
    return count
end

local function fireacSafeListCount(fn, filter)
    if type(fn) ~= "function" then return 0 end

    local ok, list = pcall(fn)
    if not ok or type(list) ~= "table" then return 0 end
    if type(filter) ~= "function" then return #list end

    local count = 0
    for _, entity in ipairs(list) do
        local okFilter, result = pcall(filter, entity)
        if okFilter and result then count = count + 1 end
    end
    return count
end

local function fireacSendDashboardStats(src, databaseStats, recentAdmins, recentBans)
    if not src or not GetPlayerName(src) then return end
    local stats = {
        players = fireacCountPlayers(),
        vehicles = fireacSafeListCount(GetAllVehicles),
        props = fireacSafeListCount(GetAllObjects),
        peds = fireacSafeListCount(GetAllPeds, function(ped)
            return DoesEntityExist(ped) and not IsPedAPlayer(ped)
        end),
        bans = 0,
        admins = 0,
        whitelist = 0,
        unban = 0,
        recentAdmins = type(recentAdmins) == "table" and recentAdmins or {},
        recentBans = type(recentBans) == "table" and recentBans or {},
    }

    if type(databaseStats) == "table" then
        stats.bans = tonumber(databaseStats.bans) or 0
        stats.admins = tonumber(databaseStats.admins) or 0
        stats.whitelist = tonumber(databaseStats.whitelist) or 0
        stats.unban = tonumber(databaseStats.unban) or 0
    end

    TriggerClientEvent("FIREAC:updateDashboardStats", src, stats)
end

RegisterNetEvent("FIREAC:getDashboardStats")
AddEventHandler("FIREAC:getDashboardStats", function()
    local src = tonumber(source)
    if not src then return end

    if not FIREAC_GETADMINS(src) then
        FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to get FIREAC dashboard stats.")
        return
    end

    MySQL.Async.fetchAll([[
        SELECT
            (SELECT COUNT(*) FROM fireac_banlist) AS bans,
            (SELECT COUNT(*) FROM fireac_admin) AS admins,
            (SELECT COUNT(*) FROM fireac_whitelist) AS whitelist,
            (SELECT COUNT(*) FROM fireac_unban) AS unban
    ]], {}, function(rows)
        local row = rows and rows[1] or {}
        MySQL.Async.fetchAll('SELECT * FROM fireac_admin ORDER BY id DESC LIMIT 5', {}, function(adminRows)
            MySQL.Async.fetchAll('SELECT * FROM fireac_banlist ORDER BY id DESC LIMIT 5', {}, function(banRows)
                fireacSendDashboardStats(src, row, adminRows or {}, banRows or {})
            end)
        end)
    end)
end)

RegisterNetEvent("FIREAC:getAllPlayerData")
AddEventHandler("FIREAC:getAllPlayerData", function()
    local source = source

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Try For Open Admin Menu (Not Admin)")
    else
        local PlayerList = {}
        for _, value in pairs(GetPlayers()) do
            local pid = tonumber(value)
            table.insert(PlayerList, {
                name = GetPlayerName(value),
                id   = value,
                identifier = fireacPlayerLicense(pid) or "no license yet",
                isAdmin = FIREAC_GETADMINS(pid) == true,
                isWhitelist = FIREAC_WHITELIST(pid) == true,
            })
        end
        TriggerClientEvent("FIREAC:sendAllPlayerData", source, PlayerList)
    end
end)

RegisterNetEvent("FIREAC:getPlayerData")
AddEventHandler("FIREAC:getPlayerData", function(playerId)
    local source = source
    playerId = tonumber(playerId)

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Try for get a player data")
    else
        if GetPlayerName(playerId) then
            local data = {
                id     = playerId,
                name   = GetPlayerName(playerId),
                health = GetEntityHealth(GetPlayerPed(playerId)),
                armour = GetPedArmour(GetPlayerPed(playerId)),
                identifier = fireacPlayerLicense(playerId) or "no license yet",
                isAdmin = FIREAC_GETADMINS(playerId) == true,
                isWhitelist = FIREAC_WHITELIST(playerId) == true,
            }
            TriggerClientEvent("FIREAC:openPlayerData", source, data)
        end
    end
end)

RegisterNetEvent("FIREAC:addPlayerAsAdmin")
AddEventHandler("FIREAC:addPlayerAsAdmin", function(playerId)
    local source = source
    playerId = tonumber(playerId)

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Try to set player as admin")
    else
        if GetPlayerName(playerId) then
            if not FIREAC_GETADMINS(playerId) then
                local added = FIREAC:ADDADMIN(playerId)
                if added then
                    TRUSTED_ADMINS[playerId] = true
                    invalidatePermissionCache(playerId)
                    FIREAC_CHANGE_TEMP_WHHITELIST(playerId, true, 120000)
                    TriggerClientEvent("FIREAC:clientGrace", playerId, 120000)
                    TriggerClientEvent("FIREAC:allowToOpen", playerId, true)
                end
            end
        end
    end
end)

RegisterNetEvent("FIREAC:addPlayerAsWhiteList")
AddEventHandler("FIREAC:addPlayerAsWhiteList", function(playerId)
    local source = source
    playerId = tonumber(playerId)

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Try to set player as admin")
    else
        if GetPlayerName(playerId) then
            if not FIREAC_WHITELIST(playerId) then
                local added = FIREAC:ADDWHITELIST(playerId)
                if added then
                    invalidatePermissionCache(playerId)
                    FIREAC_CHANGE_TEMP_WHHITELIST(playerId, true, 120000)
                    TriggerClientEvent("FIREAC:clientGrace", playerId, 120000)
                end
            end
        end
    end
end)

RegisterNetEvent("FIREAC:addPlayerUnbanAccess")
AddEventHandler("FIREAC:addPlayerUnbanAccess", function(playerId)
    local source = source
    playerId = tonumber(playerId)

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Try to add player unban access")
    else
        if GetPlayerName(playerId) then
            if not FIREAC_UNBANACCESS(playerId) then
                FIREAC:ADDUNBAN(playerId)
                invalidatePermissionCache(playerId)
            end
        end
    end
end)

function fireacPlayerLicense(src)
    src = tonumber(src)
    if not src then return nil end
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if type(identifier) == "string" and identifier:sub(1, 8) == "license:" then
            return identifier
        end
    end
    return nil
end

RegisterNetEvent("FIREAC:getAccessOnlinePlayers")
AddEventHandler("FIREAC:getAccessOnlinePlayers", function(scope)
    local src = tonumber(source)
    scope = tostring(scope or "")
    if not src or not FIREAC_GETADMINS(src) then
        if src then
            FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
                "Attempt to get online access picker data")
        end
        return
    end

    if scope ~= "admins" and scope ~= "whitelist" then return end

    local players = {}
    for _, value in ipairs(GetPlayers()) do
        local playerId = tonumber(value)
        if playerId and GetPlayerName(playerId) then
            table.insert(players, {
                id = playerId,
                name = GetPlayerName(playerId),
                identifier = fireacPlayerLicense(playerId) or "no license yet",
                isAdmin = FIREAC_GETADMINS(playerId) == true,
                isWhitelist = FIREAC_WHITELIST(playerId) == true
            })
        end
    end

    TriggerClientEvent("FIREAC:updateAccessOnlinePlayers", src, scope, players)
end)

local function spawnAdminVehicle(requester, data)
    local src = tonumber(requester)
    if not src or not FIREAC_GETADMINS(src) then
        if src then
            FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Spawn Vehicle",
                "Unauthorized admin vehicle spawn event")
        end
        return false
    end

    if type(data) ~= "table" or type(data.vehicleName) ~= "string" then return false end
    local vehicleName = data.vehicleName:lower():match("^[%w_%-]+$")
    if not vehicleName or #vehicleName > 64 then return false end

    local target = tonumber(data.targetId) or src
    if not target or not GetPlayerName(target) then return false end
    local ped = GetPlayerPed(target)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return false end

    fireacGrantActionGrace(src, 45000, "adminVehicleSpawn")
    fireacGrantActionGrace(target, 45000, "adminVehicleSpawn")

    local model = GetHashKey(vehicleName)
    if model == 0 then return false end
    local pos = GetEntityCoords(ped)
    local vehicle = CreateVehicle(model, pos.x, pos.y, pos.z, GetEntityHeading(ped), true, false)
    if not vehicle or vehicle == 0 then return false end

    local timeout = GetGameTimer() + 5000
    while not DoesEntityExist(vehicle) and GetGameTimer() < timeout do Wait(0) end
    if not DoesEntityExist(vehicle) then return false end

    SetPedIntoVehicle(ped, vehicle, -1)
    return true
end

RegisterNetEvent("FIREAC:spawnVehicle")
AddEventHandler("FIREAC:spawnVehicle", function(data)
    spawnAdminVehicle(source, data)
end)

local FIREAC_LIST_TABLES = {
    admins = {
        tableName = "fireac_admin",
        orderBy = "id",
        columns = "`id`, `identifier`, `player_name`",
        searchable = {"identifier", "player_name", "id"},
    },
    unban = {
        tableName = "fireac_unban",
        orderBy = "id",
        columns = "`id`, `identifier`, `player_name`",
        searchable = {"identifier", "player_name", "id"},
    },
    whitelist = {
        tableName = "fireac_whitelist",
        orderBy = "id",
        columns = "`id`, `identifier`, `player_name`",
        searchable = {"identifier", "player_name", "id"},
    },
    bans = {
        tableName = "fireac_banlist",
        orderBy = "id",
        columns = "*",
        searchable = {"PLAYER_NAME", "LICENSE", "DISCORD", "STEAM", "BANID", "REASON", "IP"},
    }
}

local function fireacListRequest(data)
    data = type(data) == "table" and data or {}
    local page = math.max(1, tonumber(data.page) or 1)
    local pageSize = math.max(5, math.min(100, tonumber(data.pageSize) or 25))
    local search = tostring(data.search or ""):gsub("[%c]", " "):sub(1, 96)
    return page, pageSize, search
end

local function fireacFetchPagedList(scope, request, cb)
    local cfgList = FIREAC_LIST_TABLES[scope]
    if not cfgList then cb({}, { page = 1, pageSize = 25, total = 0, search = "" }) return end

    if scope == "admins" or scope == "unban" or scope == "whitelist" then
        fireacEnsureColumn(cfgList.tableName, "player_name", "varchar(128) NULL DEFAULT NULL AFTER `identifier`")
    elseif scope == "bans" then
        fireacEnsureColumn(cfgList.tableName, "PLAYER_NAME", "varchar(128) NULL DEFAULT NULL AFTER `id`")
    end

    local page, pageSize, search = fireacListRequest(request)
    local offset = (page - 1) * pageSize
    local params = { ["@limit"] = pageSize, ["@offset"] = offset }
    local where = ""

    if search ~= "" then
        local pieces = {}
        for index, column in ipairs(cfgList.searchable or {}) do
            local key = "@q" .. tostring(index)
            params[key] = "%" .. search .. "%"
            pieces[#pieces + 1] = ("CAST(`%s` AS CHAR) LIKE %s"):format(column, key)
        end
        if #pieces > 0 then
            where = " WHERE " .. table.concat(pieces, " OR ")
        end
    end

    local countSql = ("SELECT COUNT(*) AS total FROM `%s`%s"):format(cfgList.tableName, where)
    MySQL.Async.fetchAll(countSql, params, function(countRows)
        local total = tonumber(countRows and countRows[1] and countRows[1].total) or 0
        local maxPage = math.max(1, math.ceil(total / pageSize))
        if page > maxPage then
            page = maxPage
            offset = (page - 1) * pageSize
            params["@offset"] = offset
        end

        local sql = ("SELECT %s FROM `%s`%s ORDER BY `%s` DESC LIMIT %d OFFSET %d"):format(
            cfgList.columns, cfgList.tableName, where, cfgList.orderBy, pageSize, offset
        )

        MySQL.Async.fetchAll(sql, params, function(rows)
            cb(rows or {}, {
                page = page,
                pageSize = pageSize,
                total = total,
                search = search
            })
        end)
    end)
end

RegisterNetEvent('FIREAC:getAdminListData')
AddEventHandler('FIREAC:getAdminListData', function(request)
    local source = source
    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to get admins data by admin menu event.")
        return
    end

    fireacFetchPagedList("admins", request, function(rows, meta)
        TriggerClientEvent("FIREAC:updateAdminData", source, rows, meta)
    end)
end)

RegisterNetEvent('FIREAC:removeSelectedAdmin')
AddEventHandler('FIREAC:removeSelectedAdmin', function(id)
    local source = source

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to remove admins data by admin menu event.")
    else
        MySQL.Async.execute('DELETE FROM fireac_admin WHERE id=@id', {
            ['@id'] = tonumber(id) or -1
        }, function()
            TRUSTED_ADMINS = {}
            invalidatePermissionCache()
        end)
    end
end)

RegisterNetEvent('FIREAC:getUnbanAccessData')
AddEventHandler('FIREAC:getUnbanAccessData', function(request)
    local source = source
    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to get unban data by admin menu event.")
        return
    end

    fireacFetchPagedList("unban", request, function(rows, meta)
        TriggerClientEvent("FIREAC:updateUnbanAccess", source, rows, meta)
    end)
end)

RegisterNetEvent('FIREAC:removeUnbanAccess')
AddEventHandler('FIREAC:removeUnbanAccess', function(id)
    local source = source

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to remove player from unban access list.")
    else
        MySQL.Async.execute('DELETE FROM fireac_unban WHERE id=@id', {
            ['@id'] = tonumber(id) or -1
        }, function() invalidatePermissionCache() end)
    end
end)

RegisterNetEvent('FIREAC:removeWhitelistUser')
AddEventHandler('FIREAC:removeWhitelistUser', function(id)
    local source = source

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to remove user from whitelist by admin menu event.")
    else
        MySQL.Async.execute('DELETE FROM fireac_whitelist WHERE id=@id', {
            ['@id'] = tonumber(id) or -1
        }, function() invalidatePermissionCache() end)
    end
end)

RegisterNetEvent('FIREAC:getWhitelistData')
AddEventHandler('FIREAC:getWhitelistData', function(request)
    local source = source
    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to get whitelist data by admin menu event.")
        return
    end

    fireacFetchPagedList("whitelist", request, function(rows, meta)
        TriggerClientEvent("FIREAC:updateWhiteList", source, rows, meta)
    end)
end)

RegisterNetEvent('FIREAC:getBanListData')
AddEventHandler('FIREAC:getBanListData', function(request)
    local source = source
    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to get banlist data by admin menu event.")
        return
    end

    fireacFetchPagedList("bans", request, function(rows, meta)
        TriggerClientEvent("FIREAC:updateBanListData", source, rows, meta)
    end)
end)

RegisterNetEvent('FIREAC:unbanSelectedPlayer')
AddEventHandler('FIREAC:unbanSelectedPlayer', function(banID)
    local source = source

    if not FIREAC_GETADMINS(source) then
        FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Attempt to remove player from banlist by admin menu event.")
    else
        MySQL.Async.execute('DELETE FROM fireac_banlist WHERE BANID=@banid', {
            ['@banid'] = tonumber(banID) or -1
        })
    end
end)

RegisterNetEvent("FIREAC:deleteEntitys")
AddEventHandler("FIREAC:deleteEntitys", function(entityType)
    local source = source

    if entityType ~= nil then
        if FIREAC_GETADMINS(source) then
            if entityType == "vehicles" then
                for index, vehicles in ipairs(GetAllVehicles()) do
                    if DoesEntityExist(vehicles) then
                        DeleteEntity(vehicles)
                    end
                end
            elseif entityType == "peds" then
                for _, ped in ipairs(GetAllPeds()) do
                    if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                        DeleteEntity(ped)
                    end
                end
            elseif entityType == "props" then
                for index, objects in ipairs(GetAllObjects()) do
                    if DoesEntityExist(objects) then
                        DeleteEntity(objects)
                    end
                end
            end
        else
            FIREAC_ACTION(source, FIREAC.AdminMenu.MenuPunishment, "Anti Delete Entity", "Try For Delete Entitys")
        end
    end
end)

RegisterNetEvent("FIREAC:TeleportToPlayer", function(targetId)
    local src = tonumber(source)
    local target = tonumber(targetId)
    if not src or not target or not GetPlayerName(target) then return end
    if not FIREAC_GETADMINS(src) then
        FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Teleport", "Unauthorized admin teleport event")
        return
    end
    local sourcePed, targetPed = GetPlayerPed(src), GetPlayerPed(target)
    if sourcePed == 0 or targetPed == 0 then return end
    fireacGrantActionGrace(src, 90000, "adminGoto")
    fireacGrantActionGrace(target, 90000, "adminGotoTargetNear")
    local coords = GetEntityCoords(targetPed)
    SetEntityCoords(sourcePed, coords.x, coords.y, coords.z, false, false, false, false)
end)

RegisterNetEvent("FIREAC:BringPlayerToAdmin", function(targetId)
    local src = tonumber(source)
    local target = tonumber(targetId)
    if not src or not target or not GetPlayerName(target) or target == src then return end
    if not FIREAC_GETADMINS(src) then
        FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Teleport", "Unauthorized admin bring event")
        return
    end
    local sourcePed, targetPed = GetPlayerPed(src), GetPlayerPed(target)
    if sourcePed == 0 or targetPed == 0 then return end
    fireacGrantActionGrace(src, 90000, "adminBring")
    fireacGrantActionGrace(target, 120000, "adminBringTarget")
    local coords = GetEntityCoords(sourcePed)
    SetEntityCoords(targetPed, coords.x + 1.0, coords.y + 1.0, coords.z, false, false, false, false)
end)

RegisterNetEvent("FIREAC:KickPlayerByAdmin", function(targetId, reason)
    local src = tonumber(source)
    local target = tonumber(targetId)
    if not src or not target or not GetPlayerName(target) or target == src then return end
    if not FIREAC_GETADMINS(src) then
        FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Kick Players", "Unauthorized admin kick event")
        return
    end
    reason = tostring(reason or "Kicked by admin menu"):gsub("[%c]", " "):sub(1, 160)
    DropPlayer(target, ("\n[FIREAC]\nYou have been kicked by an administrator.\nReason: %s"):format(reason))
end)

RegisterNetEvent("FIREAC:GiveVehicleToPlayer", function(vehicleName, targetId)
    spawnAdminVehicle(source, { vehicleName = vehicleName, targetId = tonumber(targetId) })
end)

RegisterNetEvent("FIREAC:GetScreenShot", function(playerId)
    local src, target = tonumber(source), tonumber(playerId)
    if not src or not target or not GetPlayerName(target) then return end
    if not FIREAC_GETADMINS(src) then
        FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Get ScreenShot", "Unauthorized screenshot request")
        return
    end
    if GetResourceState("discord-screenshot") ~= "started" then return end
    local webhook = FIREAC.Webhooks and FIREAC.Webhooks.ScreenShot or ""
    if type(webhook) ~= "string" or not webhook:match("^https?://") then return end
    FIREAC_SCREENSHOT(target, "By Admin Menu", "Requested by " .. (GetPlayerName(src) or tostring(src)), "WARN")
end)

RegisterNetEvent("FIREAC:banPlayerByAdmin", function(targetId, reason)
    local src, target = tonumber(source), tonumber(targetId)
    if not src or not target or not GetPlayerName(target) then return end
    if not FIREAC_GETADMINS(src) then
        FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Ban Players", "Unauthorized admin ban event")
        return
    end
    if target == src then return end

    local adminName = GetPlayerName(src) or ("ID " .. tostring(src))
    FIREAC_BAN_PLAYER(target, reason or "Banned by FIREAC admin menu", "Admin " .. adminName .. " (" .. tostring(src) .. ")")
end)

RegisterNetEvent("FIREAC:requestSpectate", function(targetId)
    local src, target = tonumber(source), tonumber(targetId)
    if not src or not target or not GetPlayerName(target) or target == src then return end
    if not FIREAC_GETADMINS(src) then
        FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Spectate Players", "Unauthorized spectate event")
        return
    end
    local targetPed = GetPlayerPed(target)
    if not targetPed or targetPed == 0 or not DoesEntityExist(targetPed) then return end
    fireacGrantActionGrace(src, 90000, "adminSpectate")
    TriggerClientEvent("FIREAC:spectatePlayer", src, target, GetEntityCoords(targetPed))
end)

RegisterNetEvent("FIREAC:CheckJumping", function()
    local src = tonumber(source)
    if not src or not GetPlayerName(src) then return end
    local st = playerState(src)
    if not st or st.readyAt == 0 or monotonicMs() < st.graceUntil then return end
    if FIREAC_IS_TRUSTED(src) then return end
    if IsPlayerUsingSuperJump(src) then
        FIREAC_ACTION(src, FIREAC.JumpPunishment, "Anti Superjump", "Server native confirmed super jump")
    end
end)

RegisterNetEvent("FIREAC:ScreenShotFromClient", function()
    return
end)

AddEventHandler("playerDropped", function(reason)
    local src = tonumber(source)
    local name = GetPlayerName(src) or ("ID " .. tostring(src))
    reason = tostring(reason or "Unknown")
    print(("^%s[FIREAC]^0 ^1Player ^3%s ^1disconnected | ^0%s"):format(COLORS, name, reason))
    if GetPlayerName(src) then
        FIREAC_SENDLOG(src, FIREAC.Webhooks and FIREAC.Webhooks.Disconnect or "", "DISCONNECT", reason)
    end
end)

AddEventHandler("giveWeaponEvent", function(SRC, DATA)
    if FIREAC.AntiAddWeapon then
        if tonumber(SRC) ~= nil and GetPlayerName(SRC) ~= nil then
            if not FIREAC_IS_TRUSTED(SRC) then
                CancelEvent()
                FIREAC_ACTION(SRC, FIREAC.WeaponPunishment, "Anti Add Weapon", "Try for add weapon for player")
            end
        else
            FIREAC_ERROR(FIREAC.ServerConfig.Name, "giveWeaponEvent : SRC (Not Found)")
        end
    end
end)

AddEventHandler("RemoveWeaponEvent", function(SRC, DATA)
    if FIREAC.AntiRemoveWeapon then
        if tonumber(SRC) ~= nil and GetPlayerName(SRC) ~= nil then
            if not FIREAC_IS_TRUSTED(SRC) then
                CancelEvent()
                FIREAC_ACTION(SRC, FIREAC.WeaponPunishment, "Anti Remove Weapon", "Try for remove weapon for player")
            end
        else
            FIREAC_ERROR(FIREAC.ServerConfig.Name, "giveWeaponEvent : SRC (Not Found)")
        end
    end
end)

AddEventHandler("RemoveAllWeaponsEvent", function(SRC, DATA)
    if FIREAC.AntiRemoveWeapon then
        if tonumber(SRC) ~= nil and GetPlayerName(SRC) ~= nil then
            if not FIREAC_IS_TRUSTED(SRC) then
                CancelEvent()
                FIREAC_ACTION(SRC, FIREAC.WeaponPunishment, "Anti Remove All Weapon",
                    "Try for remove all weapon for player")
            end
        else
            FIREAC_ERROR(FIREAC.ServerConfig.Name, "giveWeaponEvent : SRC (Not Found)")
        end
    end
end)

RegisterNetEvent("FIREAC:AddToSpawnList", function()
    local src = tonumber(source)
    local st = playerState(src)
    if not st or st.readyAt == 0 then return end
    SPAWNED[src] = true
    st.graceUntil = math.max(st.graceUntil, monotonicMs() + cfg("RespawnGraceMs", 10000))
end)

local EVENTS = {}
if FIREAC.AntiSpamTrigger then
    for i = 1, #SpamCheck do
        local eventName = SpamCheck[i].EVENT
        local maxCount = tonumber(SpamCheck[i].MAX_TIME) or 10
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, function()
            local src = tonumber(source)
            if not src or src <= 0 then return end
            local now = os.time()
            EVENTS[src] = EVENTS[src] or {}
            local state = EVENTS[src][eventName]
            if not state or now - state.startedAt >= 10 then
                state = { count = 0, startedAt = now }
                EVENTS[src][eventName] = state
            end
            state.count = state.count + 1
            if state.count > maxCount then
                FIREAC_ACTION(src, FIREAC.TriggerPunishment, "Anti Spam Trigger",
                    ("Event `%s` fired %s times within 10 seconds"):format(eventName, state.count))
                CancelEvent()
            end
        end)
    end
end

local SERVER_CMDS = {}
if type(Commands) == "table" then
    for _, blockedCommand in ipairs(Commands) do
        local commandName = tostring(blockedCommand)
        if commandName ~= "" then
            RegisterCommand(commandName, function(src)
                src = tonumber(src)
                if FIREAC.AntiBlackListCommands and src and src > 0 then
                    FIREAC_ACTION(src, FIREAC.CMDPunishment, "Anti Black List Commands",
                        "Attempted blocked command: " .. commandName)
                end
            end, false)
        end
    end
end

local MESSAGE = {}
AddEventHandler("chatMessage", function(src, _, word)
    src = tonumber(src)
    if not src or src <= 0 or not GetPlayerName(src) then return end
    if FIREAC_IS_TRUSTED(src) then return end

    local text = tostring(word or "")
    local lower = text:lower()
    if FIREAC.AntiBlackListWord and type(Words) == "table" then
        for _, blocked in ipairs(Words) do
            local needle = tostring(blocked):lower()
            if needle ~= "" and lower:find(needle, 1, true) then
                FIREAC_ACTION(src, FIREAC.WordPunishment, "Anti Bad Word", "Blocked chat term detected")
                CancelEvent()
                return
            end
        end
    end

    if not FIREAC.AntiSpamChat then return end
    local now = os.time()
    local state = MESSAGE[src]
    if not state or now - state.startedAt >= (tonumber(FIREAC.CoolDownSec) or 3) then
        state = { count = 0, startedAt = now, acted = false }
        MESSAGE[src] = state
    end
    state.count = state.count + 1
    local maximum = tonumber(FIREAC.MaxMessage) or 10
    if state.count >= maximum and not state.acted then
        state.acted = true
        CancelEvent()
        FIREAC_ACTION(src, FIREAC.ChatPunishment, "Anti Spam Chat",
            ("Sent %s messages in %s seconds"):format(state.count, tonumber(FIREAC.CoolDownSec) or 3))
    end
end)

if FIREAC.AntiBlackListTrigger and type(Events) == "table" then
    for _, blockedEvent in ipairs(Events) do
        local eventName = tostring(blockedEvent)
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, function()
            local src = tonumber(source)
            if not src or FIREAC_IS_TRUSTED(src) then return end
            CancelEvent()
            FIREAC_ACTION(src, FIREAC.TriggerPunishment, "Anti Black List Trigger",
                "Attempted blocked event: " .. eventName)
        end)
    end
end

AddEventHandler("db:updateUser", function(data)
    local src = tonumber(source)
    if not FIREAC.AntiChangePerm or not src or FIREAC_IS_TRUSTED(src) then return end
    if type(data) ~= "table" or not data.playerName or not data.dateofbirth then
        CancelEvent()
        FIREAC_ACTION(src, FIREAC.PermPunishment, "Anti Change Perm", "Malformed db:updateUser payload")
    end
end)

local EXPLOSION = {}
AddEventHandler("explosionEvent", function(src, data)
    src = tonumber(src)
    if not src or src <= 0 or type(data) ~= "table" then
        CancelEvent()
        return
    end
    if FIREAC_IS_TRUSTED(src) then return end

    local definition = type(Explosion) == "table" and Explosion[tonumber(data.explosionType)] or nil
    if definition then
        local name = tostring(definition.NAME or data.explosionType or "Unknown")
        if definition.Log then
            FIREAC_SENDLOG(src, FIREAC.Webhooks and FIREAC.Webhooks.Exoplosion or "", "EXPLOSION", name)
        end
        local punishment = type(definition.Punishment) == "string" and definition.Punishment:upper() or nil
        if punishment == "WARN" or punishment == "KICK" or punishment == "BAN" then
            CancelEvent()
            FIREAC_ACTION(src, punishment, "Anti Explosion", "Blocked explosion type: " .. name)
            return
        end
    end

    if not FIREAC.AntiExplosionSpam then return end
    local key = GetPlayerToken(src, 0) or tostring(src)
    local now = os.time()
    local state = EXPLOSION[key]
    if not state or now - state.startedAt >= 10 then
        state = { count = 0, startedAt = now, acted = false }
        EXPLOSION[key] = state
    end
    state.count = state.count + 1
    if state.count >= (tonumber(FIREAC.MaxExplosion) or 10) and not state.acted then
        state.acted = true
        CancelEvent()
        FIREAC_ACTION(src, FIREAC.ExplosionSpamPunishment, "Anti Spam Explosion",
            ("Created %s explosions within 10 seconds"):format(state.count))
    end
end)

if GetResourceState("interact-sound") == "started" then
    local blockedSounds = {
        ["10000:handcuff"] = true, ["1000:Cuff"] = true, ["103232:lock"] = true,
        ["10:szajbusek"] = true, ["5:alarm"] = true, ["13232:pasysound"] = true,
        ["5000:demo"] = true,
    }
    AddEventHandler("InteractSound_SV:PlayWithinDistance", function(maxDistance, soundFile)
        local src = tonumber(source)
        if not FIREAC.AntiPlaySound or not src or FIREAC_IS_TRUSTED(src) then return end
        local key = tostring(tonumber(maxDistance) or maxDistance) .. ":" .. tostring(soundFile)
        if blockedSounds[key] then
            CancelEvent()
            FIREAC_ACTION(src, FIREAC.SoundPunishment, "Anti Play Sound", "Blocked sound payload: " .. key)
        end
    end)
end

local TAZE, FREEZE = {}, {}
AddEventHandler("weaponDamageEvent", function(src, data)
    src = tonumber(src)
    if not FIREAC.AntiTazePlayers or not src or type(data) ~= "table" or data.weaponType ~= 911657153 then return end
    if FIREAC_IS_TRUSTED(src) then return end
    local key = GetPlayerToken(src, 0) or tostring(src)
    local now = os.time()
    local state = TAZE[key]
    if not state or now - state.startedAt >= 10 then
        state = { count = 0, startedAt = now, acted = false }
        TAZE[key] = state
    end
    state.count = state.count + 1
    if state.count >= (tonumber(FIREAC.MaxTazeSpam) or 8) and not state.acted then
        state.acted = true
        CancelEvent()
        FIREAC_ACTION(src, FIREAC.TazePunishment, "Anti Spam Tazer",
            ("Tazer damage repeated %s times within 10 seconds"):format(state.count))
    end
end)

AddEventHandler("clearPedTasksEvent", function(src)
    src = tonumber(src)
    if not FIREAC.AntiClearPedTasks or not src then return end
    if FIREAC_IS_TRUSTED(src) then return end
    local key = GetPlayerToken(src, 0) or tostring(src)
    local now = os.time()
    local state = FREEZE[key]
    if not state or now - state.startedAt >= 10 then
        state = { count = 0, startedAt = now, acted = false }
        FREEZE[key] = state
    end
    state.count = state.count + 1
    if state.count >= (tonumber(FIREAC.MaxClearPedTasks) or 8) and not state.acted then
        state.acted = true
        CancelEvent()
        FIREAC_ACTION(src, FIREAC.CPTPunishment, "Anti Clear Ped Tasks",
            ("clearPedTasksEvent repeated %s times within 10 seconds"):format(state.count))
    end
end)

RegisterNetEvent("esx_ambulancejob:syncDeadBody")
AddEventHandler("esx_ambulancejob:syncDeadBody", function(ped, target)
    local src = tonumber(source)
    if not FIREAC.AntiBringAll or not src or FIREAC_IS_TRUSTED(src) then return end
    local targetId = tonumber(target)
    if targetId == -1 or (targetId and targetId ~= src and not GetPlayerName(targetId)) then
        CancelEvent()
        FIREAC_ACTION(src, FIREAC.BringAllPunishment, "Anti Bring All Players", "Invalid ambulance sync target")
    end
end)

AddEventHandler("onResourceStarting", function(RES)
    FIREAC_REFRESHCMD()
end)

AddEventHandler("onResourceStop", function(RES)
    FIREAC_REFRESHCMD()
end)

local function fireacConnectionConfig(name, fallback)
    if FIREAC and FIREAC.Connection and FIREAC.Connection[name] ~= nil then
        return FIREAC.Connection[name]
    end
    return fallback
end

local function fireacDeferralMode()
    local mode = tostring(fireacConnectionConfig("DeferralMode", "legacy") or "legacy"):lower()
    if mode == "legacy" then mode = "update" end
    if mode ~= "card" and mode ~= "update" and mode ~= "silent" then
        mode = "update"
    end
    if mode == "card" and not fireacConnectionConfig("AdaptiveCard", false) then
        mode = "update"
    end
    return mode
end

local function fireacConnectionUiEnabled()
    return fireacConnectionConfig("ShowConnectUI", true) ~= false
end

local function fireacProblemOnlyMode()
    return fireacConnectionConfig("ProblemOnlyMode", false) == true
end

local function fireacShouldShowConnectionStep(isProblem)
    if fireacConnectionUiEnabled() then
        return true
    end
    return isProblem == true and fireacConnectionConfig("ShowProblemCard", true) == true
end

local function fireacDeferralWait(multiplier)
    local ms = tonumber(fireacConnectionConfig("DeferralStepMs", 150)) or 150
    if ms < 0 then ms = 0 end
    if ms > 1000 then ms = 1000 end
    Wait(math.floor(ms * (tonumber(multiplier) or 1)))
end

local function fireacText(value, fallback, maxLen)
    local out = tostring(value or fallback or "")
    out = out:gsub("[%c]", "")
    maxLen = tonumber(maxLen) or 180
    if #out > maxLen then
        out = out:sub(1, maxLen - 3) .. "..."
    end
    return out
end

local function fireacDeferralUpdate(deferrals, message)
    if fireacDeferralMode() == "silent" then
        fireacDeferralWait()
        return true
    end
    if not deferrals or not deferrals.update then return false end
    local ok = pcall(function()
        deferrals.update(fireacText(message, "FIREAC security validation is running...", 240))
    end)
    fireacDeferralWait()
    return ok
end

local function fireacVisualDelay(multiplier)
    local ms = tonumber(fireacConnectionConfig("VisualStepMs", 420)) or 420
    if ms < 0 then ms = 0 end
    if ms > 1500 then ms = 1500 end
    Wait(math.floor(ms * (tonumber(multiplier) or 1)))
end

local function fireacProgress(step, total)
    step = tonumber(step) or 1
    total = tonumber(total) or 4
    if step < 1 then step = 1 end
    if step > total then step = total end
    local slots = 10
    local filled = math.floor((step / total) * slots + 0.5)
    if filled < 1 then filled = 1 end
    if filled > slots then filled = slots end
    return "[" .. string.rep("#", filled) .. string.rep("-", slots - filled) .. "]"
end

local function fireacConnectBrand()
    return fireacText(fireacConnectionConfig("CardTitle", "FIREAC SECURITY"), "FIREAC SECURITY", 32):upper()
end

local function fireacStatus(deferrals, step, total, title, detail, delayMultiplier)
    if not deferrals or not deferrals.update then return false end
    local brand = fireacConnectBrand()
    local msg = string.format("[%s] %s %s", brand, fireacProgress(step, total), fireacText(title, "Checking connection", 80))
    if detail and tostring(detail) ~= "" then
        msg = msg .. " | " .. fireacText(detail, "", 80)
    end
    local ok = pcall(function()
        deferrals.update(fireacText(msg, "[FIREAC] Checking connection...", 220))
    end)
    fireacVisualDelay(delayMultiplier or 1)
    return ok
end

local function fireacAdaptivePercent(step, total)
    step = tonumber(step) or 1
    total = tonumber(total) or 4
    if step < 1 then step = 1 end
    if step > total then step = total end
    local value = math.floor((step / total) * 100 + 0.5)
    if value < 0 then value = 0 end
    if value > 100 then value = 100 end
    return value
end

local FIREAC_CONNECT_STEP_LABELS = {
    [1] = "Gateway initialization",
    [2] = "Identity verification",
    [3] = "Security validation",
    [4] = "Connection result"
}

local function fireacBuildConnectCard(step, total, title, detail, accent)
    local brand = fireacConnectBrand()
    local percent = fireacAdaptivePercent(step, total)
    local safeTitle = fireacText(title, "Checking connection", 70)
    local safeDetail = fireacText(detail, "Please wait", 120)
    local color = fireacText(accent, "Accent", 16)

    local body = {
        {
            type = "Container",
            style = "emphasis",
            items = {
                {
                    type = "TextBlock",
                    text = brand,
                    weight = "Bolder",
                    size = "Large",
                    color = "Attention",
                    horizontalAlignment = "Center",
                    wrap = true
                },
                {
                    type = "TextBlock",
                    text = "Protected connection screening",
                    isSubtle = true,
                    spacing = "None",
                    horizontalAlignment = "Center",
                    wrap = true
                }
            }
        },
        {
            type = "TextBlock",
            text = safeTitle,
            weight = "Bolder",
            size = "Medium",
            color = color,
            horizontalAlignment = "Center",
            wrap = true,
            spacing = "Medium"
        },
        {
            type = "TextBlock",
            text = safeDetail,
            isSubtle = true,
            horizontalAlignment = "Center",
            wrap = true,
            spacing = "Small"
        },
        {
            type = "TextBlock",
            text = "Progress " .. tostring(percent) .. "%  " .. fireacProgress(step, total),
            weight = "Bolder",
            horizontalAlignment = "Center",
            wrap = true,
            spacing = "Medium"
        },
        {
            type = "TextBlock",
            text = "Security pipeline",
            weight = "Bolder",
            color = "Accent",
            spacing = "Medium",
            wrap = true
        }
    }

    for index = 1, total do
        local prefix = index < step and "DONE" or (index == step and "LIVE" or "WAIT")
        local rowColor = index < step and "Good" or (index == step and color or "Default")
        body[#body + 1] = {
            type = "TextBlock",
            text = string.format("[%s] %s", prefix, fireacText(FIREAC_CONNECT_STEP_LABELS[index] or ("Step " .. tostring(index)), "Step", 48)),
            color = rowColor,
            wrap = true,
            spacing = index == 1 and "Small" or "None"
        }
    end

    body[#body + 1] = {
        type = "TextBlock",
        text = "Please keep this screen open while the connection is being validated.",
        isSubtle = true,
        wrap = true,
        spacing = "Medium"
    }

    return {
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        type = "AdaptiveCard",
        version = "1.0",
        body = body
    }
end

local function fireacPresentCard(deferrals, step, total, title, detail, accent)
    if fireacDeferralMode() ~= "card" then
        return fireacStatus(deferrals, step, total, title, detail, 1)
    end
    if not deferrals or not deferrals.presentCard then
        return fireacStatus(deferrals, step, total, title, detail, 1)
    end

    fireacDeferralWait()

    local card = fireacBuildConnectCard(step, total, title, detail, accent)
    local encoded = nil
    local okJson = pcall(function()
        encoded = json.encode(card)
    end)
    if not okJson or not encoded or encoded == "" then
        return fireacStatus(deferrals, step, total, title, detail, 1)
    end

    local ok = pcall(function()
        deferrals.presentCard(encoded)
    end)

    fireacDeferralWait()
    if not ok then
        print("^3[FIREAC]^0 presentCard failed at Lua level; falling back to deferrals.update.")
        return fireacStatus(deferrals, step, total, title, detail, 1)
    end

    local hold = tonumber(fireacConnectionConfig("PresentCardHoldMs", 1600)) or 1600
    if hold < 0 then hold = 0 end
    if hold > 5000 then hold = 5000 end
    if hold > 0 then Wait(math.floor(hold)) end
    return true
end

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local src = tonumber(source)
    if not src then return end
    playerState(src)

    if connectionCfg("UseDeferrals", true) ~= true then
        return
    end

    local name = fireacText(playerName or GetPlayerName(src) or ("ID " .. tostring(src)), "Player", 64)
    print(("^%sFIREAC^0: ^2Player ^3%s ^2Connecting ...^0"):format(COLORS, name))

    local hasDeferral = deferrals and deferrals.defer and deferrals.update and deferrals.done
    if not hasDeferral then
        return
    end

    deferrals.defer()
    Wait(0)

    local function showStatus(step, total, title, detail, delayMultiplier, accent, isProblem)
        if not fireacShouldShowConnectionStep(isProblem == true) then
            fireacDeferralWait(delayMultiplier or 1)
            return true
        end

        if fireacDeferralMode() == "card" then
            return fireacPresentCard(deferrals, step, total, title, detail, accent or "Attention")
        end

        return fireacStatus(deferrals, step, total, title, detail, delayMultiplier or 1)
    end

    local startDelay = tonumber(fireacConnectionConfig("DeferralDelayMs", 0)) or 0
    if startDelay < 0 then startDelay = 0 end
    if startDelay > 10000 then startDelay = 10000 end
    if startDelay > 0 then Wait(math.floor(startDelay)) end

    showStatus(1, 4, "Initializing secure gateway", "Protected by FIREAC", 1, "Attention")
    showStatus(2, 4, "Verifying player identity", name, 1, "Accent")

    local function finish(message)
        if message and message ~= "" then
            pcall(function() deferrals.done(message) end)
        else
            pcall(function() deferrals.done() end)
        end
    end

    showStatus(3, 4, "Checking ban database", "Please wait", 0.8, "Accent")
    local okBan, banData = pcall(FIREAC_INBANLIST, src)
    if okBan and banData and banData[1] then
        local reason = fireacText(banData[1].REASON, "Unknown", 160)
        local banId = fireacText(banData[1].BANID, "N/A", 48)
        print(("^%sFIREAC^0: ^1Blocked banned player ^3%s^0 | Ban ID: %s"):format(COLORS, name, banId))
        pcall(FIREAC_SENDLOG, src, FIREAC.Webhooks and FIREAC.Webhooks.Connect or "", "TFJ", banId, reason)
        showStatus(4, 4, "Connection blocked", "Ban ID #" .. banId, 1, "Attention", true)
        Wait(600)
        finish(("\n[FIREAC]\nYou are banned from this server.\nReason: %s\nBan ID: #%s"):format(reason, banId))
        return
    elseif not okBan then
        print("^3[FIREAC]^0 Ban-list lookup failed during connection; allowing player fail-open.")
    end

    if FIREAC.Connection and FIREAC.Connection.AntiBlackListName and type(Names) == "table" then
        local normalizedName = fireacNormalizeName(playerName or name)
        for _, blocked in ipairs(Names) do
            local needle = fireacNormalizeName(blocked)
            if needle ~= "" and normalizedName:find(needle, 1, true) then
                print(("^%sFIREAC^0: ^1Player ^3%s ^3Try For Join ^0| ^3Black List Word in name: ^3%s^0"):format(COLORS, name, tostring(blocked)))
                pcall(FIREAC_SENDLOG, src, FIREAC.Webhooks and FIREAC.Webhooks.Connect or "", "BLN", "Black List Name", "Found " .. tostring(blocked) .. " in player name")
                showStatus(4, 4, "Connection blocked", "Invalid player name", 1, "Attention", true)
                Wait(600)
                finish(("\n[FIREAC]\nYour player name contains a blocked term: %s"):format(tostring(blocked)))
                return
            end
        end
    end

    local endpoint = tostring(GetPlayerEndpoint(src) or "")
    local localEndpoint = endpoint == "" or endpoint == "127.0.0.1" or endpoint:find("192.168.", 1, true) == 1 or endpoint:find("10.", 1, true) == 1 or endpoint:find("172.16.", 1, true) == 1
    local function allow(statusDetail)
        if not fireacProblemOnlyMode() then
            showStatus(4, 4, "Connection accepted", statusDetail or "Welcome to the server", 1, "Good")
        else
            fireacDeferralWait(0.5)
        end
        pcall(FIREAC_SENDLOG, src, FIREAC.Webhooks and FIREAC.Webhooks.Connect or "", "CONNECT")
        local hold = tonumber(fireacConnectionConfig("ConnectHoldMs", 1800)) or 1800
        if hold < 0 then hold = 0 end
        if hold > 5000 then hold = 5000 end
        if hold > 0 then Wait(math.floor(hold)) end
        finish()
    end

    if FIREAC.Connection and FIREAC.Connection.AntiVPN and not localEndpoint then
        showStatus(3, 4, "Checking network reputation", "VPN/proxy scan", 1, "Accent")
        local finished = false
        PerformHttpRequest("http://ip-api.com/json/" .. endpoint .. "?fields=status,message,proxy,hosting,isp,country,city", function(statusCode, body)
            if finished then return end
            finished = true
            if statusCode ~= 200 or not body or body == "" then
                print("^3[FIREAC]^0 VPN lookup unavailable; allowing player fail-open.")
                allow("VPN lookup unavailable")
                return
            end
            local ok, data = pcall(json.decode, body)
            if not ok or type(data) ~= "table" or data.status == "fail" then
                print("^3[FIREAC]^0 Invalid VPN lookup response; allowing player fail-open.")
                allow("VPN lookup invalid")
                return
            end
            if data.proxy == true or data.hosting == true then
                local isp = fireacText(data.isp, "Unknown", 80)
                local country = fireacText(data.country, "Unknown", 60)
                local city = fireacText(data.city, "Unknown", 60)
                print(("^%sFIREAC^0: ^1Player ^3%s ^3Try For Join ^0| ^3VPN/Hosting ^3 ISP: %s / Country: %s / City: %s^0"):format(COLORS, name, isp, country, city))
                pcall(FIREAC_SENDLOG, src, FIREAC.Webhooks and FIREAC.Webhooks.Connect or "", "VPN")
                showStatus(4, 4, "Connection blocked", "VPN/proxy is not allowed", 1, "Attention", true)
                Wait(600)
                finish(("\n[FIREAC]\nVPN/hosting connections are not allowed.\nISP: %s\nCountry: %s\nCity: %s"):format(isp, country, city))
                return
            end
            allow("Network reputation passed")
        end, "GET")

        CreateThread(function()
            Wait(8000)
            if not finished then
                finished = true
                print("^3[FIREAC]^0 VPN lookup timed out; allowing player fail-open.")
                allow("VPN lookup timed out")
            end
        end)
        return
    end

    allow("Security checks passed")
end)

local SV_VEHICLES, SV_PEDS, SV_OBJECT = {}, {}, {}
local ENTITY_LISTS = { [1] = Peds, [2] = Vehicle, [3] = Objects }
local ENTITY_NAMES = { [1] = "Ped", [2] = "Vehicle", [3] = "Object" }
local ENTITY_BLACKLIST_FLAGS = {
    [1] = function() return FIREAC.AntiBlackListPed end,
    [2] = function() return FIREAC.AntiBlackListVehicle end,
    [3] = function() return FIREAC.AntiBlackListObject or FIREAC.AntiBlackListBuilding end,
}
local ENTITY_SPAM_FLAGS = {
    [1] = function() return FIREAC.AntiSpamPed end,
    [2] = function() return FIREAC.AntiSpamVehicle end,
    [3] = function() return FIREAC.AntiSpamObject end,
}
local ENTITY_SPAM_TABLES = { [1] = SV_PEDS, [2] = SV_VEHICLES, [3] = SV_OBJECT }

local function modelInList(model, list)
    if type(list) ~= "table" then return false end
    for _, value in ipairs(list) do
        if model == GetHashKey(value) then return true end
    end
    return false
end

local function getEntitiesByType(entityType)
    if entityType == 1 then return GetAllPeds() end
    if entityType == 2 then return GetAllVehicles() end
    if entityType == 3 then return GetAllObjects() end
    return {}
end

local function FIREAC_InspectCreatedEntity(entity)
    if not runtimeCfg("EntityCreatedMonitor", false) then return end
    if not entity or entity == 0 then return end

    local delay = tonumber(runtimeCfg("EntityCreatedDelayMs", 750)) or 750
    if delay < 0 then delay = 0 end
    if delay > 5000 then delay = 5000 end

    SetTimeout(delay, function()
        if not runtimeCfg("EntityCreatedMonitor", false) then return end
        if not DoesEntityExist(entity) then return end

        local owner = tonumber(NetworkGetFirstEntityOwner(entity))
        if not owner or owner <= 0 or not GetPlayerName(owner) then return end

        local entityType = GetEntityType(entity)
        if not ENTITY_NAMES[entityType] then return end

        local population = GetEntityPopulationType(entity)
        if population ~= 0 then return end
        if FIREAC_IS_TRUSTED(owner) then return end

        local model = GetEntityModel(entity)
        local kind = ENTITY_NAMES[entityType]
        if ENTITY_BLACKLIST_FLAGS[entityType]() and modelInList(model, ENTITY_LISTS[entityType]) then
            if DoesEntityExist(entity) then DeleteEntity(entity) end
            FIREAC_ACTION(owner, FIREAC.EntityPunishment, "Anti Spawn " .. kind,
                ("Blocked %s model: %s"):format(kind:lower(), tostring(model)))
            return
        end

        if not ENTITY_SPAM_FLAGS[entityType]() then return end
        local key = GetPlayerToken(owner, 0) or tostring(owner)
        local bucket = ENTITY_SPAM_TABLES[entityType]
        local now = os.time()
        local state = bucket[key]
        if not state or now - state.startedAt >= 10 then
            state = { count = 0, startedAt = now, acted = false }
            bucket[key] = state
        end
        state.count = state.count + 1

        local maximum = tonumber(FIREAC["Max" .. kind]) or 10
        if state.count < maximum or state.acted then return end
        state.acted = true

        if DoesEntityExist(entity) then DeleteEntity(entity) end
        FIREAC_ACTION(owner, FIREAC.SpamPunishment, "Anti Spam " .. kind,
            ("Created %s entities within 10 seconds"):format(state.count))
    end)
end

AddEventHandler("entityCreated", function(entity)
    FIREAC_InspectCreatedEntity(entity)
end)

function StartAntiCheat()
    local resources = {
        "configs/fire-config.lua", "tables/fire-event.lua", "tables/fire-explosions.lua",
        "tables/fire-name.lua", "tables/fire-object.lua", "tables/fire-peds.lua",
        "tables/fire-plate.lua", "tables/fire-vehicle.lua", "tables/fire-weapon.lua",
        "tables/fire-words.lua", "tables/fire-task.lua", "tables/fire-anim.lua",
        "tables/fire-emoji.lua"
    }

    local missing = {}
    for _, resource in ipairs(resources) do
        if LoadResourceFile(GetCurrentResourceName(), resource) then
            print("^" .. COLORS .. "[FIREAC]^0: ^2" .. resource .. " LOADED !^0")
        else
            missing[#missing + 1] = resource
        end
    end

    if #missing > 0 then
        print("^" .. COLORS .. "[FIREAC]^0: ^1 Some Files Of FIREAC Not Found! Please Replace or Repair Them^0")
        print("^1[FIREAC]^0 Missing required files: " .. table.concat(missing, ", "))
        return false
    end

    print("^" .. COLORS .. "")
    print([[
    8888888888 8888888 8888888b.  8888888888        d8888  .d8888b.
    888          888   888   Y88b 888              d88888 d88P  Y88b
    888          888   888    888 888             d88P888 888    888
    8888888      888   888   d88P 8888888        d88P 888 888
    888          888   8888888P"  888           d88P  888 888
    888          888   888 T88b   888          d88P   888 888    888
    888          888   888  T88b  888         d8888888888 Y88b  d88P
    888        8888888 888   T88b 8888888888 d88P     888  "Y8888P"
                    ]])

    local configuredPort = tostring(FIREAC.ServerConfig.Port or "auto")
    local actualPort = GetConvar("netPort", configuredPort)
    local artifact = GetConvar("version", "unknown build")

    print("^3═════════════════════════════════════════════════════════════════════════════════")
    print("^1★ ^3THE PERFECT ^4FiveM MLO's ^1-> ^5https://kingmaps.net/")
    print("^1★ ^3For the best ^1FiveM Anticheat ^1-> ^5https://fiveguard.net/")
    print("^1★ ^3Most reliable ^2FiveM Scripts ^3supporting ^1QBCORE, ESX, VRP ^1-> ^5https://justscripts.net/")
    print("^3═════════════════════════════════════════════════════════════════════════════════")
    print("^6This resource is sponsored by ^5https://kingmaps.net/^6, ^5https://fiveguard.net/^6, and ^5https://justscripts.net/^6!")
    print("^" .. COLORS .. "[FIREAC]^0: ^3Server Build : " .. tostring(artifact))
    print("^" .. COLORS .. "[FIREAC]^0: ^2Version " .. tostring(FIREAC.Version) .. " started successfully on port " .. tostring(actualPort) .. ".^0")

    local webhook = FIREAC.Webhooks and FIREAC.Webhooks.Ban or ""
    if type(webhook) == "string" and webhook:match("^https?://") then
        PerformHttpRequest(webhook, function() end, "POST", json.encode({
            username = "FIREAC",
            embeds = {{
                title = "FIREAC started",
                description = ("Version: %s\nServer: %s\nPort: %s\nBuild: %s"):format(
                    tostring(FIREAC.Version), tostring(FIREAC.ServerConfig.Name), tostring(actualPort), tostring(artifact)),
                color = 16733440
            }}
        }), { ["Content-Type"] = "application/json" })
    end

    return true
end

function FIREAC_ISNEARADMIN(SRC)
    local src = tonumber(SRC)
    if not src then return false end
    local myPed = GetPlayerPed(src)
    if not myPed or myPed == 0 or not DoesEntityExist(myPed) then return false end
    local myPos = GetEntityCoords(myPed)
    for _, value in ipairs(GetPlayers()) do
        local other = tonumber(value)
        if other and other ~= src and FIREAC_GETADMINS(other) then
            local adminPed = GetPlayerPed(other)
            if adminPed and adminPed ~= 0 and DoesEntityExist(adminPed) then
                local adminPos = GetEntityCoords(adminPed)
                if #(myPos - adminPos) < 30.0 then return true end
            end
        end
    end
    return false
end

local PERMISSION_TABLES = {
    whitelist = "fireac_whitelist",
    admin = "fireac_admin",
    unban = "fireac_unban"
}

local function permissionIdentifiers(src)
    local result, seen = {}, {}
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier and identifier ~= "" and not seen[identifier] then
            seen[identifier] = true
            result[#result + 1] = identifier
        end
        if identifier and identifier:sub(1, 8) == "discord:" then
            local legacy = identifier:sub(9)
            if legacy ~= "" and not seen[legacy] then
                seen[legacy] = true
                result[#result + 1] = legacy
            end
        end
    end
    return result
end

local function databasePermission(src, kind)
    src = tonumber(src)
    local tableName = PERMISSION_TABLES[kind]
    if not src or not tableName or not GetPlayerName(src) then return false end

    PERMISSION_CACHE[src] = PERMISSION_CACHE[src] or {}
    local cached = PERMISSION_CACHE[src][kind]
    local t = monotonicMs()
    if cached and cached.expiresAt > t then return cached.value end

    local identifiers = permissionIdentifiers(src)
    if #identifiers == 0 then return false end

    local placeholders, params = {}, {}
    for index, identifier in ipairs(identifiers) do
        local key = "@id" .. index
        placeholders[#placeholders + 1] = key
        params[key] = identifier
    end

    local p = promise.new()
    MySQL.Async.fetchAll(("SELECT id FROM %s WHERE identifier IN (%s) LIMIT 1"):format(tableName, table.concat(placeholders, ",")), params,
        function(rows)
            local value = rows ~= nil and rows[1] ~= nil
            PERMISSION_CACHE[src][kind] = { value = value, expiresAt = monotonicMs() + 15000 }
            p:resolve(value)
        end)
    return Citizen.Await(p)
end

local function acePermission(src, permission)
    if not permission or permission == "" then return false end
    return IsPlayerAceAllowed(tostring(src), permission) == true
end

function FIREAC_WHITELIST(SRC)
    local src = tonumber(SRC)
    if not src then return false end
    if FIREAC.ACE and FIREAC.ACE.Enable == true then
        return acePermission(src, FIREAC.ACE.Whitelist)
    end
    return databasePermission(src, "whitelist")
end

function FIREAC_GETADMINS(SRC)
    local src = tonumber(SRC)
    if not src then return false end
    if FIREAC.ACE and FIREAC.ACE.Enable == true then
        return acePermission(src, FIREAC.ACE.Admin)
    end
    return databasePermission(src, "admin")
end

function FIREAC_UNBANACCESS(SRC)
    local src = tonumber(SRC)
    if not src then return false end
    if FIREAC.ACE and FIREAC.ACE.Enable == true then
        return acePermission(src, FIREAC.ACE.Unban)
    end
    return databasePermission(src, "unban")
end

function FIREAC_IS_TRUSTED(SRC)
    local src = tonumber(SRC)
    if not src then return false end
    if TRUSTED_ADMINS[src] == true then return true end
    if FIREAC_CHECK_TEMP_WHITELIST(src) then return true end
    if FIREAC_WHITELIST(src) then return true end
    if FIREAC_GETADMINS(src) then return true end
    return false
end

invalidatePermissionCache = function(src)
    if src then
        PERMISSION_CACHE[tonumber(src)] = nil
    else
        PERMISSION_CACHE = {}
    end
end

function FIREAC_ERROR(SERVER_NAME, ERROR_MESSAGE)
    local message = tostring(ERROR_MESSAGE or "Unknown FIREAC error")
    print(("^1[FIREAC ERROR]^0 %s"):format(message))

    local webhook = FIREAC.Webhooks and FIREAC.Webhooks.Error or ""
    if type(webhook) ~= "string" or not webhook:match("^https?://") then return end

    PerformHttpRequest(webhook, function() end, "POST", json.encode({
        username = "FIREAC",
        embeds = {{
            title = "FIREAC warning",
            description = ("Server: %s\nError: `%s`"):format(tostring(SERVER_NAME or "Unknown"), message:sub(1, 1500)),
            color = 16753920
        }}
    }), { ["Content-Type"] = "application/json" })
end

function FIREAC_BAN(SRC, REASON)
    local src = tonumber(SRC)
    local reason = type(REASON) == "string" and REASON:sub(1, 1000) or nil
    if not src or not reason or not GetPlayerName(src) then
        FIREAC_ERROR(FIREAC.ServerConfig.Name, "FIREAC_BAN received an invalid source or reason")
        return false
    end

    local identifiers = {
        steam = "__NONE__", discord = "__NONE__", license = "__NONE__",
        live = "__NONE__", xbl = "__NONE__"
    }
    for _, value in ipairs(GetPlayerIdentifiers(src)) do
        local kind, identifier = value:match("^([^:]+):(.+)$")
        if kind == "discord" then identifiers.discord = identifier
        elseif kind and identifiers[kind] then identifiers[kind] = value end
    end

    local tokens = {}
    local tokenCount = tonumber(GetNumPlayerTokens(src)) or 0
    for index = 0, tokenCount - 1 do
        local token = GetPlayerToken(src, index)
        if type(token) == "string" and token ~= "" then tokens[#tokens + 1] = token end
    end

    local banId = os.time() * 1000 + math.random(0, 999)
    local playerName = fireacDbName(GetPlayerName(src))
    local hasNameColumn = fireacEnsureColumn("fireac_banlist", "PLAYER_NAME", "varchar(128) NULL DEFAULT NULL AFTER `id`")
    local p = promise.new()

    local params = {
        ["@steam"] = identifiers.steam, ["@discord"] = identifiers.discord,
        ["@license"] = identifiers.license, ["@live"] = identifiers.live,
        ["@xbl"] = identifiers.xbl, ["@ip"] = GetPlayerEndpoint(src) or "__NONE__",
        ["@tokens"] = json.encode(tokens), ["@banid"] = banId, ["@reason"] = reason,
        ["@player_name"] = playerName
    }

    if hasNameColumn then
        MySQL.Async.execute([[INSERT INTO fireac_banlist
            (PLAYER_NAME, STEAM, DISCORD, LICENSE, LIVE, XBL, IP, TOKENS, BANID, REASON)
            VALUES (@player_name, @steam, @discord, @license, @live, @xbl, @ip, @tokens, @banid, @reason)]], params, function(rowsChanged)
            p:resolve((tonumber(rowsChanged) or 0) > 0)
        end)
    else
        MySQL.Async.execute([[INSERT INTO fireac_banlist
            (STEAM, DISCORD, LICENSE, LIVE, XBL, IP, TOKENS, BANID, REASON)
            VALUES (@steam, @discord, @license, @live, @xbl, @ip, @tokens, @banid, @reason)]], params, function(rowsChanged)
            p:resolve((tonumber(rowsChanged) or 0) > 0)
        end)
    end

    local inserted = Citizen.Await(p)
    return inserted and banId or false
end

local function fireacCleanBanReason(value, fallback)
    local text = tostring(value or fallback or "Banned by FIREAC")
    text = text:gsub("[%c]", " "):gsub("%s+", " "):sub(1, 240)
    if text == "" then text = fallback or "Banned by FIREAC" end
    return text
end

function FIREAC_BAN_PLAYER(targetId, reason, issuer)
    local target = tonumber(targetId)
    if not target or target <= 0 or not GetPlayerName(target) then
        return false, "invalid_player"
    end

    local finalReason = fireacCleanBanReason(reason, "Banned by FIREAC")
    local finalIssuer = fireacCleanBanReason(issuer or GetInvokingResource() or "server", "server")
    local playerName = GetPlayerName(target) or ("ID " .. tostring(target))
    local details = "Issued by " .. finalIssuer

    if FIREAC.ScreenShot and FIREAC.ScreenShot.Enable
        and GetResourceState("discord-screenshot") == "started"
        and FIREAC.Webhooks and type(FIREAC.Webhooks.ScreenShot) == "string"
        and FIREAC.Webhooks.ScreenShot:match("^https?://") then
        FIREAC_SCREENSHOT(target, finalReason, details, "BAN")
    end

    FIREAC_SENDLOG(target, FIREAC.Webhooks and FIREAC.Webhooks.Ban or "", "BAN", finalReason, details)
    FIREAC_MESSAGE(target, "BAN", playerName, finalReason)

    local banId = FIREAC_BAN(target, finalReason)
    local fireEmoji = Emoji and Emoji.Fire or "🔥"

    if banId then
        print(("^1[FIREAC]^0 Banned ^3%s^0 | %s | By: %s | Ban ID: %s"):format(playerName, finalReason, finalIssuer, tostring(banId)))
        DropPlayer(target, ("\n[%s FIREAC %s]\n%s\nReason: %s\nBan ID: #%s"):format(fireEmoji, fireEmoji,
            FIREAC.Message and FIREAC.Message.Ban or "You have been banned.", finalReason, tostring(banId)))
        return true, banId
    end

    FIREAC_ERROR(FIREAC.ServerConfig.Name, "External/admin ban could not be persisted; player was kicked instead")
    DropPlayer(target, ("\n[%s FIREAC %s]\n%s\nReason: %s"):format(fireEmoji, fireEmoji,
        FIREAC.Message and FIREAC.Message.Kick or "You have been kicked.", finalReason))
    return false, "db_failed"
end

function BanPlayer(targetId, reason, issuer)
    return FIREAC_BAN_PLAYER(targetId, reason, issuer)
end

RegisterCommand("fireacban", function(src, args)
    args = args or {}
    local executor = tonumber(src) or 0
    if executor > 0 and not FIREAC_GETADMINS(executor) then
        FIREAC_ACTION(executor, FIREAC.AdminMenu.MenuPunishment, "Anti Ban Players", "Unauthorized fireacban command")
        return
    end

    local target = tonumber(args and args[1])
    if not target or not GetPlayerName(target) then
        print("^1[FIREAC]^0 Usage: fireacban [server_id] [reason]")
        return
    end

    table.remove(args, 1)
    local reason = table.concat(args or {}, " ")
    if reason == "" then reason = "Banned by FIREAC command" end

    local issuer = executor > 0 and ("Admin " .. (GetPlayerName(executor) or tostring(executor)) .. " (" .. tostring(executor) .. ")") or "server console"
    FIREAC_BAN_PLAYER(target, reason, issuer)
end, false)

RegisterCommand("fireacunban", function(src, args)
    args = args or {}
    local executor = tonumber(src) or 0
    if executor > 0 and not FIREAC_GETADMINS(executor) then
        FIREAC_ACTION(executor, FIREAC.AdminMenu.MenuPunishment, "Anti Unban", "Unauthorized fireacunban command")
        return
    end

    local banId = tonumber(args and args[1])
    if not banId then
        print("^1[FIREAC]^0 Usage: fireacunban [ban_id]")
        return
    end

    local issuer = executor > 0 and ("Admin " .. (GetPlayerName(executor) or tostring(executor)) .. " (" .. tostring(executor) .. ")") or "server console"
    local ok, result = FIREAC_UNBAN_PLAYER(banId, issuer)
    if not ok then
        print(("^1[FIREAC]^0 Unban failed for Ban ID %s | %s"):format(tostring(banId), tostring(result)))
    end
end, false)

function FIREAC:UNBAN(BanID)
    local p = promise.new()
    if tonumber(BanID) then
        MySQL.Async.execute('DELETE FROM fireac_banlist WHERE BANID=@BANID', {
            ['@BANID'] = tonumber(BanID)
        }, function(rowsChanged)
            if rowsChanged > 0 then
                p:resolve(true)
            else
                p:resolve(false)
            end
        end)
    else
        p:resolve(false)
    end
    return Citizen.Await(p)
end

function FIREAC_UNBAN_PLAYER(banId, issuer)
    local id = tonumber(banId)
    if not id then
        return false, "invalid_ban_id"
    end

    local ok = FIREAC:UNBAN(id)
    if ok then
        local who = tostring(issuer or GetInvokingResource() or "server"):gsub("[%c]", " "):sub(1, 120)
        print(("^2[FIREAC]^0 Unbanned Ban ID ^3%s^0 | By: %s"):format(tostring(id), who))
        return true, id
    end

    return false, "not_found"
end

function UnbanPlayer(banId, issuer)
    return FIREAC_UNBAN_PLAYER(banId, issuer)
end

local ACCESS_TABLE_ALLOWLIST = {
    fireac_admin = true,
    fireac_whitelist = true,
    fireac_unban = true
}

local function addAccessIdentifier(playerId, tableName)
    local p = promise.new()
    playerId = tonumber(playerId)
    if not playerId or not ACCESS_TABLE_ALLOWLIST[tableName] or not GetPlayerName(playerId) then
        p:resolve(false)
        return Citizen.Await(p)
    end

    local license
    for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
        if identifier:sub(1, 8) == "license:" then
            license = identifier
            break
        end
    end
    if not license then
        p:resolve(false)
        return Citizen.Await(p)
    end

    local playerName = fireacDbName(GetPlayerName(playerId))
    local hasNameColumn = fireacEnsureColumn(tableName, "player_name", "varchar(128) NULL DEFAULT NULL AFTER `identifier`")

    MySQL.Async.fetchScalar(("SELECT id FROM `%s` WHERE identifier=@identifier LIMIT 1"):format(tableName), {
        ["@identifier"] = license
    }, function(existing)
        if existing then
            if hasNameColumn then
                MySQL.Async.execute(("UPDATE `%s` SET player_name=@player_name WHERE identifier=@identifier"):format(tableName), {
                    ["@identifier"] = license,
                    ["@player_name"] = playerName
                }, function()
                    invalidatePermissionCache(playerId)
                    p:resolve(true)
                end)
            else
                invalidatePermissionCache(playerId)
                p:resolve(true)
            end
            return
        end

        if hasNameColumn then
            MySQL.Async.execute(("INSERT INTO `%s` (`identifier`, `player_name`) VALUES (@identifier, @player_name)"):format(tableName), {
                ["@identifier"] = license,
                ["@player_name"] = playerName
            }, function(rowsChanged)
                invalidatePermissionCache(playerId)
                p:resolve((tonumber(rowsChanged) or 0) > 0)
            end)
        else
            MySQL.Async.execute(("INSERT INTO `%s` (`identifier`) VALUES (@identifier)"):format(tableName), {
                ["@identifier"] = license
            }, function(rowsChanged)
                invalidatePermissionCache(playerId)
                p:resolve((tonumber(rowsChanged) or 0) > 0)
            end)
        end
    end)
    return Citizen.Await(p)
end

function FIREAC:ADDADMIN(Player_ID)
    return addAccessIdentifier(Player_ID, "fireac_admin")
end

function FIREAC:ADDWHITELIST(Player_ID)
    return addAccessIdentifier(Player_ID, "fireac_whitelist")
end

function FIREAC:ADDUNBAN(Player_ID)
    return addAccessIdentifier(Player_ID, "fireac_unban")
end

function FIREAC_INBANLIST(SRC)
    local p = promise.new()
    local src = tonumber(SRC)
    if not src then
        p:resolve(false)
        return Citizen.Await(p)
    end

    local identifiers = {
        steam = "__NO_STEAM__", discord = "__NO_DISCORD__", license = "__NO_LICENSE__",
        live = "__NO_LIVE__", xbl = "__NO_XBL__"
    }
    for _, value in ipairs(GetPlayerIdentifiers(src)) do
        local kind, identifier = value:match("^([^:]+):(.+)$")
        if kind == "discord" then
            identifiers.discord = identifier
        elseif kind and identifiers[kind] then
            identifiers[kind] = value
        end
    end

    local token = GetPlayerToken(src, 0)
    local tokenPattern = type(token) == "string" and token ~= "" and ("%%" .. token .. "%%") or "%__NO_TOKEN__%"
    MySQL.Async.fetchAll([[SELECT * FROM fireac_banlist
        WHERE STEAM = @steam OR DISCORD = @discord OR LICENSE = @license
           OR LIVE = @live OR XBL = @xbl OR IP = @ip OR TOKENS LIKE @token
        ORDER BY id DESC LIMIT 1]], {
        ["@steam"] = identifiers.steam,
        ["@discord"] = identifiers.discord,
        ["@license"] = identifiers.license,
        ["@live"] = identifiers.live,
        ["@xbl"] = identifiers.xbl,
        ["@ip"] = GetPlayerEndpoint(src) or "__NO_IP__",
        ["@token"] = tokenPattern,
    }, function(result)
        p:resolve(result and #result > 0 and result or false)
    end)

    return Citizen.Await(p)
end

function FIREAC_ACTION(SRC, ACTION, REASON, DETAILS)
    local src = tonumber(SRC)
    local action = tostring(ACTION or "WARN"):upper()
    local reason = tostring(REASON or "Unknown detection")
    local details = tostring(DETAILS or "No details")

    if not src or src <= 0 or not GetPlayerName(src) then return false end
    if action ~= "WARN" and action ~= "KICK" and action ~= "BAN" then action = "WARN" end
    if FIREAC_IS_TRUSTED(src) then return false end
    if FIREAC_IS_SPAMLIST(src, action, reason, details) then return false end
    FIREAC_ADD_SPAMLIST(src, action, reason, details)

    if FIREAC.ScreenShot and FIREAC.ScreenShot.Enable
        and GetResourceState("discord-screenshot") == "started"
        and FIREAC.Webhooks and type(FIREAC.Webhooks.ScreenShot) == "string"
        and FIREAC.Webhooks.ScreenShot:match("^https?://") then
        FIREAC_SCREENSHOT(src, reason, details, action)
    end

    local playerName = GetPlayerName(src) or ("ID " .. src)
    FIREAC_SENDLOG(src, FIREAC.Webhooks and FIREAC.Webhooks.Ban or "", action, reason, details)
    FIREAC_MESSAGE(src, action, playerName, reason)

    if action == "WARN" then
        print(("^3[FIREAC]^0 Warning for ^3%s^0 | %s"):format(playerName, reason))
        return true
    end

    local fireEmoji = Emoji and Emoji.Fire or "🔥"
    if action == "BAN" then
        local banId = FIREAC_BAN(src, reason)
        if banId then
            print(("^1[FIREAC]^0 Banned ^3%s^0 | %s | Ban ID: %s"):format(playerName, reason, banId))
            DropPlayer(src, ("\n[%s FIREAC %s]\n%s\nReason: %s\nBan ID: #%s"):format(fireEmoji, fireEmoji,
                FIREAC.Message and FIREAC.Message.Ban or "You have been banned.", reason, banId))
        else
            FIREAC_ERROR(FIREAC.ServerConfig.Name, "Ban record could not be persisted; player was kicked instead")
            DropPlayer(src, ("\n[%s FIREAC %s]\n%s\nReason: %s"):format(fireEmoji, fireEmoji,
                FIREAC.Message and FIREAC.Message.Kick or "You have been kicked.", reason))
        end
        return true
    end

    print(("^1[FIREAC]^0 Kicked ^3%s^0 | %s"):format(playerName, reason))
    DropPlayer(src, ("\n[%s FIREAC %s]\n%s\nReason: %s"):format(fireEmoji, fireEmoji,
        FIREAC.Message and FIREAC.Message.Kick or "You have been kicked.", reason))
    return true
end

function FIREAC_MESSAGE(SRC, TYPE, NAME, REASON)
    local settings = FIREAC.ChatSettings or {}
    if not settings.Enable then return end
    local src = tonumber(SRC)
    local kind = tostring(TYPE or "WARN"):upper()
    local name = tostring(NAME or "Unknown"):gsub("[%c]", ""):sub(1, 80)
    local reason = tostring(REASON or "Unknown"):gsub("[%c]", " "):sub(1, 240)
    local icon = kind == "BAN" and (Emoji and Emoji.Ban or "⛔")
        or kind == "KICK" and (Emoji and Emoji.Kick or "👢")
        or (Emoji and Emoji.Warn or "⚠️")
    local payload = {
        color = kind == "WARN" and {255, 170, 0} or {255, 70, 70},
        multiline = true,
        args = { "FIREAC", ("%s %s | %s (%s): %s"):format(icon, kind, name, tostring(src or "?"), reason) }
    }

    if kind == "WARN" and settings.PrivateWarn then
        for _, playerId in ipairs(GetPlayers()) do
            if FIREAC_GETADMINS(playerId) then TriggerClientEvent("chat:addMessage", playerId, payload) end
        end
    else
        TriggerClientEvent("chat:addMessage", -1, payload)
    end
end

local function validWebhook(url)
    return type(url) == "string" and url:match("^https?://") ~= nil and not url:find("YOUR_WEBHOOK", 1, true)
end

local function limited(value, length)
    value = tostring(value or "Not Found")
    if #value > length then return value:sub(1, length - 3) .. "..." end
    return value
end

local function getIdentitySummary(src)
    local ids = { steam = "Not Found", discord = "Not Found", license = "Not Found", live = "Not Found", xbl = "Not Found" }
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        local kind = identifier:match("^([^:]+):")
        if kind == "steam" then ids.steam = identifier
        elseif kind == "discord" then ids.discord = "<@" .. identifier:sub(9) .. ">"
        elseif kind == "license" then ids.license = identifier
        elseif kind == "live" then ids.live = identifier
        elseif kind == "xbl" then ids.xbl = identifier end
    end
    return ids
end

function FIREAC_SENDLOG(SRC, URL, TYPE, REASON, DETAILS)
    local src = tonumber(SRC)
    if not src or not GetPlayerName(src) or not validWebhook(URL) then return false end

    local kind = tostring(TYPE or "INFO"):upper()
    local colors = { BAN = 16711680, KICK = 16744192, WARN = 16763904, CONNECT = 5763719, DISCONNECT = 9807270, EXPLOSION = 16724787 }
    local ids = getIdentitySummary(src)
    local ped = GetPlayerPed(src)
    local coordsText = "Unavailable"
    if ped and ped ~= 0 and DoesEntityExist(ped) then
        local c = GetEntityCoords(ped)
        coordsText = ("%.2f, %.2f, %.2f"):format(c.x, c.y, c.z)
    end
    local endpoint = GetPlayerEndpoint(src) or "Not Found"
    if FIREAC.Connection and FIREAC.Connection.HideIP then endpoint = "Hidden by owner" end

    local description = table.concat({
        ("**Player:** %s (`%s`)"):format(limited(GetPlayerName(src), 120), src),
        ("**Type:** %s"):format(limited(kind, 40)),
        ("**Reason:** %s"):format(limited(REASON, 700)),
        ("**Details:** %s"):format(limited(DETAILS, 1200)),
        ("**License:** `%s`"):format(limited(ids.license, 150)),
        ("**Discord:** %s"):format(limited(ids.discord, 150)),
        ("**Steam:** `%s`"):format(limited(ids.steam, 150)),
        ("**Endpoint:** `%s`"):format(limited(endpoint, 100)),
        ("**Coords:** `%s`"):format(coordsText),
        ("**Ping:** `%sms`"):format(GetPlayerPing(src) or 0),
    }, "\n")

    PerformHttpRequest(URL, function(status)
        if status and status >= 400 then
            print(("^3[FIREAC]^0 Discord webhook returned HTTP %s"):format(status))
        end
    end, "POST", json.encode({
        username = "FIREAC Security",
        embeds = {{
            title = "FIREAC • " .. limited(kind, 60),
            description = description,
            color = colors[kind] or 16744448,
            footer = { text = ("FIREAC %s • %s"):format(tostring(FIREAC.Version), os.date("!%Y-%m-%d %H:%M:%S UTC")) }
        }}
    }), { ["Content-Type"] = "application/json" })
    return true
end

function FIREAC_REFRESHCMD()
    SERVER_CMDS = {}
    for _, command in ipairs(GetRegisteredCommands() or {}) do
        if type(command) == "table" and type(command.name) == "string" then
            SERVER_CMDS[command.name] = true
        end
    end
    return SERVER_CMDS
end

function FIREAC_ISPLAYERLOAD(source)
    local SRC = tonumber(source)
    local PED = GetPlayerPed(SRC)
    local STATUS = false
    if SRC ~= nil then
        if DoesEntityExist(PED) then
            if SPAWNED[SRC] ~= nil then
                STATUS = true
            else
                STATUS = false
            end
        else
            STATUS = false
        end
    else
        STATUS = false
    end
    return STATUS
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for index in pairs(SPAMLIST) do
            SPAMLIST[index] = nil
        end
        Citizen.Wait(0)
    end
end)

function FIREAC_ADD_SPAMLIST(SRC, ACTION, REASON, DETAILS)
    local src = tonumber(SRC)
    if not src then return end
    SPAMLIST[src] = SPAMLIST[src] or {}
    local key = table.concat({ tostring(ACTION), tostring(REASON), tostring(DETAILS) }, "|")
    SPAMLIST[src][key] = monotonicMs() + 10000
end

function FIREAC_IS_SPAMLIST(SRC, ACTION, REASON, DETAILS)
    local src = tonumber(SRC)
    if not src or not SPAMLIST[src] then return false end
    local key = table.concat({ tostring(ACTION), tostring(REASON), tostring(DETAILS) }, "|")
    local expires = SPAMLIST[src][key]
    if not expires then return false end
    if monotonicMs() >= expires then
        SPAMLIST[src][key] = nil
        return false
    end
    return true
end

function FIREAC_SCREENSHOT(SRC, REASON, DETAILS, ACTION)
    local src = tonumber(SRC)
    local webhook = FIREAC.Webhooks and FIREAC.Webhooks.ScreenShot or ""
    if not src or not GetPlayerName(src) or not validWebhook(webhook) then return false end
    if GetResourceState("discord-screenshot") ~= "started" then return false end

    local colors = { WARN = 16763904, KICK = 16744192, BAN = 16711680 }
    local ids = getIdentitySummary(src)
    local options = {
        encoding = (FIREAC.ScreenShot and FIREAC.ScreenShot.Format) or "jpg",
        quality = math.max(0.1, math.min(tonumber(FIREAC.ScreenShot and FIREAC.ScreenShot.Quality) or 0.75, 1.0))
    }
    local payload = {
        username = "FIREAC Security",
        embeds = {{
            title = "FIREAC • Screenshot",
            color = colors[tostring(ACTION or "WARN"):upper()] or colors.WARN,
            description = table.concat({
                ("**Player:** %s (`%s`)"):format(limited(GetPlayerName(src), 120), src),
                ("**Reason:** %s"):format(limited(REASON, 700)),
                ("**Details:** %s"):format(limited(DETAILS, 1200)),
                ("**License:** `%s`"):format(limited(ids.license, 150)),
                ("**Discord:** %s"):format(limited(ids.discord, 150))
            }, "\n"),
            footer = { text = ("FIREAC %s • %s"):format(tostring(FIREAC.Version), os.date("!%Y-%m-%d %H:%M:%S UTC")) }
        }}
    }

    local ok, err = pcall(function()
        exports["discord-screenshot"]:requestCustomClientScreenshotUploadToDiscord(src, webhook, options, payload)
    end)
    if not ok then
        print(("^3[FIREAC]^0 Screenshot request failed: %s"):format(tostring(err)))
        return false
    end
    return true
end

function FIREAC_CHANGE_TEMP_WHHITELIST(SRC, STATUS, DURATION_MS)
    local src = tonumber(SRC)
    if not src then return false end
    if STATUS == true then
        local duration = math.max(1000, math.min(tonumber(DURATION_MS) or 15000, 600000))
        TEMP_WHITELIST[src] = monotonicMs() + duration
        return true
    end
    TEMP_WHITELIST[src] = nil
    return true
end

function FIREAC_CHANGE_TEMP_WHITELIST(SRC, STATUS, DURATION_MS)
    return FIREAC_CHANGE_TEMP_WHHITELIST(SRC, STATUS, DURATION_MS)
end

function FIREAC_CHECK_TEMP_WHITELIST(SRC)
    local src = tonumber(SRC)
    if not src then return false end
    local expires = TEMP_WHITELIST[src]
    if not expires then return false end
    if monotonicMs() >= expires then
        TEMP_WHITELIST[src] = nil
        return false
    end
    return true
end

RegisterNetEvent("FIREAC:adminState", function(enabled, durationMs)
    local src = tonumber(source)
    if not src then return end
    if not FIREAC_GETADMINS(src) then
        FIREAC_ACTION(src, FIREAC.AdminMenu.MenuPunishment, "Anti Open Admin Menu",
            "Unauthorized admin exemption request")
        return
    end
    if enabled == true then
        fireacGrantActionGrace(src, durationMs, "adminMode")
    else
        FIREAC_CHANGE_TEMP_WHHITELIST(src, false, 0)
    end
end)

RegisterCommand('funban', function(source, args)
    local BAN_ID = args[1]

    if source == 0 then
        local unbaned = FIREAC:UNBAN(BAN_ID)

        if unbaned then
            print("^" .. COLORS .. "[FIREAC]^0: You unbanned ^2" .. tostring(BAN_ID) .. "^0 !")
        else
            print("^" .. COLORS .. "[FIREAC]^0: ^1 unban failed !^0")
        end
    else
        if FIREAC_UNBANACCESS(source) then
            local unbaned = FIREAC:UNBAN(BAN_ID)

            if unbaned then
                TriggerClientEvent("chatMessage", source, "[FIREAC]", { 255, 0, 0 }, "You unbanned ^2" .. tostring(BAN_ID) ..
                    "^0 !")
            else
                TriggerClientEvent("chatMessage", source, "[FIREAC]", { 255, 0, 0 }, "Your unbanned failed !")
            end
        else
            TriggerClientEvent("chatMessage", source, "[FIREAC]", { 255, 0, 0 },
                "You don't have access for unban players !")
        end
    end
end)

RegisterCommand('unban', function(source, args)
    local BAN_ID = args[1]
    if source == 0 then
        local unbaned = FIREAC:UNBAN(BAN_ID)
        if unbaned then
            print("^" .. COLORS .. "[FIREAC]^0: You unbanned ^2" .. tostring(BAN_ID) .. "^0 !")
        else
            print("^" .. COLORS .. "[FIREAC]^0: ^1 unban failed !^0")
        end
    elseif FIREAC_UNBANACCESS(source) then
        local unbaned = FIREAC:UNBAN(BAN_ID)
        if unbaned then
            TriggerClientEvent("chatMessage", source, "[FIREAC]", { 255, 0, 0 }, "You unbanned ^2" .. tostring(BAN_ID) .. "^0 !")
        else
            TriggerClientEvent("chatMessage", source, "[FIREAC]", { 255, 0, 0 }, "Your unban failed !")
        end
    else
        TriggerClientEvent("chatMessage", source, "[FIREAC]", { 255, 0, 0 }, "You don't have access for unban players !")
    end
end)

RegisterCommand('addadmin', function(source, args)
    local PLAYER_ID = tonumber(args[1])

    if source == 0 then
        if PLAYER_ID and GetPlayerName(PLAYER_ID) then
            local addedAdmin = FIREAC:ADDADMIN(PLAYER_ID)

            if addedAdmin then
                TRUSTED_ADMINS[PLAYER_ID] = true
                invalidatePermissionCache(PLAYER_ID)
                FIREAC_CHANGE_TEMP_WHHITELIST(PLAYER_ID, true, 120000)
                print("^" ..
                    COLORS ..
                    "[FIREAC]^0: You added ^2" .. GetPlayerName(PLAYER_ID) .. "(" .. PLAYER_ID .. ")^0 to admin list^0 !")
                TriggerClientEvent("FIREAC:clientGrace", PLAYER_ID, 120000)
                TriggerClientEvent("FIREAC:allowToOpen", PLAYER_ID, true)
            else
                print("^" .. COLORS .. "[FIREAC]^0: ^1 add admin failed !^0")
            end
        else
            print("^" .. COLORS .. "[FIREAC]^0: ^1 This player isn't online !^0")
        end
    end
end)

RegisterCommand('addwhitelist', function(source, args)
    local PLAYER_ID = tonumber(args[1])

    if source == 0 then
        if PLAYER_ID and GetPlayerName(PLAYER_ID) then
            local addedAdmin = FIREAC:ADDWHITELIST(PLAYER_ID)

            if addedAdmin then
                invalidatePermissionCache(PLAYER_ID)
                FIREAC_CHANGE_TEMP_WHHITELIST(PLAYER_ID, true, 120000)
                TriggerClientEvent("FIREAC:clientGrace", PLAYER_ID, 120000)
                print("^" ..
                    COLORS ..
                    "[FIREAC]^0: You added ^2" .. GetPlayerName(PLAYER_ID) .. "(" .. PLAYER_ID .. ")^0 to whitelist^0 !")
            else
                print("^" .. COLORS .. "[FIREAC]^0: ^1 failed to add access !^0")
            end
        else
            print("^" .. COLORS .. "[FIREAC]^0: ^1 This player isn't online !^0")
        end
    end
end)

RegisterCommand('addunban', function(source, args)
    local PLAYER_ID = tonumber(args[1])

    if source == 0 then
        if PLAYER_ID and GetPlayerName(PLAYER_ID) then
            local addedAdmin = FIREAC:ADDUNBAN(PLAYER_ID)

            if addedAdmin then
                print("^" ..
                    COLORS ..
                    "[FIREAC]^0: You added ^2" ..
                    GetPlayerName(PLAYER_ID) .. "(" .. PLAYER_ID .. ")^0 to unban access^0 !")
            else
                print("^" .. COLORS .. "[FIREAC]^0: ^1 failed to add access !^0")
            end
        else
            print("^" .. COLORS .. "[FIREAC]^0: ^1 This player isn't online !^0")
        end
    end
end)
