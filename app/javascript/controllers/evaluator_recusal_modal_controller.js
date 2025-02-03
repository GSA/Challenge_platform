import ModalController from "./modal_controller"

export default class extends ModalController {
  static values = {
    assignmentId: String
  }

  open(event) {
    event.preventDefault()
    this.assignmentIdValue = event.currentTarget.dataset.assignmentId
    this.modalTarget.showModal()
  }

  evaluatorRecusal(event) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const pathMatch = window.location.pathname.match(/\/submissions\/(\d+)/)

    const [_, submissionId] = pathMatch
  
    fetch(`/submissions/${submissionId}/evaluations/new/recuse`, {
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
