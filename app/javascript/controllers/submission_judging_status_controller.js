// app/javascript/controllers/submission_judging_status_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["eligibilityForm", "advancementForm", "eligibilityCheckbox", "advancementCheckbox"]

  toggleEligibility(event) {
    event.preventDefault()
    const formData = new FormData(this.eligibilityFormTarget)
    formData.set('submission[judging_status]', 
      event.target.checked ? 'selected' : 'not_selected'
    )
    this.submitForm(formData, this.eligibilityFormTarget)
  }

  toggleAdvancement(event) {
    event.preventDefault()
    const formData = new FormData(this.advancementFormTarget)
    formData.set('submission[judging_status]', 
      event.target.checked ? 'winner' : 'selected'
    )
    
    if (event.target.checked) {
      this.eligibilityCheckboxTarget.checked = true
    }
    this.submitForm(formData, this.advancementFormTarget)
  }

  submitForm(formData, form) {
    const csrfToken = document.querySelector('[name="csrf-token"]').content

    fetch(form.action, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: formData
    })
    .catch(() => {
      const checkbox = form.querySelector('input[type="checkbox"]')
      checkbox.checked = !checkbox.checked
    })
  }
}
