// app/javascript/controllers/sort_filter_menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["filterOption", "submissionIdSearch"]

  connect() {
    this.searchTerm = ''
    this.setInitialFilterState()
  }

  setInitialFilterState() {
    const currentUrl = new URL(window.location.href)

    this.filterOptionTargets.forEach(option => {
      const [param, value] = option.value.split('=')
      if (currentUrl.searchParams.get(param) === value) {
        option.checked = true

        // only one radio button checked at a time
        this.filterOptionTargets.forEach(otherOption => {
          if (otherOption !== option && otherOption.checked) {
            otherOption.checked = false
          }
        })
      }
    })

    // preserve submission id in search input field when page loads/refreshes
    if (this.hasSubmissionIdSearchTarget && currentUrl.searchParams.has('submission_id')) {
      const submissionId = currentUrl.searchParams.get('submission_id')
      this.submissionIdSearchTarget.value = submissionId
      this.searchTerm = submissionId
    }    
  }

  handleSearchInput(event) {
    this.searchTerm = event.target.value.trim()
  }

  handleRadioChange(event) {
    const clickedRadio = event.target

    this.filterOptionTargets.forEach(radio => {
      if (radio !== clickedRadio) {
        radio.checked = false
      }
    })
  }

  applyFilters() {
    const selectedFilters = this.filterOptionTargets
      .filter(radio => radio.checked)
      .map(radio => radio.value)

    let queryParams = selectedFilters

    if (this.searchTerm) {
      queryParams = queryParams ? 
        `${queryParams}&submission_id=${this.searchTerm}` :
        `submission_id=${this.searchTerm}`
    }

    window.location.href = `${window.location.pathname}?${queryParams}`
  }
  
  clearAllFilters(event) {
    if (event) {
      event.preventDefault()
    }
    
    if (this.hasSubmissionIdSearchTarget) {
      this.submissionIdSearchTarget.value = ''
      this.searchTerm = ''
    }
    
    this.filterOptionTargets.forEach(radio => {
      radio.checked = false
    })

    window.location.replace(window.location.pathname)
  }

  close() {
    const button = document.querySelector('[aria-controls="sort-and-filter"]')
    button.click()
  }
}
