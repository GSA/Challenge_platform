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
      this.updateErrorMessage(
        fieldName,
        this.generateErrorMessage(fieldName, target)
      );
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

  generateErrorMessage(field_name, target) {
    const normalizedFieldName =
      field_name.charAt(0).toUpperCase() + field_name.slice(1).toLowerCase();
    const fieldLabel = target.dataset.fieldLabel || normalizedFieldName;
    const { tagName, type } = target;

    switch (tagName) {
      case "SELECT":
      case "INPUT":
        return type === "radio"
          ? `Select ${fieldLabel}`
          : `Provide ${fieldLabel}`;
      case "TEXTAREA":
        return `Provide ${fieldLabel}`;
      default:
        return `Provide ${fieldLabel}`;
    }
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
    const errorElement = document.getElementById(field + "_error");
    if (errorElement) {
      errorElement.innerHTML = message;
    }
  }
  
  clearForm(e) {
    e.preventDefault();
    const form = e.target.closest('form');

    form.reset();
    
    form.querySelectorAll('input[type="text"], input[type="email"]').forEach(input => {
      input.value = '';
    });
    
    this.clearAllErrors(form);
  }
  
  clearAllErrors(form) {
    const errorAlert = form.querySelector('.usa-alert--error');
    if (errorAlert) {
      errorAlert.remove();
    }
  
    const formGroups = form.querySelectorAll('.usa-form-group');
    formGroups.forEach(group => {
      const input = group.querySelector('input, textarea, select');
      if (input) {
        input.className = input.className.replace(/usa-input--error/g, '');
        
        const label = this.findLabel(input, group);
        if (label) {
          label.className = label.className.replace(/usa-label--error/g, '');
        }
        
        this.removeErrorClasses(input, label);
  
        const errorSpan = group.querySelector('[id$="_error"]');
        if (errorSpan) {
          errorSpan.textContent = '';
        }
      }
    });
  }
}
