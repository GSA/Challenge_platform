// app/javascript/controllers/sort_filter_menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menuItem"]

  connect() {
    this.updateCheckmarks()
  }

  toggle(event) {
    event.preventDefault()
    const clickedItem = event.currentTarget
    const filterValue = clickedItem.dataset.filterValue
    
    const currentUrl = new URL(window.location.href)
    const [param, value] = filterValue.split('=')
    
    if (currentUrl.searchParams.get(param) === value) {
      this.clearAllFilters()
    } else {
      this.applyFilter(filterValue)
    }
  }

  applyFilter(filterValue) {
    const currentUrl = new URL(window.location.href)
    const [param, value] = filterValue.split('=')
  
    this.removeExistingParams(currentUrl)
    currentUrl.searchParams.set(param, value)
    window.location.href = currentUrl.toString()
  }

  clearAllFilters() {
    const currentUrl = new URL(window.location.href)
    this.removeExistingParams(currentUrl)
    window.location.href = currentUrl.toString()
  }

  removeExistingParams(url) {
    const paramsToRemove = ['status', 'eligible_for_evaluation', 'selected_to_advance', 'sort']
    paramsToRemove.forEach(key => {
      url.searchParams.delete(key)
    })
  }

  updateCheckmarks() {
    const currentUrl = new URL(window.location.href)
    this.menuItemTargets.forEach(item => {
      const checkmark = item.querySelector('.checkmark')
      const [param, value] = item.dataset.filterValue.split('=')
      if (currentUrl.searchParams.get(param) === value) {
        checkmark.style.display = 'inline'
      } else {
        checkmark.style.display = 'none'
      }
    })
  }
}
