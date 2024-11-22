import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "confirmButton"]
  static values = {
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
    event.preventDefault();
    this.submissionIdValue = event.currentTarget.dataset.submissionId;
    this.evaluatorIdValue = event.currentTarget.dataset.evaluatorId;
    this.phaseIdValue = event.currentTarget.dataset.phaseId;
    this.modalTarget.showModal();
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
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    
    fetch(`/phases/${this.phaseIdValue}/evaluator_submission_assignments?evaluator_id=${this.evaluatorIdValue}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        submission_id: this.submissionIdValue,
        status: 'unassigned'
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        window.location.href = `/phases/${this.phaseIdValue}/evaluator_submission_assignments?evaluator_id=${this.evaluatorIdValue}`;
      } else {
        throw new Error(data.message || 'Failed to unassign evaluator from submission');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert(error.message || 'An error occurred while unassigning the evaluator from the submission');
    });
  }
}
