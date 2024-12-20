import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submission-details"
export default class extends Controller {
  static targets = ["judgingStatusHidden", "eligibleCheckbox", "winnerCheckbox"];
  
  eligibleCheck(e) {
    if (e.target.checked) {
      this.judgingStatusHiddenTarget.value = "selected"
      this.winnerCheckboxTarget.disabled = false
    } else {
      this.judgingStatusHiddenTarget.value = "not_selected"
      this.winnerCheckboxTarget.disabled = true
    }
  }

  selectedCheck(e) {
    if (e.target.checked) {
      this.judgingStatusHiddenTarget.value = "winner"
      this.eligibleCheckboxTarget.disabled = true
    } else {
      this.judgingStatusHiddenTarget.value = "selected"
      this.eligibleCheckboxTarget.disabled = false
    }
  }
}
