import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "loadMoreButton"]
  static values = { 
    page: Number,
    totalCount: Number
  }

  connect() {
    this.pageValue = 1
    this.checkHasMoreSubmissions()
  }

  async loadMore() {
    this.pageValue++
    
    try {
      const url = new URL(window.location.href)
      url.searchParams.set('page', this.pageValue)
      url.searchParams.set('partial', 'true')
      
      const response = await fetch(url, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      if (!response.ok) throw new Error('Network response was not ok')
      
      const html = await response.text()
      this.containerTarget.insertAdjacentHTML('beforeend', html)
      this.checkHasMoreSubmissions()
    } catch (error) {
      console.error("Error loading more submissions:", error)
    }
  }

  checkHasMoreSubmissions() {
    const rows = this.containerTarget.querySelectorAll('tr')
    if (rows.length >= this.totalCountValue) {
      this.loadMoreButtonTarget.classList.add('display-none')
    }
  }
}
