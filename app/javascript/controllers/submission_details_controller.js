import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submission-details"
export default class extends Controller {
  static targets = ["hiddenInput"]
  
  selectedSubmit(e) {
    console.log(e.target.checked)
    if (e.target.checked) {
      this.hiddenInputTarget.value = "selected"
      e.target.setAttribute('checked', true);
    } else {
      this.hiddenInputTarget.setAttribute("value", "qualified")
      e.target.setAttribute('checked', false);
    }
    console.log(this.hiddenInputTarget)
  }

  winnerSubmit(e) {
    if (e.target.checked) {
      this.hiddenInputTarget.value = "winner"
    } else {
      this.hiddenInputTarget.value = "selected"
    }
  }
}
