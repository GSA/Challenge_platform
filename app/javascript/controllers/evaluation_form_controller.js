import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="evaluation-form"
export default class extends Controller {

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
}
