import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal"];
  static values = {
    modalId: String,
  };

  open(event) {
    const modalId = event.currentTarget.dataset.modalTargetId;
    const modal = this.modalTargets.find((modal) => modal.id === modalId);

    event.preventDefault();

    if (modal) {
      modal.showModal();
    } else {
      console.error(`Modal with ID '${modalId}' not found.`);
    }
  }

  confirm(event) {
    const modal = this._getModal(event);

    if (modal) {
      const confirmRedirect = modal.dataset.modalConfirmRedirect;

      if (confirmRedirect) {
        window.location.href = confirmRedirect;
      } else {
        modal.close();
        return true;
      }
    }
  }

  cancel(event) {
    const modal = this._getModal(event);

    if (modal) {
      const cancelRedirect = modal.dataset.modalCancelRedirect;

      if (cancelRedirect) {
        window.location.href = cancelRedirect;
      } else {
        modal.close();
        return false;
      }
    }
  }

  _getModal(event) {
    return event.currentTarget.closest("dialog");
  }
}
