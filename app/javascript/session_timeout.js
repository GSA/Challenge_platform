import { formatMilliseconds } from "./time_helpers";

document.addEventListener("DOMContentLoaded", function () {
  var sessionStartTime = Date.now();

  const sessionTimeoutMinutes = window.appConfig.sessionTimeoutMinutes;
  const warningTimeoutMinutes = 2;
  const sessionTimeoutMs = sessionTimeoutMinutes * 60 * 1000;
  const warningTimeoutMs =
    (sessionTimeoutMinutes - warningTimeoutMinutes) * 60 * 1000;
  // Debug overrides
  // const sessionTimeoutMs = 20000;
  // const warningTimeoutMs = 5000;

  const renewalModal = document.getElementById("renew-modal");
  const countdownDiv = document.querySelector("#renew-modal .countdown");
  countdownDiv.textContent = formatMilliseconds(warningTimeoutMs);

  const activityRenewalInterval = 1000;
  var doRenewSession = false;

  const showTimeoutWarning = () => {
    renewalModal.showModal();
  };

  const updateCountdown = () => {
    var timeRemaining = sessionTimeoutMs - (Date.now() - sessionStartTime);
    countdownDiv.textContent = formatMilliseconds(timeRemaining);
  };

  const logoutSession = () => {
    fetch("/sessions/timeout", {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
        "Content-Type": "application/json",
      },
    }).then((response) => {
      if (response.ok) {
        window.location.href = "/";
      }
    });
  };

  const handleUserActivity = (event) => {
    // Don't count the modal showing and hiding as user activity
    renewalModal.close();

    doRenewSession = true;
  };

  document.addEventListener("click", handleUserActivity);
  document.addEventListener("keydown", handleUserActivity);
  document.addEventListener("scroll", handleUserActivity);

  setInterval(() => {
    if (doRenewSession) {
      renewSession();
    }
  }, activityRenewalInterval);

  document
    .getElementById("extend-session-button")
    .addEventListener("click", () => {
      renewSession();
    });

  var renewSession = () => {
    fetch("/sessions/renew", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    }).then((response) => {
      if (response.ok) {
        clearTimeout(timeoutWarning);
        clearTimeout(sessionTimeout);

        sessionStartTime = Date.now();

        timeoutWarning = setTimeout(() => {
          showTimeoutWarning();
        }, warningTimeoutMs);

        sessionTimeout = setTimeout(() => {
          logoutSession();
        }, sessionTimeoutMs);

        doRenewSession = false;
      }
    });
  };

  var timeoutWarning = setTimeout(() => {
    showTimeoutWarning();
  }, warningTimeoutMs);

  var sessionTimeout = setTimeout(() => {
    logoutSession();
  }, sessionTimeoutMs);

  var countdownInterval;

  var startCountdown = () => {
    clearInterval(countdownInterval);
    countdownInterval = setInterval(updateCountdown, 1000);
  };

  startCountdown();
});
