import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    assignmentId: String
  }

  connect() {
    this.modalTarget.addEventListener('click', this.handleOutsideClick.bind(this));
  }

  disconnect() {
    this.modalTarget.removeEventListener('click', this.handleOutsideClick.bind(this));
  }

  open(event) {
    event.preventDefault();
    this.assignmentIdValue = event.currentTarget.dataset.assignmentId;
    this.modalTarget.showModal();
  }

  close() {
    this.modalTarget.close();
  }

  handleOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }

  evaluatorRecusal() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const pathMatch = window.location.pathname.match(/\/submissions\/(\d+)\/evaluations\/(\d+)/);
  
    const [_, submissionId, evaluationId] = pathMatch;
  
    fetch(`/submissions/${submissionId}/evaluations/${evaluationId}/recuse`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        submission_id: submissionId
      })
    })
    .then(response => {
      if (response.redirected) {
        window.location.href = response.url;
      } else {
        throw new Error('Failed to recuse from evaluation');
      }
    })
    .catch(() => {
      alert('Failed to recuse from evaluation');
    });
    
    this.close();
  }
}
