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

      this.updateErrorMessage("evaluation_form_challenge_id", "");
      this.updateErrorMessage("evaluation_form_phase_id", "");
    } else {
      this.updateErrorMessage("evaluation_form_challenge_id", "can't be blank");
      this.startDateTarget.innerHTML = "mm/dd/yyyy";
    }
  }

  // Opens all accordions, remove existing points/weights, update max points/weights values
  updateMaxPoints(e) {
    const form = e.target.closest('form[data-controller="evaluation-form"]');
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
    if (!e.target.value) {
      e.target.classList.add("border-secondary");
      this.updateErrorMessage(e.target.id, "can't be blank");
    } else {
      e.target.classList.remove("border-secondary");
      this.updateErrorMessage(e.target.id, "");
    }
  }

  updateErrorMessage(field, message) {
    document.getElementById(field + "_error").innerHTML = message;
  }
}
