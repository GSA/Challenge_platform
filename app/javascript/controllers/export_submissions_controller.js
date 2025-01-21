import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    phaseId: String,
    challengeTitle: String,
    phaseNumber: String
  }

  connect() {
    this.modalTarget.addEventListener('click', this.handleOutsideClick.bind(this));
  }

  disconnect() {
    this.modalTarget.removeEventListener('click', this.handleOutsideClick.bind(this));
  }

  open(event) {
    event.preventDefault();
    this.phaseIdValue = event.currentTarget.dataset.phaseId;
    this.challengeTitleValue = event.currentTarget.dataset.challengeTitle;
    this.phaseNumberValue = event.currentTarget.dataset.phaseNumber;
    this.modalTarget.showModal();
  }

  close() {
    this.modalTarget.close();
  }

  handleOutsideClick = (event) => {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }

  async exportSubmissions(event) {
    event.preventDefault();
  
    const selectedOptions = Array.from(
      document.querySelectorAll('input[name="export-options"]:checked')
    ).map(checkbox => checkbox.value);
  
    if (selectedOptions.length === 0) {
      alert('Please select at least one export option');
      return;
    }
  
    try {
      for (const option of selectedOptions) {
        const params = new URLSearchParams({
          options: option,
          format: 'csv'
        });
        
        const response = await fetch(`/phases/${this.phaseIdValue}/export_submissions?${params}`, {
          method: 'GET',
          headers: {
            'Accept': 'text/csv',
            'X-Requested-With': 'XMLHttpRequest'
          }
        });
        
        if (!response.ok) throw new Error('Export failed');
        
        const blob = await response.blob();
        const title = `${this.challengeTitleValue} - Phase ${this.phaseNumberValue}`;
        const sanitizedTitle = title.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
        
        const filename = `${sanitizedTitle}_${option}_${new Date().toISOString().split('T')[0]}.csv`;
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      }
      
      this.close();
    } catch (error) {
      console.error('Export failed:', error);
      alert('Export failed. Please try again.');
    }
  }
}
