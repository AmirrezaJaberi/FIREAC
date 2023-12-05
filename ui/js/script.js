function openUrl(url) {
  window.invokeNative("openUrl", url);
}

function closeUI() {
  $("#main-ui").fadeOut();
}

function openUI() {
  $("#title").text("Welcome to admin menu !");

  $("#main-ui").fadeIn();
}

function openAdminToolMenu() {
  closeMainMenu();

  $("#title").text("Admin Tool");
  $("#admin-menu").fadeIn();
}

function closeMainMenu() {
  $("#main-menu").fadeOut();
}

function backToMainMenu() {
  $("#main-menu").fadeIn();

  $("#title").text("Welcome to admin menu !");

  $("#admin-menu").fadeOut();
}

$(document).keydown(function (e) {
  if (e.keyCode == 27) {
    closeUI();
  }
});
