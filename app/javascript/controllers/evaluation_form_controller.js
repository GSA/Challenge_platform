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
    this.validatePresence(e)
  }

  validatePresence(e) {
    if (!e.target.value) {
      e.target.classList.add("border-secondary")
      document.getElementById(e.target.id + "_error").innerHTML = "can't be blank"
    } else {
      e.target.classList.remove("border-secondary")
      document.getElementById(e.target.id + "_error").innerHTML = ""
    }
  }
}
