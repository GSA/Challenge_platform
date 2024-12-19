import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submission-details"
export default class extends Controller {
  
  eligibleCheck(e) {
    const hiddenInput = e.target.form.elements["judging-status-hidden"]
    const winnerCheckbox = e.target.form.elements[3]
    if (e.target.checked) {
      hiddenInput.value = "selected"
      winnerCheckbox.disabled = false
    } else {
      hiddenInput.value = "qualified"
      winnerCheckbox.disabled = true
    }
  }

  selectedCheck(e) {
    const hiddenInput = e.target.form.elements["judging-status-hidden"]
    const eligibleCheckbox = e.target.form.elements[2]
    if (e.target.checked) {
      hiddenInput.value = "winner"
      eligibleCheckbox.disabled = true
    } else {
      hiddenInput.value = "selected"
      eligibleCheckbox.disabled = false
    }
  }
}
