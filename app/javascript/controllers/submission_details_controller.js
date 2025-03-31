import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submission-details"
export default class extends Controller {
  static targets = ["judgingStatusHidden", "eligibleCheckbox", "winnerCheckbox", "judgingStatusForm"];
  
  eligibleCheck(e) {
    if (e.target.checked) {
      this.judgingStatusHiddenTarget.value = "selected"
    } else {
      this.judgingStatusHiddenTarget.value = "not_selected"
    }
    this.submitForm()
  }

  selectedCheck(e) {
    if (e.target.checked) {
      this.judgingStatusHiddenTarget.value = "winner"
    } else {
      this.judgingStatusHiddenTarget.value = "selected"
    }
    this.submitForm()
  }

  submitForm(e) {
    this.judgingStatusFormTarget.submit()
  }
}


