import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    phaseId: String,
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
    this.setValues(event.currentTarget.dataset);
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

  setValues(dataset) {
    this.assignmentIdValue = dataset.assignmentId;
    this.phaseIdValue = dataset.phaseId;
  }

  exportSubmissions() {
    // TODO: export submissions
  }
}
