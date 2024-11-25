import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "confirmButton"]
  static values = {
    phaseId: String,
    assignmentId: String
  }

  connect() {
    this.modalTarget.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    this.modalTarget.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  open(event) {
    event.preventDefault();
    this.setValues(event.currentTarget.dataset);
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

  setValues(dataset) {
    this.assignmentIdValue = dataset.assignmentId;
    this.phaseIdValue = dataset.phaseId;
  }

  unassignEvaluatorSubmission() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    
    fetch(`/phases/${this.phaseIdValue}/evaluator_submission_assignments/${this.assignmentIdValue}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        status: 'unassigned'
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const evaluatorId = new URLSearchParams(window.location.search).get('evaluator_id');
        window.location.href = `/phases/${this.phaseIdValue}/evaluator_submission_assignments?evaluator_id=${evaluatorId}`;
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
