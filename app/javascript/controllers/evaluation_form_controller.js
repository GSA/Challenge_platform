import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="evaluation-form"
export default class extends Controller {
  static targets = ["challengeID", "challengePhase"];

  connect() {
    console.log("connected")
  }

  handleChallengeSelect(e) {
    let id, phase
    [id, phase] = e.target.value.split(".")
    this.challengeIDTarget.value = id
    this.challengePhaseTarget.value = phase
  }
}
