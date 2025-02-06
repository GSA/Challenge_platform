import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["calculatedScore", "totalScore"];

  connect() {
    this.updateTotalScore();
  }

  updateTotalScore() {
    let totalScore = 0;

    this.calculatedScoreTargets.forEach((span) => {
      totalScore += parseFloat(span.textContent) || 0;
    });

    if (this.hasTotalScoreTarget) {
      this.totalScoreTarget.textContent = totalScore.toFixed(2);
    }
  }
}
