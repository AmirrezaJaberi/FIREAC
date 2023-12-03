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
  closeMainMenu();

  $("#admin-menu").fadeIn();
}

function closeMainMenu() {
  $("#main-menu").fadeOut();
}

function backToMainMenu() {
  $("#main-menu").fadeIn();

  $("#admin-menu").fadeOut();
}

$(document).keydown(function (e) {
  if (e.keyCode == 27) {
    closeUI();
  }
});
