import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submission-details"
export default class extends Controller {
  static targets = ["qualifiedForm", "selectedForm"]
  
  selectedSubmit(e) {
    if (e.target.checked) {
      e.target.form.submit()
    } else {
      this.qualifiedFormTarget.submit()
    }
  }

  winnerSubmit(e) {
    if (e.target.checked) {
      e.target.form.submit()
    } else {
      this.selectedFormTarget.submit()
    }
  }
}
