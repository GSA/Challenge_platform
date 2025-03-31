import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["scoreInput", "calculatedScore"];

  connect() {
    this.updateScore();
  }

  updateScore() {
    this.calculateScore(this.scoreInputTarget);
  }

  calculateScore(event) {
    const input = this.getInputValue(event);
    const criterionElement = this.getCriterionElement();

    var scoreValue;

    if (!criterionElement) return;

    if (input === null) {
      scoreValue = "__";
    } else {
      const points = this.getPoints(criterionElement);
      scoreValue = this.getScoreValue(input, criterionElement, points);
    }

    this.updateCalculatedScore(criterionElement, scoreValue);

    this.setRadioScoreClass(event);

    this.dispatch("scoreUpdated");
  }

  getInputValue(event) {
    const input = event.target || event;
    if (input.type === "radio") {
      return this.getCheckedRadioValue();
    }
    return input.value.trim() === "" ? null : parseFloat(input.value);
  }

  getCheckedRadioValue() {
    const checkedRadio = this.element.querySelector(
      'input[type="radio"]:checked'
    );
    return checkedRadio ? parseFloat(checkedRadio.value) : null;
  }

  getCriterionElement() {
    return this.element.closest("[data-criterion]");
  }

  getPoints(criterionElement) {
    return parseFloat(criterionElement.dataset.points) || 0;
  }

  getScoreValue(input, criterionElement, points) {
    const scoringType = criterionElement.dataset.scoringType;
    let scoreValue = input;

    switch (scoringType) {
      case "binary":
        scoreValue = input === 1 ? points : 0;
        break;
      case "numeric":
        scoreValue = Math.min(input, points);
        break;
      case "rating":
        const bestOption =
          parseFloat(criterionElement.dataset.optionRangeEnd) || 1;
        scoreValue = (points / bestOption) * input;
        break;
      default:
        scoreValue = 0;
    }

    return Math.round(scoreValue * 100) / 100;
  }

  updateCalculatedScore(criterionElement, scoreValue) {
    const scoreSpan = criterionElement.querySelector(".calculated-score");
    if (scoreSpan) {
      scoreSpan.textContent = scoreValue;
    }
  }

  setRadioScoreClass(event) {
    if (!event || !event.target) return; // Prevent error on page load

    const radio = event.target;
    const fieldset = radio.closest(".usa-fieldset"); // Scope to the fieldset
    if (!fieldset) return;

    const allScoreValues = fieldset.querySelectorAll(".radio-score-value"); // Get only in fieldset
    const container = radio.closest(".usa-radio");
    const scoreValue = container?.querySelector(".radio-score-value");

    // Reset all within the fieldset to bg-base
    allScoreValues.forEach((el) => el.classList.remove("bg-primary"));
    allScoreValues.forEach((el) => el.classList.add("bg-base-dark"));

    // Set clicked one to bg-primary
    if (scoreValue) {
      scoreValue.classList.remove("bg-base-dark");
      scoreValue.classList.add("bg-primary");
    }
  }
}
