const NUI_RESOURCE = typeof GetParentResourceName === "function" ? GetParentResourceName() : "FIREAC";

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function safeNumber(value, fallback = 0) {
  const number = Number(value);
  return Number.isFinite(number) ? number : fallback;
}

function normalizeSearch(value) {
  return String(value ?? "").toLowerCase().replace(/\s+/g, " ").trim();
}

function applySearchFilter(targetSelector) {
  const target = $(targetSelector);
  if (!target.length) return;
  const input = $(`.record-search[data-target="${targetSelector}"]`);
  const query = normalizeSearch(input.val());
  const rows = target.children("button, .record-row, .player-row, .access-player-row");
  let visible = 0;

  rows.each(function () {
    const row = $(this);
    const haystack = normalizeSearch(row.text());
    const match = !query || haystack.includes(query);
    row.toggle(match);
    if (match) visible += 1;
  });

  target.find(".search-empty").remove();
  if (rows.length && visible === 0) {
    target.append(`<div class="empty-state search-empty">No matching records found.</div>`);
  }
}

function applyAllSearchFilters() {
  $(".record-search").each(function () {
    applySearchFilter($(this).data("target"));
  });
}

function nuiPost(name, payload) {
  return $.post(`https://${NUI_RESOURCE}/${name}`, payload ? JSON.stringify(payload) : undefined);
}

let playerCoords = null;
let selectedPlayer = null;
let currentView = "home";
let cachedStats = { players: 0, vehicles: 0, props: 0, peds: 0, bans: 0, admins: 0, whitelist: 0, unban: 0, recentAdmins: [], recentBans: [] };

const pagedLists = {
  bans: { page: 1, pageSize: 25, total: 0, search: "" },
  admins: { page: 1, pageSize: 25, total: 0, search: "" },
  unban: { page: 1, pageSize: 25, total: 0, search: "" },
  whitelist: { page: 1, pageSize: 25, total: 0, search: "" },
};

const listTargets = {
  bans: "#ban-records",
  admins: "#admin-records",
  unban: "#unban-records",
  whitelist: "#whitelist-records",
};

const searchTimers = {};

function listPayload(scope) {
  const state = pagedLists[scope] || { page: 1, pageSize: 25, search: "" };
  return { page: state.page, pageSize: state.pageSize, search: state.search || "" };
}

function setListMeta(scope, meta) {
  if (!pagedLists[scope]) return;
  meta = meta || {};
  pagedLists[scope].page = Math.max(1, Number(meta.page) || pagedLists[scope].page || 1);
  pagedLists[scope].pageSize = Math.max(5, Math.min(100, Number(meta.pageSize) || pagedLists[scope].pageSize || 25));
  pagedLists[scope].total = Math.max(0, Number(meta.total) || 0);
  if (typeof meta.search === "string") pagedLists[scope].search = meta.search;
}

function renderPager(scope) {
  const state = pagedLists[scope];
  if (!state) return;
  const pagerId = scope === "bans" ? "ban-pager" : `${scope}-pager`;
  const pager = $(`#${pagerId}`);
  if (!pager.length) return;

  const pages = Math.max(1, Math.ceil((state.total || 0) / state.pageSize));
  const from = state.total === 0 ? 0 : ((state.page - 1) * state.pageSize) + 1;
  const to = Math.min(state.total, state.page * state.pageSize);

  pager.html(`
    <button type="button" ${state.page <= 1 ? "disabled" : ""} onclick="changeListPage('${scope}', -1)">Prev</button>
    <span>Page <b>${state.page}</b> / ${pages} · ${from}-${to} of ${state.total}</span>
    <button type="button" ${state.page >= pages ? "disabled" : ""} onclick="changeListPage('${scope}', 1)">Next</button>
  `);
}

function changeListPage(scope, delta) {
  const state = pagedLists[scope];
  if (!state) return;
  const pages = Math.max(1, Math.ceil((state.total || 0) / state.pageSize));
  state.page = Math.max(1, Math.min(pages, state.page + Number(delta || 0)));
  loadPagedList(scope);
}

function loadPagedList(scope) {
  if (scope === "bans") return getBanListData();
  if (scope === "admins") return getAdminListData();
  if (scope === "unban") return getUnbanAccessData();
  if (scope === "whitelist") return getWhitelistData();
}

const pageLoaders = {
  home: () => { refreshDashboard(); getAdminStatus(); getAdminCoords(); },
  admin: () => { getAdminStatus(); getAdminCoords(); },
  players: getPlayersData,
  server: refreshDashboard,
  teleport: getAdminCoords,
  vehicle: refreshDashboard,
  bans: getBanListData,
  admins: () => { getAdminListData(); refreshAccessPlayers("admins"); },
  unban: getUnbanAccessData,
  whitelist: () => { getWhitelistData(); refreshAccessPlayers("whitelist"); },
};

$(function () {
  $(document).on("input", ".record-search", function () {
    const target = $(this).data("target");
    const scope = Object.keys(listTargets).find((key) => listTargets[key] === target);
    if (scope && pagedLists[scope]) {
      pagedLists[scope].search = String($(this).val() || "").trim();
      pagedLists[scope].page = 1;
      clearTimeout(searchTimers[scope]);
      searchTimers[scope] = setTimeout(() => loadPagedList(scope), 220);
      return;
    }
    applySearchFilter(target);
  });

  $(".fireac-body").on("wheel", function (event) {
    if (!$("#main-ui").is(":visible")) return;
    const original = event.originalEvent;
    const activeView = $(".view.is-active");
    if (!activeView.length) return;
    activeView[0].scrollTop += original.deltaY;
    this.scrollTop += original.deltaY;
  });

  window.addEventListener("message", function (event) {
    const data = event.data || {};
    if (data.action === "openUI") openUI();
    else if (data.action === "forceClose") hardCloseUI();
    else if (data.action === "updateAdminStatus") updateAdminStatus(data.godmode, data.visible, data.vision, data.spectate);
    else if (data.action === "updatePlayerCoords") updateAdminCoords(data.location);
    else if (data.action === "updatePlayerList") updatePlayerList(data.playerList || []);
    else if (data.action === "openPlayerActionMenu") openPlayerActionMenu(data.data);
    else if (data.action === "updateBanList") updateBanList(data.banList || [], data.meta || {});
    else if (data.action === "updateAdminData") updateAdminList(data.adminList || [], data.meta || {});
    else if (data.action === "updateUnbanAccess") updateUnbanAccess(data.unbanList || [], data.meta || {});
    else if (data.action === "updateWhiteList") updateWhiteList(data.whiteList || [], data.meta || {});
    else if (data.action === "updateAccessPlayers") updateAccessPlayers(data.scope, data.players || []);
    else if (data.action === "updateDashboardStats") updateDashboardStats(data.stats || {});
  });
});

function hardCloseUI() { $("#main-ui").stop(true, true).hide(); resetToHome(); }
function closeUI() { $("#main-ui").fadeOut(140, resetToHome); nuiPost("onCloseMenu"); }
function openUI() { $("#main-ui").fadeIn(140); resetToHome(); refreshDashboard(); getAdminStatus(); getAdminCoords(); }

function resetToHome() { openPage("home", true); }

function setActiveTab(page) {
  $(".tab-button").removeClass("is-active");
  $(`.tab-button[data-page="${page}"]`).addClass("is-active");
}

function openPage(page, skipLoader = false) {
  const view = document.getElementById(`view-${page}`);
  if (!view) return;
  selectedPlayer = null;
  currentView = page;
  $(".view").removeClass("is-active");
  $(`#view-${page}`).addClass("is-active");
  setActiveTab(page);
  $("#header-back").toggle(page !== "home");
  $("#title").text(view.dataset.title || "FIREAC");
  $("#breadcrumb").text(view.dataset.breadcrumb || "Dashboard");
  $(".playerAction").hide();
  $(".playerList").show();
  const loader = pageLoaders[page];
  $(".fireac-body, .view").scrollTop(0);
  if (!skipLoader && loader) loader();
}

function goBack() {
  if (currentView === "players" && $(".playerAction").is(":visible")) { closePlayerActionMenu(); return; }
  if (currentView !== "home") { resetToHome(); refreshDashboard(); return; }
  closeUI();
}

function refreshDashboard() { nuiPost("getDashboardStats"); }
function getAdminStatus() { nuiPost("getAdminStatus"); }
function getAdminCoords() { nuiPost("getPlayerCoords"); }
function getPlayersData() { nuiPost("getAllPlayersData"); }
function getBanListData() { nuiPost("getBanListData", listPayload("bans")); }
function getAdminListData() { nuiPost("getAdminListData", listPayload("admins")); }
function getUnbanAccessData() { nuiPost("getUnbanAccessData", listPayload("unban")); }
function getWhitelistData() { nuiPost("getWhitelistData", listPayload("whitelist")); }

function primaryName(row, fallback) {
  return row?.PLAYER_NAME || row?.player_name || row?.name || fallback || "Unknown";
}
function primaryLicense(row) { return row?.identifier || row?.LICENSE || row?.license || row?.DISCORD || "No identifier stored"; }

function renderOverviewList(selector, rows, kind) {
  const container = $(selector);
  container.empty();
  if (!Array.isArray(rows) || rows.length === 0) {
    container.append(`<div class="empty-state small">No records yet.</div>`);
    return;
  }
  rows.slice(0, 5).forEach((row) => {
    const name = escapeHtml(primaryName(row, kind === "ban" ? `Ban #${row.BANID || "N/A"}` : "Unknown"));
    const sub = kind === "ban"
      ? `Ban #${escapeHtml(row.BANID || "N/A")} · ${escapeHtml(row.REASON || "No reason")}`
      : escapeHtml(primaryLicense(row));
    container.append(`<div class="record-row static ${kind === "ban" ? "danger" : ""}"><span class="avatar">${kind === "ban" ? "⛔" : "🛡️"}</span><span class="row-main"><b>${name}</b><small>${sub}</small></span></div>`);
  });
}

function updateDashboardStats(stats) {
  cachedStats = {
    players: safeNumber(stats.players, cachedStats.players),
    vehicles: safeNumber(stats.vehicles, cachedStats.vehicles),
    props: safeNumber(stats.props ?? stats.objects, cachedStats.props),
    peds: safeNumber(stats.peds, cachedStats.peds),
    bans: safeNumber(stats.bans, cachedStats.bans),
    admins: safeNumber(stats.admins, cachedStats.admins),
    whitelist: safeNumber(stats.whitelist, cachedStats.whitelist),
    unban: safeNumber(stats.unban, cachedStats.unban),
    recentAdmins: Array.isArray(stats.recentAdmins) ? stats.recentAdmins : cachedStats.recentAdmins,
    recentBans: Array.isArray(stats.recentBans) ? stats.recentBans : cachedStats.recentBans,
  };
  const map = { "stat-players": cachedStats.players, "stat-vehicles": cachedStats.vehicles, "stat-props": cachedStats.props, "stat-peds": cachedStats.peds, "stat-bans": cachedStats.bans, "stat-admins": cachedStats.admins, "stat-whitelist": cachedStats.whitelist, "stat-unban": cachedStats.unban };
  Object.entries(map).forEach(([id, value]) => $(`#${id}`).text(value));
  $("#server-vehicles").text(`${cachedStats.vehicles} detected`);
  $("#server-props").text(`${cachedStats.props} detected`);
  $("#server-peds").text(`${cachedStats.peds} detected`);
  renderOverviewList("#overview-admins", cachedStats.recentAdmins, "admin");
  renderOverviewList("#overview-bans", cachedStats.recentBans, "ban");
}

function updateAdminStatus(godmode, visible, vision, spectate) {
  const godEnabled = Boolean(godmode);
  const invisibleEnabled = !Boolean(visible);
  const visionLabel = String(vision || "Normal");
  const visionEnabled = visionLabel.toLowerCase() !== "normal";
  const spectateEnabled = Boolean(spectate);

  $("#godmode").toggleClass("is-on", godEnabled);
  $("#invisible").toggleClass("is-on", invisibleEnabled);
  $("#status-card-godmode").toggleClass("is-on", godEnabled);
  $("#status-card-invisible").toggleClass("is-on", invisibleEnabled);
  $("#status-card-vision").toggleClass("is-on", visionEnabled);
  $("#status-card-spectate").toggleClass("is-on", spectateEnabled);

  $("#godmode-state, #status-godmode").text(godEnabled ? "ON" : "OFF");
  $("#invisible-state, #status-invisible").text(invisibleEnabled ? "ON" : "OFF");
  $("#status-vision").text(visionLabel);
  $("#status-spectate").text(spectateEnabled ? "ON" : "OFF");
}

function updateAdminCoords(location) {
  const x = Number(location?.x), y = Number(location?.y), z = Number(location?.z), w = Number(location?.w);
  if (![x, y, z, w].every(Number.isFinite)) return;
  playerCoords = `vector4(${x.toFixed(2)}, ${y.toFixed(2)}, ${z.toFixed(2)}, ${w.toFixed(2)})`;
  $(".coords-loaction").text(playerCoords);
}

function copyTextToClipboard(text) { const el = document.createElement("textarea"); el.value = text; document.body.appendChild(el); el.select(); document.execCommand("copy"); document.body.removeChild(el); }

function doAction(actionName) {
  if (actionName === "copyLiveCoords") { copyTextToClipboard(playerCoords || ""); $(".coords-loaction").text("Coords copied successfully!"); return; }
  nuiPost(actionName); setTimeout(getAdminStatus, 200);
}

function updatePlayerList(playersList) {
  const playerList = $(".playerList"); playerList.empty();
  cachedStats.players = Array.isArray(playersList) ? playersList.length : cachedStats.players;
  updateDashboardStats(cachedStats);
  if (!Array.isArray(playersList) || playersList.length === 0) { playerList.append(`<div class="empty-state">No online players found.</div>`); return; }
  playersList.forEach((playerData) => {
    const id = safeNumber(playerData.id); if (!Number.isInteger(id) || id <= 0) return;
    const name = escapeHtml(playerData.name || `Player ${id}`);
    const identifier = escapeHtml(playerData.identifier || "license not available yet");
    const initial = escapeHtml(String(playerData.name || "?").trim().charAt(0).toUpperCase() || "?");
    const tags = `${playerData.isAdmin ? "ADMIN" : "PLAYER"}${playerData.isWhitelist ? " · WL" : ""}`;
    playerList.append(`<button class="player-row" onclick="openPlayerActionList(${id})"><span class="avatar">${initial}</span><span class="row-main"><b>${name}</b><small>ID ${id} · ${identifier}</small></span><span class="row-tag">${tags}</span></button>`);
  });
  applySearchFilter(".playerList");
}

function openPlayerActionList(id) { id = Number(id); if (Number.isInteger(id) && id > 0) nuiPost("getPlayerData", { playerId: id }); }
function openPlayerActionMenu(data) {
  const playerId = Number(data?.id); if (!Number.isInteger(playerId) || playerId <= 0) return;
  selectedPlayer = playerId;
  $(".playerList").fadeOut(120, function () {
    $("#playerName").text(data.name || "Player"); $("#playerId").text(playerId); $("#armourCount").text(safeNumber(data.armour)); $("#heartCount").text(safeNumber(data.health)); $(".playerAction").fadeIn(120);
  });
}
function closePlayerActionMenu() { $(".playerAction").fadeOut(120, function () { $(".playerList").fadeIn(120); }); }

function doActionOnTargetPlayer(actionName) {
  const allowed = new Set(["spectate", "ban", "addToAdmin", "addToWhiteList", "addToUnban", "gotoPlayer", "bringPlayer", "kickPlayer"]);
  if (!allowed.has(actionName) || Number(selectedPlayer) <= 0) return;

  const payload = { playerId: selectedPlayer };
  const reason = String($("#moderation-reason").val() || "").trim();

  if (actionName === "ban") {
    payload.reason = reason || "Banned by FIREAC admin menu";
  } else if (actionName === "kickPlayer") {
    payload.reason = reason || "Kicked by FIREAC admin menu";
  }

  nuiPost(actionName, payload);
  if (["ban", "kickPlayer"].includes(actionName)) setTimeout(getPlayersData, 500);
}

function doOnServer(actionName) { const allowed = new Set(["delete_vehicles", "delete_objects", "delete_peds", "delete_all_entity"]); if (allowed.has(actionName)) { nuiPost(actionName); setTimeout(refreshDashboard, 500); } }
function teleportToWaypoint() { nuiPost("teleportToWaypoint"); }
function teleportToCoords() { const x = Number($("#x-coords").val()), y = Number($("#y-coords").val()), z = Number($("#z-coords").val()); if ([x, y, z].every(Number.isFinite)) nuiPost("teleportToCoords", { x, y, z }); }
function changeVisionView(visionType) { if (visionType === "night" || visionType === "thermal") { nuiPost(visionType); setTimeout(getAdminStatus, 250); } }
function spawnVehicleForSelf() { const vehicleName = String($("#vehicle-name-m").val() || "").trim(); if (vehicleName) nuiPost("spawnVehicleForSelf", { vehicleName }); }
function spawnVehicleOthers() { const vehicleName = String($("#vehicle-name-o").val() || "").trim(); const targetId = Number($("#target-player").val()); if (vehicleName && Number.isInteger(targetId) && targetId > 0) nuiPost("spawnVehicleOthers", { vehicleName, targetId }); }
function vehicleAction(actionName) { if (["repairVehicle", "cleanVehicle", "maxVehicleMods", "deleteCurrentVehicle"].includes(actionName)) nuiPost(actionName); }
function setVehicleColor() { const r = Number($("#veh-r").val()), g = Number($("#veh-g").val()), b = Number($("#veh-b").val()); if ([r,g,b].every(Number.isFinite)) nuiPost("setVehicleColor", { r, g, b }); }

function refreshAccessPlayers(scope) { if (scope !== "admins" && scope !== "whitelist") return; const target = scope === "admins" ? "#admin-online-picker" : "#whitelist-online-picker"; $(target).html(`<div class="empty-state small">Loading online players...</div>`); nuiPost("getAccessOnlinePlayers", { scope }); }
function updateAccessPlayers(scope, players) {
  if (scope !== "admins" && scope !== "whitelist") return;
  const target = scope === "admins" ? "#admin-online-picker" : "#whitelist-online-picker";
  const container = $(target); container.empty();
  if (!Array.isArray(players) || players.length === 0) { container.append(`<div class="empty-state small">No online players found.</div>`); return; }
  players.forEach((playerData) => {
    const id = safeNumber(playerData.id); if (!Number.isInteger(id) || id <= 0) return;
    const name = escapeHtml(playerData.name || `Player ${id}`); const identifier = escapeHtml(playerData.identifier || "license not available yet");
    const initial = escapeHtml(String(playerData.name || "?").trim().charAt(0).toUpperCase() || "?");
    const already = scope === "admins" ? Boolean(playerData.isAdmin) : Boolean(playerData.isWhitelist);
    const label = already ? (scope === "admins" ? "ADMIN" : "WHITELISTED") : (scope === "admins" ? "ADD ADMIN" : "ADD WHITELIST");
    const action = scope === "admins" ? "addToAdmin" : "addToWhiteList";
    const button = already ? `<button type="button" class="is-disabled" disabled>${label}</button>` : `<button type="button" onclick="addOnlineAccess('${scope}', '${action}', ${id})">${label}</button>`;
    container.append(`<div class="access-player-row ${already ? "is-existing" : ""}" data-search="${name} ${identifier} ${id} ${label}"><span class="avatar">${initial}</span><span class="row-main"><b>${name}</b><small>ID ${id} · ${identifier}</small></span>${button}</div>`);
  });
  applySearchFilter(target);
}
function addOnlineAccess(scope, actionName, playerId) { playerId = Number(playerId); if (!Number.isInteger(playerId) || playerId <= 0) return; nuiPost(actionName, { playerId }); setTimeout(() => { if (scope === "admins") getAdminListData(); else getWhitelistData(); refreshAccessPlayers(scope); refreshDashboard(); }, 350); }

function renderRecords(containerSelector, rows, options) {
  const container = $(containerSelector); container.empty();
  if (!Array.isArray(rows) || rows.length === 0) { container.append(`<div class="empty-state">No records found.</div>`); return; }
  rows.forEach((row) => {
    const id = Number.parseInt(row[options.idKey], 10); if (!Number.isSafeInteger(id) || id <= 0) return;
    const titleRaw = options.title(row);
    const subRaw = options.sub(row);
    const title = escapeHtml(titleRaw);
    const sub = escapeHtml(subRaw);
    const searchText = escapeHtml(Object.values(row || {}).join(" ") + " " + titleRaw + " " + subRaw);
    container.append(`<button class="record-row ${options.danger ? "danger" : ""}" data-search="${searchText}" onclick="${options.action}(${id})"><span class="avatar">${options.icon}</span><span class="row-main"><b>${title}</b><small>${sub}</small></span><span class="row-tag">${options.label}</span></button>`);
  });
  applySearchFilter(containerSelector);
}
function unbanSelectedPlayer(banID) { banID = Number.parseInt(banID, 10); if (!Number.isSafeInteger(banID) || banID <= 0) return; nuiPost("unbanSelectedPlayer", { banID }); setTimeout(() => { getBanListData(); refreshDashboard(); }, 350); }
function updateBanList(bannedPlayers, meta) {
  setListMeta("bans", meta);
  cachedStats.bans = Number(meta?.total) || (Array.isArray(bannedPlayers) ? bannedPlayers.length : cachedStats.bans);
  updateDashboardStats(cachedStats);
  renderRecords("#ban-records", bannedPlayers, { idKey: "BANID", icon: "⛔", label: "UNBAN", danger: true, action: "unbanSelectedPlayer", title: (row) => primaryName(row, `Ban #${row.BANID || "N/A"}`), sub: (row) => `Ban #${row.BANID || "N/A"} · ${row.LICENSE || row.DISCORD || "No identifier"} · ${row.REASON || "No reason"}` });
  renderPager("bans");
}
function removeSelectedAdmin(id) { nuiPost("removeSelectedAdmin", { id }); setTimeout(() => { getAdminListData(); refreshDashboard(); }, 350); }
function updateAdminList(adminList, meta) {
  setListMeta("admins", meta);
  cachedStats.admins = Number(meta?.total) || (Array.isArray(adminList) ? adminList.length : cachedStats.admins);
  updateDashboardStats(cachedStats);
  renderRecords("#admin-records", adminList, { idKey: "id", icon: "🛡️", label: "REMOVE", action: "removeSelectedAdmin", title: (row) => primaryName(row, "Unknown admin"), sub: (row) => row.identifier || `Record ID ${row.id || "N/A"}` });
  renderPager("admins");
}
function removeUnbanAccess(id) { nuiPost("removeUnbanAccess", { id }); setTimeout(() => { getUnbanAccessData(); refreshDashboard(); }, 350); }
function updateUnbanAccess(list, meta) {
  setListMeta("unban", meta);
  cachedStats.unban = Number(meta?.total) || (Array.isArray(list) ? list.length : cachedStats.unban);
  updateDashboardStats(cachedStats);
  renderRecords("#unban-records", list, { idKey: "id", icon: "🔓", label: "REMOVE", action: "removeUnbanAccess", title: (row) => primaryName(row, "Unknown user"), sub: (row) => row.identifier || `Record ID ${row.id || "N/A"}` });
  renderPager("unban");
}
function removeWhitelistUser(id) { nuiPost("removeWhitelistUser", { id }); setTimeout(() => { getWhitelistData(); refreshDashboard(); }, 350); }
function updateWhiteList(list, meta) {
  setListMeta("whitelist", meta);
  cachedStats.whitelist = Number(meta?.total) || (Array.isArray(list) ? list.length : cachedStats.whitelist);
  updateDashboardStats(cachedStats);
  renderRecords("#whitelist-records", list, { idKey: "id", icon: "✅", label: "REMOVE", action: "removeWhitelistUser", title: (row) => primaryName(row, "Unknown user"), sub: (row) => row.identifier || `Record ID ${row.id || "N/A"}` });
  renderPager("whitelist");
}

$(document).keydown(function (e) { if (e.key === "Escape") { if (currentView !== "home" || $(".playerAction").is(":visible")) goBack(); else closeUI(); } });
