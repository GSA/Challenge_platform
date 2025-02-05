import ModalController from "./modal_controller"

export default class extends ModalController {
  static values = {
    assignmentId: String,
    submissionId: String,
    evaluationId: String
  }

  open(event) {
    event.preventDefault()
    this.assignmentIdValue = event.currentTarget.dataset.assignmentId
    this.submissionIdValue = event.currentTarget.dataset.submissionId
    this.evaluationIdValue = event.currentTarget.dataset.evaluationId
    this.modalTarget.showModal()
  }

  evaluatorRecusal(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const recusalPath = this.evaluationIdValue ? 
      `/evaluations/${this.evaluationIdValue}/recuse` : 
      `/submissions/${this.submissionIdValue}/evaluations/recuse`
    
    fetch(recusalPath, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        evaluation_id: this.evaluationIdValue,
        submission_id: this.submissionIdValue,
        evaluator_submission_assignment: {
          id: this.assignmentIdValue,
          status: 'recused'
        }
      })
    })
    .then(response => {
      if (response.redirected) {
        window.location.href = response.url
      } else {
        throw new Error('Failed to recuse from evaluation')
      }
    })
    .catch(() => {
      alert('Failed to recuse from evaluation')
    })
    
    this.cancel(event)
  }
}
