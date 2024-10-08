import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="evaluation-form"
export default class extends Controller {
  static targets = ["challengeID", "challengePhase", "startDate"];

  handleChallengeSelect(e) {
    let id, phase, end_date
    [id, phase, end_date] = e.target.value.split(".")
    if (id) {
      // set values of hidden form fields 
      this.challengeIDTarget.value = id
      this.challengePhaseTarget.value = phase

      // set the start date of the evaluation form 
      // to be the challenge's end date
      this.startDateTarget.innerHTML = end_date || "mm/dd/yyyy"

      this.updateErrorMessage("evaluation_form_challenge_id", "")
      this.updateErrorMessage("evaluation_form_challenge_phase", "")
    } else {
      this.updateErrorMessage("evaluation_form_challenge_id", "can't be blank")
      this.startDateTarget.innerHTML = "mm/dd/yyyy"
    }
  }

  validatePresence(e) {
    if (!e.target.value) {
      e.target.classList.add("border-secondary")
      this.updateErrorMessage(e.target.id, "can't be blank")

    } else {
      e.target.classList.remove("border-secondary")
      this.updateErrorMessage(e.target.id, "")
    }
  }

  updateErrorMessage(field, message) {
    document.getElementById(field + "_error").innerHTML = message
  }
}
