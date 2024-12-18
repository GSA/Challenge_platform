import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submission-details"
export default class extends Controller {
  
  eligibleCheck(e) {
    const hiddenInput = e.target.form.elements["judging-status-hidden"]
    if (e.target.checked) {
      hiddenInput.value = "selected"
    } else {
      hiddenInput.value = "qualified"
    }
  }

  selectedCheck(e) {
    const hiddenInput = e.target.form.elements["judging-status-hidden"]
    if (e.target.checked) {
      hiddenInput.value = "winner"
    } else {
      hiddenInput.value = "selected"
    }
  }
}
