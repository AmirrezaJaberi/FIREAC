let playerCoords = null;
let selectedPlayer = null;

$(function () {
  window.addEventListener("message", function (event) {
    if (event.data.action == "openUI") {
      openUI();
    } else if (event.data.action == "updateAdminStatus") {
      updateAdminStatus(event.data.godmode, event.data.visible);
    } else if (event.data.action == "updatePlayerCoords") {
      updateAdminCoords(event.data.location);
    } else if (event.data.action == "updatePlayerList") {
      updatePlayerList(event.data.playerList);
    } else if (event.data.action == "openPlayerActionMenu") {
      openPlayerActionMenu(event.data.data);
    } else if (event.data.action == "updateBanList") {
      updateBanList(event.data.banList);
    } else if (event.data.action == "updateAdminData") {
      updateAdminList(event.data.adminList);
    } else if (event.data.action == "updateUnbanAccess") {
      updateUnbanAccess(event.data.unbanList);
    } else if (event.data.action == "updateWhiteList") {
      updateWhiteList(event.data.whiteList);
    }
  });
});

function openUrl(url) {
  window.invokeNative("openUrl", url);
}

function closeUI() {
  $("#main-ui").fadeOut();
  $.post(`https://FIREAC/onCloseMenu`);
}

function openUI() {
  $("#main-ui").fadeIn();

  getAdminStatus();
  getAdminCoords();
}

function openAdminToolMenu() {
  setTimeout(() => {
    $("#admin-menu").fadeIn();
    $("#title").text("Admin Tool");
  }, 500);

  getAdminStatus();
  getAdminCoords();

  closeMainMenu();
}

function getAdminStatus() {
  $.post(`https://FIREAC/getAdminStatus`);
}

function getAdminCoords() {
  $.post(`https://FIREAC/getPlayerCoords`);
}

function getPlayersData() {
  $.post(`https://FIREAC/getAllPlayersData`);
}

function getBanListData() {
  $.post(`https://FIREAC/getBanListData`);
}

function getAdminListData() {
  $.post(`https://FIREAC/getAdminListData`);
}

function getUnbanAccessData() {
  $.post(`https://FIREAC/getUnbanAccessData`);
}

function getWhitelistData() {
  $.post(`https://FIREAC/getWhitelistData`);
}

function openPlayersMenu() {
  setTimeout(() => {
    $("#player-menu").fadeIn();
    $("#title").text("Player List Menu");
  }, 500);

  getPlayersData();

  closeMainMenu();
}

function openServerMenu() {
  setTimeout(() => {
    $("#server-menu").fadeIn();
    $("#title").text("Server Tool");
  }, 500);

  closeMainMenu();
}

function openTeleportMenu() {
  setTimeout(() => {
    $("#teleport-menu").fadeIn();
    $("#title").text("Teleport Options");
  }, 500);

  closeMainMenu();
}

function openVisionMenu() {
  setTimeout(() => {
    $("#vision-menu").fadeIn();
    $("#title").text("Vision View");
  }, 500);

  closeMainMenu();
}

function openVehicleMenu() {
  setTimeout(() => {
    $("#vehicle-menu").fadeIn();
    $("#title").text("Vehicle Spawner");
  }, 500);

  closeMainMenu();
}

function openBanListMenu() {
  setTimeout(() => {
    $("#banlist-menu").fadeIn();
    $("#title").text("Ban List");
  }, 500);

  getBanListData();

  closeMainMenu();
}

function openAdminListMenu() {
  setTimeout(() => {
    $("#adminlist-menu").fadeIn();
    $("#title").text("Admin List");
  }, 500);

  getAdminListData();

  closeMainMenu();
}

function openUnbanListMenu() {
  setTimeout(() => {
    $("#ubAccess-menu").fadeIn();
    $("#title").text("Admin List");
  }, 500);

  getUnbanAccessData();

  closeMainMenu();
}

function openWhitelistMenu() {
  setTimeout(() => {
    $("#wlusers-menu").fadeIn();
    $("#title").text("Admin List");
  }, 500);

  getWhitelistData();

  closeMainMenu();
}

function closeMainMenu() {
  $("#main-menu").fadeOut();
}

function backToMainMenu() {
  $("#admin-menu").fadeOut();
  $("#player-menu").fadeOut();
  $("#server-menu").fadeOut();
  $("#teleport-menu").fadeOut();
  $("#vision-menu").fadeOut();
  $("#vehicle-menu").fadeOut();
  $("#banlist-menu").fadeOut();
  $("#adminlist-menu").fadeOut();
  $("#ubAccess-menu").fadeOut();
  $("#wlusers-menu").fadeOut();

  setTimeout(() => {
    $("#main-menu").fadeIn();
    $("#title").text("Admin Menu");
  }, 500);
}

function doAction(actionName) {
  $.post(`https://FIREAC/${actionName}`);

  getAdminStatus();

  if (actionName == "copyLiveCoords") {
    copyTextToClipboard(playerCoords);
    $(".coords-loaction").html("Coords copied successfully !");
  }
}

function updateAdminStatus(godmode, visible) {
  if (godmode) {
    // Status when (Godmode)
    document.getElementById("disable-godmode").style.display = "none";
    document.getElementById("enable-godmode").style.display = "flex";

    document.getElementById("godmode").style.backgroundColor = "#bdff9c";
    document.getElementById("godmode").style.border = "2px solid #a7ff64";
  } else {
    // Status when (Not Godmode)
    document.getElementById("enable-godmode").style.display = "none";
    document.getElementById("disable-godmode").style.display = "flex";

    document.getElementById("godmode").style.backgroundColor = "#ffa19c";
    document.getElementById("godmode").style.border = "2px solid #ff6b64";
  }
  if (visible) {
    // Status when (Invisible)
    document.getElementById("enable-invisible").style.display = "none";
    document.getElementById("disable-invisible").style.display = "flex";

    document.getElementById("invisible").style.backgroundColor = "#ffa19c";
    document.getElementById("invisible").style.border = "2px solid #ff6b64";
  } else {
    // Status when (Not Invisible)
    document.getElementById("disable-invisible").style.display = "none";
    document.getElementById("enable-invisible").style.display = "flex";

    document.getElementById("invisible").style.backgroundColor = "#bdff9c";
    document.getElementById("invisible").style.border = "2px solid #a7ff64";
  }
}

function updateAdminCoords(location) {
  const xFormatted = location.x.toFixed(2);
  const yFormatted = location.y.toFixed(2);
  const zFormatted = location.z.toFixed(2);
  const wFormatted = location.w.toFixed(2);

  playerCoords = `vector4(${xFormatted}, ${yFormatted}, ${zFormatted}, ${wFormatted})`;
  $(".coords-loaction").html(playerCoords);
}

function copyTextToClipboard(text) {
  var copyText = document.createElement("textarea");

  copyText.value = text;

  document.body.appendChild(copyText);

  copyText.select();

  document.execCommand("copy");

  document.body.removeChild(copyText);
}

function updatePlayerList(playersList) {
  var playerList = $(".playerList");
  playerList.empty();

  $.each(playersList, function (index, playerData) {
    var newRow =
      $(`                            <button class="row" onclick="openPlayerActionList(${playerData.id})">
    <svg width="40px" height="40px" viewBox="0 0 24 24" version="1.1"
        xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <g id="Stockholm-icons-/-General-/-User" stroke="none" stroke-width="1" fill="none"
            fill-rule="evenodd">
            <polygon id="Shape" points="0 0 24 0 24 24 0 24"></polygon>
            <path
                d="M12,11 C9.790861,11 8,9.209139 8,7 C8,4.790861 9.790861,3 12,3 C14.209139,3 16,4.790861 16,7 C16,9.209139 14.209139,11 12,11 Z"
                id="Mask" fill="#000000" fill-rule="nonzero" opacity="0.3"></path>
            <path
                d="M3.00065168,20.1992055 C3.38825852,15.4265159 7.26191235,13 11.9833413,13 C16.7712164,13 20.7048837,15.2931929 20.9979143,20.2 C21.0095879,20.3954741 20.9979143,21 20.2466999,21 C16.541124,21 11.0347247,21 3.72750223,21 C3.47671215,21 2.97953825,20.45918 3.00065168,20.1992055 Z"
                id="Mask-Copy" fill="#000000" fill-rule="nonzero"></path>
        </g>
    </svg>
    <div class="playerID">
        <span class="title"> ID : </span>
        <span class="value"> ${playerData.id} </span>
    </div>
    <div class="playerName">
        <span class="title"> Player name : </span>
        <span class="value"> ${playerData.name} </span>
    </div>
</button>`);

    playerList.append(newRow);
  });
}

function openPlayerActionList(id) {
  if (id) {
    $.post(
      `https://FIREAC/getPlayerData`,
      JSON.stringify({
        playerId: id,
      })
    );
  }
}

function openPlayerActionMenu(data) {
  selectedPlayer = data.id;
  $(".playerList").fadeOut();
  setTimeout(() => {
    $(".playerAction").fadeIn();

    $("#playerName").text(data.name);
    $("#playerId").text(data.id);
    $("#armourCount").text(data.armour);
    $("#heartCount").text(data.health);
  }, 500);
}

function closePlayerActionMenu() {
  $(".playerAction").fadeOut();
  setTimeout(() => {
    $(".playerList").fadeIn();
  }, 500);
}

function doActionOnTargetPlayer(actionName) {
  if (actionName && selectedPlayer) {
    $.post(
      `https://FIREAC/${actionName}`,
      JSON.stringify({
        playerId: selectedPlayer,
      })
    );
    closeUI();
  }
}

function doOnServer(actionName) {
  if (actionName) {
    $.post(`https://FIREAC/${actionName}`);
    closeUI();
  }
}

function teleportToWaypoint() {
  $.post(`https://FIREAC/teleportToWaypoint`);
  closeUI();
}

function teleportToCoords() {
  var xValue = $("#x-coords").val();
  var yValue = $("#y-coords").val();
  var zValue = $("#z-coords").val();

  if (xValue && yValue && zValue) {
    $.post(
      `https://FIREAC/teleportToCoords`,
      JSON.stringify({
        x: xValue,
        y: yValue,
        z: zValue,
      })
    );

    closeUI();
  }
}

function changeVisionView(visionType) {
  if (visionType) {
    $.post(`https://FIREAC/${visionType}`);
    closeUI();
  }
}

function spawnVehicleForSelf() {
  var vehicleName = $("#vehicle-name-m").val();

  if (vehicleName) {
    $.post(
      `https://FIREAC/spawnVehicleForSelf`,
      JSON.stringify({
        vehicleName: vehicleName,
      })
    );
    closeUI();
  }
}

function spawnVehicleOthers() {
  var vehicleName = $("#vehicle-name-o").val();
  var targetId = $("#target-player").val();

  if (vehicleName && targetId) {
    $.post(
      `https://FIREAC/spawnVehicleOthers`,
      JSON.stringify({
        vehicleName: vehicleName,
        targetId: targetId,
      })
    );
    closeUI();
  }
}
function unbanSelectedPlayer(banID) {
  $.post(
    `https://FIREAC/unbanSelectedPlayer`,
    JSON.stringify({
      banID: banID,
    })
  );
  closeUI();
  openBanListMenu();
}

function updateBanList(bannedPlayers) {
  var banlist = $(".banlist-menu .mainbar");
  banlist.empty();

  $.each(bannedPlayers, function (index, banData) {
    var newRow =
      $(`                        <button onclick="unbanSelectedPlayer(${banData.BANID})">
    <svg width="34px" height="34px" viewBox="0 0 24 24" version="1.1"
        xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <g id="Stockholm-icons-/-Communication-/-Delete-user" stroke="none" stroke-width="1"
            fill="none" fill-rule="evenodd">
            <polygon id="Shape" points="0 0 24 0 24 24 0 24"></polygon>
            <path
                d="M9,11 C6.790861,11 5,9.209139 5,7 C5,4.790861 6.790861,3 9,3 C11.209139,3 13,4.790861 13,7 C13,9.209139 11.209139,11 9,11 Z M21,8 L17,8 C16.4477153,8 16,7.55228475 16,7 C16,6.44771525 16.4477153,6 17,6 L21,6 C21.5522847,6 22,6.44771525 22,7 C22,7.55228475 21.5522847,8 21,8 Z"
                id="Combined-Shape" fill="#000000" fill-rule="nonzero" opacity="0.3"></path>
            <path
                d="M0.00065168429,20.1992055 C0.388258525,15.4265159 4.26191235,13 8.98334134,13 C13.7712164,13 17.7048837,15.2931929 17.9979143,20.2 C18.0095879,20.3954741 17.9979143,21 17.2466999,21 C13.541124,21 8.03472472,21 0.727502227,21 C0.476712155,21 -0.0204617505,20.45918 0.00065168429,20.1992055 Z"
                id="Mask-Copy" fill="#000000" fill-rule="nonzero"></path>
        </g>
    </svg>
    <span class="banid">#${banData.BANID}</span>
    <span class="reason">${banData.REASON}</span>
</button>`);
    banlist.append(newRow);
  });
}

function removeSelectedAdmin(id) {
  $.post(
    `https://FIREAC/removeSelectedAdmin`,
    JSON.stringify({
      id: id,
    })
  );
  closeUI();
  openAdminListMenu();
}

function updateAdminList(adminList) {
  var adminlist = $(".adminlist-menu .mainbar");
  adminlist.empty();

  $.each(adminList, function (index, adminData) {
    var newRow =
      $(`                        <button onclick="removeSelectedAdmin(${adminData.id})">
    <svg width="34px" height="34px" viewBox="0 0 24 24" version="1.1"
        xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <g id="Stockholm-icons-/-Communication-/-Delete-user" stroke="none" stroke-width="1"
            fill="none" fill-rule="evenodd">
            <polygon id="Shape" points="0 0 24 0 24 24 0 24"></polygon>
            <path
                d="M9,11 C6.790861,11 5,9.209139 5,7 C5,4.790861 6.790861,3 9,3 C11.209139,3 13,4.790861 13,7 C13,9.209139 11.209139,11 9,11 Z M21,8 L17,8 C16.4477153,8 16,7.55228475 16,7 C16,6.44771525 16.4477153,6 17,6 L21,6 C21.5522847,6 22,6.44771525 22,7 C22,7.55228475 21.5522847,8 21,8 Z"
                id="Combined-Shape" fill="#000000" fill-rule="nonzero" opacity="0.3"></path>
            <path
                d="M0.00065168429,20.1992055 C0.388258525,15.4265159 4.26191235,13 8.98334134,13 C13.7712164,13 17.7048837,15.2931929 17.9979143,20.2 C18.0095879,20.3954741 17.9979143,21 17.2466999,21 C13.541124,21 8.03472472,21 0.727502227,21 C0.476712155,21 -0.0204617505,20.45918 0.00065168429,20.1992055 Z"
                id="Mask-Copy" fill="#000000" fill-rule="nonzero"></path>
        </g>
    </svg>
    <span class="identifier">${adminData.identifier}</span>
</button>`);
    adminlist.append(newRow);
  });
}

function removeUnbanAccess(id) {
  $.post(
    `https://FIREAC/removeUnbanAccess`,
    JSON.stringify({
      id: id,
    })
  );
  closeUI();
  openUnbanListMenu();
}

function updateUnbanAccess(unbanAccessList) {
  var unbanAcess = $(".ubAccess-menu .mainbar");
  unbanAcess.empty();

  $.each(unbanAccessList, function (index, unbanAccessData) {
    var newRow =
      $(`                        <button onclick="removeUnbanAccess(${unbanAccessData.id})">
      <svg width="34px" height="34px" viewBox="0 0 24 24" version="1.1"
          xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
          <g id="Stockholm-icons-/-Communication-/-Delete-user" stroke="none" stroke-width="1"
              fill="none" fill-rule="evenodd">
              <polygon id="Shape" points="0 0 24 0 24 24 0 24"></polygon>
              <path
                  d="M9,11 C6.790861,11 5,9.209139 5,7 C5,4.790861 6.790861,3 9,3 C11.209139,3 13,4.790861 13,7 C13,9.209139 11.209139,11 9,11 Z M21,8 L17,8 C16.4477153,8 16,7.55228475 16,7 C16,6.44771525 16.4477153,6 17,6 L21,6 C21.5522847,6 22,6.44771525 22,7 C22,7.55228475 21.5522847,8 21,8 Z"
                  id="Combined-Shape" fill="#000000" fill-rule="nonzero" opacity="0.3"></path>
              <path
                  d="M0.00065168429,20.1992055 C0.388258525,15.4265159 4.26191235,13 8.98334134,13 C13.7712164,13 17.7048837,15.2931929 17.9979143,20.2 C18.0095879,20.3954741 17.9979143,21 17.2466999,21 C13.541124,21 8.03472472,21 0.727502227,21 C0.476712155,21 -0.0204617505,20.45918 0.00065168429,20.1992055 Z"
                  id="Mask-Copy" fill="#000000" fill-rule="nonzero"></path>
          </g>
      </svg>
      <span class="identifier">${unbanAccessData.identifier}</span>
  </button>`);
    unbanAcess.append(newRow);
  });
}

function removeWhitelistUser(id) {
  $.post(
    `https://FIREAC/removeWhitelistUser`,
    JSON.stringify({
      id: id,
    })
  );
  closeUI();
  openWhitelistMenu();
}

function updateWhiteList(whiteLists) {
  var whiteList = $(".wlusers-menu .mainbar");
  whiteList.empty();

  $.each(whiteLists, function (index, whiteListData) {
    var newRow =
      $(`                        <button onclick="removeWhitelistUser(${whiteListData.id})">
      <svg width="34px" height="34px" viewBox="0 0 24 24" version="1.1"
          xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
          <g id="Stockholm-icons-/-Communication-/-Delete-user" stroke="none" stroke-width="1"
              fill="none" fill-rule="evenodd">
              <polygon id="Shape" points="0 0 24 0 24 24 0 24"></polygon>
              <path
                  d="M9,11 C6.790861,11 5,9.209139 5,7 C5,4.790861 6.790861,3 9,3 C11.209139,3 13,4.790861 13,7 C13,9.209139 11.209139,11 9,11 Z M21,8 L17,8 C16.4477153,8 16,7.55228475 16,7 C16,6.44771525 16.4477153,6 17,6 L21,6 C21.5522847,6 22,6.44771525 22,7 C22,7.55228475 21.5522847,8 21,8 Z"
                  id="Combined-Shape" fill="#000000" fill-rule="nonzero" opacity="0.3"></path>
              <path
                  d="M0.00065168429,20.1992055 C0.388258525,15.4265159 4.26191235,13 8.98334134,13 C13.7712164,13 17.7048837,15.2931929 17.9979143,20.2 C18.0095879,20.3954741 17.9979143,21 17.2466999,21 C13.541124,21 8.03472472,21 0.727502227,21 C0.476712155,21 -0.0204617505,20.45918 0.00065168429,20.1992055 Z"
                  id="Mask-Copy" fill="#000000" fill-rule="nonzero"></path>
          </g>
      </svg>
      <span class="identifier">${whiteListData.identifier}</span>
  </button>`);
    whiteList.append(newRow);
  });
}

$(document).keydown(function (e) {
  if (e.keyCode == 27) {
    closeUI();
  }
});
