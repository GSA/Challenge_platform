import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["score", "evaluatorScore", "calculatedScore", "totalScore"];

  connect() {
    this.updateTotalScore();
  }

  // This is used in both evaluation and evaluation_overrides
  // evaluatorScore targets are only present in the evaluation_override
  updateTotalScore() {
    let totalScore = 0;
    let isOverride = this.hasEvaluatorScoreTarget;
    let hasRevisedScore = this.checkForRevisions();

    this.scoreTargets.forEach((score) => {
      totalScore += this.getEffectiveScore(score, isOverride);
    });

    if ((isOverride && !hasRevisedScore) || Number.isNaN(totalScore)) {
      totalScore = "__";
    } else {
      totalScore = parseFloat((Math.round(totalScore * 100) / 100).toFixed(2));
    }

    if (this.hasTotalScoreTarget) {
      this.totalScoreTarget.textContent = totalScore;
    }
  }

  checkForRevisions() {
    return this.calculatedScoreTargets.some(
      (target) => target.textContent !== "__"
    );
  }

  getEffectiveScore(score, isOverride) {
    let effectiveScore;

    if (isOverride) {
      let evaluatorScore = this.getNestedTarget(
        score,
        "evaluatorScore"
      ).textContent;
      let calculatedScore = this.getNestedTarget(
        score,
        "calculatedScore"
      ).textContent;

      if (calculatedScore !== "__") {
        effectiveScore = calculatedScore;
      } else {
        effectiveScore = evaluatorScore;
      }
    } else {
      effectiveScore = this.getNestedTarget(
        score,
        "calculatedScore"
      ).textContent;
    }

    return parseFloat(effectiveScore);
  }

  getNestedTarget(parentTarget, childTargetName) {
    return parentTarget.querySelector(
      `[data-${this.identifier}-target="${childTargetName}"]`
    );
  }
}
