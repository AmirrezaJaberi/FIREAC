let playerCoords = null;

$(function () {
  window.addEventListener("message", function (event) {
    if (event.data.action == "openUI") {
      openUI();
    } else if (event.data.action == "updateAdminStatus") {
      updateAdminData(event.data.godmode, event.data.visible);
    } else if (event.data.action == "updatePlayerCoords") {
      updateAdminCoords(event.data.location);
    } else if (event.data.action == "updatePlayerList") {
      updatePlayerList(event.data.playerList);
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

  closeMainMenu();
}

function openAdminListMenu() {
  setTimeout(() => {
    $("#adminlist-menu").fadeIn();
    $("#title").text("Admin List");
  }, 500);

  closeMainMenu();
}

function openUnbanListMenu() {
  setTimeout(() => {
    $("#ubAccess-menu").fadeIn();
    $("#title").text("Admin List");
  }, 500);

  closeMainMenu();
}

function openWhitelistMenu() {
  setTimeout(() => {
    $("#wlusers-menu").fadeIn();
    $("#title").text("Admin List");
  }, 500);

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

function updateAdminData(godmode, visible) {
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

function openPlayerActionList(id) {}

function teleportToWaypoint() {}
function teleportToCoords() {}

function removeSelectedAdmin() {}
function unbanSelectedPlayer() {}
function removeUnbanAccess() {}
function removeWhitelistUser() {}

$(document).keydown(function (e) {
  if (e.keyCode == 27) {
    closeUI();
  }
});
