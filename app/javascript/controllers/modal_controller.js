import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal"];
  static values = {
    modalId: String,
  };

  open(event) {
    const modalId = event.currentTarget.dataset.modalTargetId;
    const modal = this.modalTargets.find((modal) => modal.id === modalId);

    this.openEvent = event;

    event.preventDefault();

    if (modal) {
      modal.showModal();
    } else {
      console.warn(`Modal with ID '${modalId}' not found.`);
    }
  }

  confirm(event) {
    const modal = this._getModal(event);

    if (modal) {
      const confirmRedirect = modal.dataset.modalConfirmRedirect;
      const confirmAction = modal.dataset.modalConfirmAction;

      if (confirmRedirect) {
        window.location.href = confirmRedirect;
      } else if (confirmAction) {
        if (confirmAction === "submit") {
          const form = modal.closest("form");
          if (form) {
            form.submit();
          }
        } else {
          this.invokeAction(confirmAction);
        }
        modal.close();
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
      const cancelAction = modal.dataset.modalCancelAction;

      if (cancelRedirect) {
        window.location.href = cancelRedirect;
      } else if (cancelAction) {
        this.invokeAction(cancelAction);
        modal.close();
      } else {
        modal.close();
        return false;
      }
    }
  }

  _getModal(event) {
    return event.currentTarget.closest("dialog");
  }

  invokeAction(actionName) {
    const [controllerName, action] = actionName.split("#");
    const controllerElement = document.querySelector(
      `[data-controller~="${controllerName}"]`
    );

    if (!controllerElement) {
      console.warn(`Controller element for ${controllerName} not found.`);
    }

    const controller = this.application.getControllerForElementAndIdentifier(
      controllerElement,
      controllerName
    );

    if (controller && typeof controller[action] === "function") {
      controller[action](this.openEvent);
    } else {
      console.warn(`Action ${actionName} not found on ${controllerName}`);
    }
  }
}
