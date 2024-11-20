import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    challengeId: String,
    evaluatorId: String,
    evaluatorType: String,
    phaseId: String
  }

  connect() {
    this.modalTarget.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    this.modalTarget.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  open(event) {
    event.preventDefault()
    this.evaluatorIdValue = event.currentTarget.dataset.evaluatorId
    this.evaluatorTypeValue = event.currentTarget.dataset.evaluatorType
    this.phaseIdValue = event.currentTarget.dataset.phaseId
    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }

  handleOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  confirm() {
    this.deleteEvaluator()
  }

  deleteEvaluator(forceDelete = false) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
  
    fetch(`/phases/${this.phaseIdValue}/evaluators/${this.evaluatorIdValue}`, {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken },
      body: JSON.stringify({ evaluator_type: this.evaluatorTypeValue, phase_id: this.phaseIdValue, force_delete: forceDelete })
    })
    .then(response => {
      if (!response.ok) { throw new Error('Network response was not ok') }
      return response.json()
    })
    .then(data => {
      if (data.success) {
        this.close()
        window.location.reload()
      } else {
        throw new Error(data.message || 'Failed to remove evaluator')
      }
    })
    .catch(error => { alert(error.message || 'An error occurred while removing the evaluator') })
  }
}
