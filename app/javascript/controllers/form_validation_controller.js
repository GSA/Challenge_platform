import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="form-validation"
export default class extends Controller {
  validatePresence(e) {
    const target = e.target;
    const formGroup = target.closest(".usa-form-group");
    const fieldName = target.dataset.fieldName || target.id;
    const label = this.findLabel(target, formGroup);

    if (!target.value) {
      this.addErrorClasses(target, label);
      this.updateErrorMessage(fieldName, "can't be blank");
    } else {
      this.removeErrorClasses(target, label);
      this.updateErrorMessage(fieldName, "");
    }
  }

  findLabel(target, formGroup) {
    const isSelect =
      target.tagName === "SELECT" ||
      target.classList.contains("usa-combo-box__input");
    const isRadio = target.type === "radio";

    const labelId = isSelect ? target.name : target.id;
    const labelQuery = isRadio ? "legend" : `label[for="${labelId}"]`;

    return formGroup.querySelector(labelQuery);
  }

  addErrorClasses(target, label) {
    target.classList.add("border-secondary");
    if (label) label.classList.add("text-secondary");
  }

  removeErrorClasses(target, label) {
    target.classList.remove("border-secondary");
    if (label) label.classList.remove("text-secondary");
  }

  updateErrorMessage(field, message) {
    console.log(field);
    const errorElement = document.getElementById(field + "_error");
    if (errorElement) {
      errorElement.innerHTML = message;
    }
  }
}
