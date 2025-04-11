import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "body", "emailError", "bodyError"]

  handleSubmit(event) {    
    event.preventDefault()
    
    if (this.validateForm()) {
      event.target.submit()
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
}
