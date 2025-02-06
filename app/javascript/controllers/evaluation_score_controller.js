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

    if (!criterionElement) return;

    const points = this.getPoints(criterionElement);
    const scoreValue = this.getScoreValue(input, criterionElement, points);
    this.updateCalculatedScore(criterionElement, scoreValue);

    this.dispatch("scoreUpdated");
  }

  getInputValue(event) {
    const input = event.target || event;
    if (input.type === "radio") {
      return this.getCheckedRadioValue();
    }
    return parseFloat(input.value) || 0;
  }

  getCheckedRadioValue() {
    const checkedRadio = this.element.querySelector(
      'input[type="radio"]:checked'
    );
    return checkedRadio ? parseFloat(checkedRadio.value) : 0;
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
}
