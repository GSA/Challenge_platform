import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="evaluation-form"
export default class extends Controller {
  static targets = ["challengeID", "phaseID", "startDate", "datePicker"];

  handleChallengeSelect(e) {
    let id, phase_id, end_date;
    [id, phase_id, end_date] = e.target.value.split(".");
    if (id) {
      // set values of hidden form fields
      this.challengeIDTarget.value = id;
      this.phaseIDTarget.value = phase_id;

      // set the start date of the evaluation form
      // to be the challenge's end date
      this.startDateTarget.innerHTML = end_date || "mm/dd/yyyy";
      let day, month, year;
      [month, day, year] = end_date.split("/");
      this.datePickerTarget.setAttribute(
        "data-min-date",
        `${year}-${month}-${day}`
      );
    } else {
      this.challengeIDTarget.value = null;
      this.phaseIDTarget.value = null;

      this.startDateTarget.innerHTML = "mm/dd/yyyy";
    }
  }

  // Opens all accordions, remove existing points/weights, update max points/weights values
  updateMaxPoints(e) {
    const form = e.target.closest(
      'form[data-controller="evaluation-form modal"]'
    );
    const pointsWeights = form.querySelectorAll(".points-or-weight");
    const weightedScale = e.target.value === "true";

    if (weightedScale && this.hasValuesOverLimit(pointsWeights, 100)) {
      this.expandAllAccordions(form);
    }

    this.updateMaxValues(pointsWeights, weightedScale ? 100 : 9999);
  }

  // Helper: Check if any input values exceed a given limit
  hasValuesOverLimit(inputs, limit) {
    return Array.from(inputs).some(
      (input) => parseInt(input.value.trim()) > limit
    );
  }

  // Helper: Update max values for inputs
  updateMaxValues(inputs, maxValue) {
    inputs.forEach((input) => (input.max = maxValue));
    Array.from(inputs).every((input) => {
      input.reportValidity();
    });
  }

  // Helper: Expand all accordions
  expandAllAccordions(form) {
    const accordionButtons = form.querySelectorAll(".usa-accordion__button");
    const accordions = form.querySelectorAll(".usa-accordion__content");

    accordionButtons.forEach((button) =>
      button.setAttribute("aria-expanded", true)
    );
    accordions.forEach((content) => content.removeAttribute("hidden"));
  }

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
    document.getElementById(field + "_error").innerHTML = message;
  }
}
