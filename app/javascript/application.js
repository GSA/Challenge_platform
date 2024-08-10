document.addEventListener("DOMContentLoaded", function () {
  var sessionTimeoutMinutes = window.appConfig.sessionTimeoutMinutes;
  var sessionTimeoutMs = sessionTimeoutMinutes * 60 * 1000;
  var warningTimeoutMs = (sessionTimeoutMinutes - 2) * 60 * 1000;

  function showTimeoutWarning() {
    document.getElementById("renew-modal-button").click();
  }

  document
    .getElementById("extend-session-button")
    .addEventListener("click", function () {
      renewSession();
    });

  function renewSession() {
    fetch("/sessions/renew", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    }).then(function (response) {
      if (response.ok) {
        document.getElementById("renew-modal").style.display = "none";
        clearTimeout(timeoutWarning);
        timeoutWarning = setTimeout(showTimeoutWarning, warningTimeoutMs);
      }
    });
  }

  var timeoutWarning = setTimeout(() => {
    showTimeoutWarning();
  }, warningTimeoutMs);
});
