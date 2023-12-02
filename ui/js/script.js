function openUrl(url) {
  window.invokeNative("openUrl", url);
}

function closeUI() {
  $("#main-ui").fadeOut();
}

function openUI() {
  $("#main-ui").fadeIn();
}

$(document).keydown(function (e) {
  if (e.keyCode == 27) {
    closeUI();
  }
});
