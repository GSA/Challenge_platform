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
    const input = event.target || event;
    let scoreValue = 0;

    if (input.type === "radio") {
      const checkedRadio = this.element.querySelector(
        'input[type="radio"]:checked'
      );
      scoreValue = checkedRadio ? parseFloat(checkedRadio.value) : 0;
    } else {
      scoreValue = parseFloat(input.value) || 0;
    }

    const criterionElement = this.element.closest("[data-criterion]");
    if (!criterionElement) return;

    const points = parseFloat(criterionElement.dataset.points) || 0;
    const scoringType = criterionElement.dataset.scoringType;
    let calculatedScore = 0;

    switch (scoringType) {
      case "binary":
        calculatedScore = scoreValue === 1 ? points : 0;
        break;
      case "numeric":
        calculatedScore = Math.min(scoreValue, points);
        break;
      case "rating":
        const bestOption =
          parseFloat(criterionElement.dataset.optionRangeEnd) || 1;
        calculatedScore = (points / bestOption) * scoreValue;
        break;
      default:
        calculatedScore = 0;
    }

    calculatedScore = Math.round(calculatedScore * 100) / 100;

    const scoreSpan = criterionElement.querySelector(".calculated-score");
    if (scoreSpan) {
      scoreSpan.textContent = calculatedScore;
    }

    // Dispatch an action for evaluation controller to recalculate total score
    this.dispatch("scoreUpdated");
  }
}
