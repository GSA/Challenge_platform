document.addEventListener("DOMContentLoaded", () => {
  const modalTriggers = document.querySelectorAll("[data-modal]");

  modalTriggers.forEach((trigger) => {
    trigger.addEventListener("click", (e) => {
      console.log(e);
      e.preventDefault();

      modalId = trigger.dataset.modal;
      modal = document.getElementById(modalId);

      if (modal) {
        const confirmButton = modal.querySelector("#modal-btn-confirm");
        if (confirmButton) {
          confirmButton.onclick = () => {
            modal.close();
            return true;
          };
        }

        const cancelButton = modal.querySelector("#modal-btn-cancel");
        if (cancelButton) {
          cancelButton.onclick = () => {
            modal.close();
            return false;
          };
        }

        modal.showModal();
      }
    });
  });
});
