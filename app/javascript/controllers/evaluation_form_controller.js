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
    const weightedScale = e.target.value == "true";

    // Check if any input has a value over 100
    const hasValuesOver100 = Array.from(pointsWeights).some(
      (input) => parseInt(input.value.trim()) > 100
    );

    // Display confirmation dialog if switching to weighted and any point inputs have a value
    if (weightedScale && hasValuesOver100) {
      const confirmed = window.confirm(
        "You have values over 100. Changing the scale type to weighted will reset your weight values"
      );
      if (!confirmed) {
        e.preventDefault();
        return;
      }

      pointsWeights.forEach((input) => (input.value = ""));
    }

    if (e.target.id == "weighted_scale") {
      pointsWeights.forEach((input) => (input.max = "100"));
    } else {
      pointsWeights.forEach((input) => (input.max = "9999"));
    }

    const accordionButtons = form.querySelectorAll(".usa-accordion__button");
    accordionButtons.forEach((accordionButton) =>
      accordionButton.setAttribute("aria-expanded", true)
    );

    const accordions = form.querySelectorAll(".usa-accordion__content");
    accordions.forEach((accordion) => accordion.removeAttribute("hidden"));
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
