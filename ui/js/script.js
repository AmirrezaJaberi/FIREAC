function openUrl(url) {
  window.invokeNative("openUrl", url);
}

function closeUI() {
  $("#main-ui").fadeOut();
}

function openUI() {
  $("#main-ui").fadeIn();
}

function openAdminToolMenu() {
  setTimeout(() => {
    $("#admin-menu").fadeIn();
    $("#title").text("Admin Tool");
  }, 500);

  closeMainMenu();
}

function openPlayersMenu() {
  setTimeout(() => {
    $("#player-menu").fadeIn();
    $("#title").text("Player List Menu");
  }, 500);

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

function closeMainMenu() {
  $("#main-menu").fadeOut();
}

function backToMainMenu() {
  $("#admin-menu").fadeOut();
  $("#player-menu").fadeOut();
  $("#server-menu").fadeOut();
  $("#teleport-menu").fadeOut();

  setTimeout(() => {
    $("#main-menu").fadeIn();
    $("#title").text("Admin Menu");
  }, 500);
}

function doAction(actionName) {
  $.post(`https://FIREAC/${actionName}`);
}

function openPlayerActionList() {}

$(document).keydown(function (e) {
  if (e.keyCode == 27) {
    closeUI();
  }
});
