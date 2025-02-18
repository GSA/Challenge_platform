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

    totalScore = parseFloat((Math.round(totalScore * 100) / 100).toFixed(2));

    if (this.hasTotalScoreTarget) {
      this.totalScoreTarget.textContent = totalScore;
    }
  }
}
