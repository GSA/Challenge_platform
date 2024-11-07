import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "confirmButton"]
  static values = {
    challengeId: String,
    phaseId: String,
    submissionId: String,
    evaluatorId: String
  }

  connect() {
    this.modalTarget.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    this.modalTarget.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  open(event) {
    event.preventDefault()
    this.submissionIdValue = event.currentTarget.dataset.submissionId
    this.evaluatorIdValue = event.currentTarget.dataset.evaluatorId
    this.challengeIdValue = event.currentTarget.dataset.challengeId
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
    this.unassignEvaluatorSubmission()
  }

  unassignEvaluatorSubmission() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/challenges/${this.challengeIdValue}/phases/${this.phaseIdValue}/evaluator_submissions/${this.submissionIdValue}/unassign`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        evaluator_id: this.evaluatorIdValue
      })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      return response.json()
    })
    .then(data => {
      if (data.success) {
        this.close()
        window.location.reload()
      } else {
        throw new Error(data.message || 'Failed to unassign evaluator from submission')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert(error.message || 'An error occurred while unassigning the evaluator from the submission')
    })
  }
}
