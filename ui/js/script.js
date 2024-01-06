// Variable to store player coordinates
let playerCoords = null;

// Variable to store selected player
let selectedPlayer = null;

// Event listener for messages from the server
$(function () {
  window.addEventListener("message", function (event) {
    // Handling different actions based on the received message data
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

// Function to open a URL
function openUrl(url) {
  window.invokeNative("openUrl", url);
}

// Function to close the UI
function closeUI() {
  $("#main-ui").fadeOut();
  $.post(`https://FIREAC/onCloseMenu`);
}

// Function to open the main UI
function openUI() {
  $("#main-ui").fadeIn();

  // Initializing UI with admin status and coordinates
  getAdminStatus();
  getAdminCoords();
}

// Function to open the admin tool menu
function openAdminToolMenu() {
  setTimeout(() => {
    $("#admin-menu").fadeIn();
    $("#title").text("Admin Tool");
  }, 500);

  // Updating admin status and coordinates
  getAdminStatus();
  getAdminCoords();

  closeMainMenu();
}

// Function to get admin status
function getAdminStatus() {
  $.post(`https://FIREAC/getAdminStatus`);
}

// Function to get admin coordinates
function getAdminCoords() {
  $.post(`https://FIREAC/getPlayerCoords`);
}

// ... (Similar functions for other menu options)

// Function to perform actions
function doAction(actionName) {
  $.post(`https://FIREAC/${actionName}`);

  // Updating admin status after performing actions
  getAdminStatus();

  // Copying live coordinates to clipboard if the action is 'copyLiveCoords'
  if (actionName == "copyLiveCoords") {
    copyTextToClipboard(playerCoords);
    $(".coords-loaction").html("Coords copied successfully !");
  }
}

// Function to update admin status UI based on godmode and visibility
function updateAdminStatus(godmode, visible) {
  // Updating UI elements and styles for godmode status
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

  // Updating UI elements and styles for visibility status
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

// Function to update admin coordinates UI
function updateAdminCoords(location) {
  const xFormatted = location.x.toFixed(2);
  const yFormatted = location.y.toFixed(2);
  const zFormatted = location.z.toFixed(2);
  const wFormatted = location.w.toFixed(2);

  // Creating a formatted vector4 string for player coordinates
  playerCoords = `vector4(${xFormatted}, ${yFormatted}, ${zFormatted}, ${wFormatted})`;
  $(".coords-loaction").html(playerCoords);
}

// Function to copy text to clipboard
function copyTextToClipboard(text) {
  var copyText = document.createElement("textarea");
  copyText.value = text;
  document.body.appendChild(copyText);
  copyText.select();
  document.execCommand("copy");
  document.body.removeChild(copyText);
}

// Function to update the player list UI
function updatePlayerList(playersList) {
  var playerList = $(".playerList");
  playerList.empty();

  // Generating UI elements for each player in the list
  $.each(playersList, function (index, playerData) {
    var newRow =
      $(`<button class="row" onclick="openPlayerActionList(${playerData.id})">
    <svg width="40px" height="40px" viewBox="0 0 24 24" version="1.1"
        xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <!-- SVG content -->
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

// Function to request player data when a player is selected
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

// Function to open the player action menu
function openPlayerActionMenu(data) {
  selectedPlayer = data.id;
  $(".playerList").fadeOut();
  setTimeout(() => {
    $(".playerAction").fadeIn();

    // Updating player information in the action menu
    $("#playerName").text(data.name);
    $("#playerId").text(data.id);
    $("#armourCount").text(data.armour);
    $("#heartCount").text(data.health);
  }, 500);
}
// Function to close the player action menu and display the player list
function closePlayerActionMenu() {
  $(".playerAction").fadeOut();
  setTimeout(() => {
    $(".playerList").fadeIn();
  }, 500);
}

// Function to perform an action on the target player and close the UI
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

// Function to perform a server-side action and close the UI
function doOnServer(actionName) {
  if (actionName) {
    $.post(`https://FIREAC/${actionName}`);
    closeUI();
  }
}

// Function to teleport to the waypoint and close the UI
function teleportToWaypoint() {
  $.post(`https://FIREAC/teleportToWaypoint`);
  closeUI();
}

// Function to teleport to specified coordinates and close the UI
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

// Function to change vision view and close the UI
function changeVisionView(visionType) {
  if (visionType) {
    $.post(`https://FIREAC/${visionType}`);
    closeUI();
  }
}

// Function to spawn a vehicle for self and close the UI
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

// Function to spawn a vehicle for others and close the UI
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

// Function to unban a selected player and close the UI, then open the ban list menu
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

// Function to update the ban list UI
function updateBanList(bannedPlayers) {
  var banlist = $(".banlist-menu .mainbar");
  banlist.empty();

  // Generating UI elements for each banned player in the list
  $.each(bannedPlayers, function (index, banData) {
    var newRow = $(`<button onclick="unbanSelectedPlayer(${banData.BANID})">
    <svg width="34px" height="34px" viewBox="0 0 24 24" version="1.1"
        xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <!-- SVG content -->
    </svg>
    <span class="banid">#${banData.BANID}</span>
    <span class="reason">${banData.REASON}</span>
</button>`);
    banlist.append(newRow);
  });
}

// Function to remove a selected admin and close the UI, then open the admin list menu
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

// Function to update the admin list UI
function updateAdminList(adminList) {
  var adminlist = $(".adminlist-menu .mainbar");
  adminlist.empty();

  // Generating UI elements for each admin in the list
  $.each(adminList, function (index, adminData) {
    var newRow = $(`<button onclick="removeSelectedAdmin(${adminData.id})">
    <svg width="34px" height="34px" viewBox="0 0 24 24" version="1.1"
        xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <!-- SVG content -->
    </svg>
    <span class="identifier">${adminData.identifier}</span>
</button>`);
    adminlist.append(newRow);
  });
}

// Function to remove unban access and close the UI, then open the unban list menu
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

// Function to update the unban access list UI
function updateUnbanAccess(unbanAccessList) {
  var unbanAcess = $(".ubAccess-menu .mainbar");
  unbanAcess.empty();

  // Generating UI elements for each unban access data in the list
  $.each(unbanAccessList, function (index, unbanAccessData) {
    var newRow = $(`<button onclick="removeUnbanAccess(${unbanAccessData.id})">
      <svg width="34px" height="34px" viewBox="0 0 24 24" version="1.1"
          xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
          <!-- SVG content -->
      </svg>
      <span class="identifier">${unbanAccessData.identifier}</span>
  </button>`);
    unbanAcess.append(newRow);
  });
}

// Function to remove a whitelisted user and close the UI, then open the whitelist menu
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

// Function to update the whitelist UI
function updateWhiteList(whiteLists) {
  var whiteList = $(".wlusers-menu .mainbar");
  whiteList.empty();

  // Generating UI elements for each whitelisted user in the list
  $.each(whiteLists, function (index, whiteListData) {
    var newRow = $(`<button onclick="removeWhitelistUser(${whiteListData.id})">
      <svg width="34px" height="34px" viewBox="0 0 24 24" version="1.1"
          xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
          <!-- SVG content -->
      </svg>
      <span class="identifier">${whiteListData.identifier}</span>
  </button>`);
    whiteList.append(newRow);
  });
}

// Event listener for the 'Esc' key to close the UI
$(document).keydown(function (e) {
  if (e.keyCode == 27) {
    closeUI();
  }
});
