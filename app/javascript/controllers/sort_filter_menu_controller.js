// app/javascript/controllers/sort_filter_menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menuItem", "filterOption"]

  connect() {
    this.searchTerm = ''
    this.setInitialFilterState()
  }

  setInitialFilterState() {
    const currentUrl = new URL(window.location.href)

    this.filterOptionTargets.forEach(option => option.checked = false)

    this.filterOptionTargets.forEach(option => {
      const [param, value] = option.value.split('=')
      if (currentUrl.searchParams.get(param) === value) {
        option.checked = true

        this.filterOptionTargets.forEach(otherOption => {
          if (otherOption !== option && otherOption.checked) {
            otherOption.checked = false
          }
        })
      }
    })
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
      .join('&')

    let queryParams = selectedFilters

    if (this.searchTerm) {
      queryParams = queryParams ? 
        `${queryParams}&submission_id=${this.searchTerm}` :
        `submission_id=${this.searchTerm}`
    }

    window.location.href = `${window.location.pathname}?${queryParams}`
  }
  
  clearAllFilters() {
    if (this.hasSubmissionIdSearchTarget) {
      this.submissionIdSearchTarget.value = ''
      this.searchTerm = ''
    }
    
    this.filterOptionTargets.forEach(radio => {
      radio.checked = false
    })

    window.location.href = window.location.pathname
  }

  close() {
    const button = document.querySelector('[aria-controls="sort-and-filter"]')
    button.click()
  }
}
