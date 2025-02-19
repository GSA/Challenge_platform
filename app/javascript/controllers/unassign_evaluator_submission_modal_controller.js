import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    phaseId: String,
    assignmentId: String
  }

  open(event) {
    event.preventDefault();
    this.setValues(event.currentTarget.dataset);
    this.modalTarget.showModal();
  }

  close() {
    this.modalTarget.close();
  }

  setValues(dataset) {
    this.assignmentIdValue = dataset.assignmentId;
    this.phaseIdValue = dataset.phaseId;
  }

  unassignEvaluatorSubmission() {
    const button = document.querySelector(`[data-assignment-id='${this.assignmentIdValue}']`);
    const newStatus = button?.dataset.currentStatus === 'recused' ? 'recused_unassigned' : 'unassigned';
  
    fetch(`/phases/${this.phaseIdValue}/evaluator_submission_assignments/${this.assignmentIdValue}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        evaluator_submission_assignment: { status: newStatus }
      })
    })
    .then(response => {
      if (response.redirected) {
        window.location.assign(response.url);
        return null;
      }
      return response.json();
    })
    .then(data => {
      if (!data) return;
      if (!data.success) {
        throw new Error(data.message || 'Failed to unassign evaluator from submission');
      }
      if (data.redirect_url) {
        window.location.assign(data.redirect_url);
      } else {
        const evaluatorId = new URLSearchParams(window.location.search).get('evaluator_id');
        window.location.assign(`/phases/${this.phaseIdValue}/evaluator_submission_assignments?evaluator_id=${evaluatorId}`);
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert(error.message || 'An error occurred while unassigning the evaluator from the submission');
    });
  }
}
