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

function closeMainMenu() {
  $("#main-menu").fadeOut();
}

function backToMainMenu() {
  $("#admin-menu").fadeOut();
  $("#player-menu").fadeOut();

  setTimeout(() => {
    $("#main-menu").fadeIn();
    $("#title").text("Admin Menu");
  }, 500);
}

function doAction(actionName) {
  $.post(`https://FIREAC/${actionName}`);
}

$(document).keydown(function (e) {
  if (e.keyCode == 27) {
    closeUI();
  }
});
