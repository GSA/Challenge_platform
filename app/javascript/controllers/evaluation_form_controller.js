import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="evaluation-form"
export default class extends Controller {
  static targets = ["challengeID", "challengePhase", "startDate"];

  connect() {
    console.log("connected")
  }

  handleChallengeSelect(e) {
    let id, phase, end_date
    [id, phase, end_date] = e.target.value.split(".")
    this.challengeIDTarget.value = id
    this.challengePhaseTarget.value = phase
    this.startDateTarget.innerHTML = end_date || "mm/dd/yyyy"
  }

  validatePresence(e) {
    if (!e.target.value) {
      console.log("error must be present")
    }
  }
}
