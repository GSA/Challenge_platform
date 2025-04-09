import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "body", "emailError", "bodyError"]

  handleSubmit(event) {    
    if (this.validateForm()) {
      this.submitForm()
    }
  }

  validateForm() {
    this.clearErrorMessages()
    
    const isEmailValid = this.validateEmail()
    const isBodyValid = this.validateBody()
    
    return isEmailValid && isBodyValid
  }

  clearErrorMessages() {
    this.emailErrorTarget.textContent = ""
    this.bodyErrorTarget.textContent = ""
  }

  validateEmail() {
    if (!this.emailTarget.value || !this.emailTarget.checkValidity()) {
      this.showError(this.emailErrorTarget, "Please enter a valid email address")
      return false
    }
    
    this.hideError(this.emailErrorTarget)
    return true
  }

  validateBody() {
    if (this.bodyTarget.value.length <= 2) {
      this.showError(this.bodyErrorTarget, "Your question or comment must be greater than 2 characters")
      return false
    }
    
    this.hideError(this.bodyErrorTarget)
    return true
  }

  showError(errorElement, message) {
    errorElement.textContent = message
    errorElement.classList.remove('display-none')
  }

  hideError(errorElement) {
    errorElement.classList.add('display-none')
  }

  async submitForm() {
    const form = this.element.querySelector('form')
    const formData = new FormData(form)

    try {
      const response = await fetch(form.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      if (response.ok) {
        form.reset()
      } else {
        const errors = await response.json()
        this.displayErrors(errors)
      }
    } catch (error) {
      console.error('An error occurred:', error)
    }
  }

  displayErrors(errors) {
    if (errors.email) {
      this.showError(this.emailErrorTarget, errors.email[0])
    }
    if (errors.body) {
      this.showError(this.bodyErrorTarget, errors.body[0])
    }
  }
}
