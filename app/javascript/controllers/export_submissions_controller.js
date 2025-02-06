import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    phaseId: String,
    challengeTitle: String,
    phaseNumber: String
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

  getSelectedOptions() {
    return Array.from(
      document.querySelectorAll('input[name="export-options"]:checked')
    ).map(checkbox => checkbox.value);
  }

  createFilename(option) {
    const title = `${this.challengeTitleValue} - Phase ${this.phaseNumberValue}`;
    const sanitizedTitle = title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '_')
      .replace(/^_|_$/g, '');
    
    return `${sanitizedTitle}_${option}_${new Date().toISOString().split('T')[0]}.csv`;
  }

  async downloadFile(option) {
    const params = new URLSearchParams({ 
      options: option,
      filename: this.createFilename(option)
    });
  
    const response = await fetch(
      `/phases/${this.phaseIdValue}/export_submissions?${params}`,
      { 
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      }
    );
  
    if (!response.ok && response.status !== 303) {
      throw new Error('Export failed');
    }
  
    if (option === 'attachments') {
      return { redirect_url: response.headers.get('Location') };
    }

    const a = document.createElement('a');
    a.href = `/phases/${this.phaseIdValue}/export_submissions.csv?${params}`;
    a.download = this.createFilename(option);
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  async exportSubmissions(event) {
    event.preventDefault();
    const selectedOptions = this.getSelectedOptions();
  
    if (selectedOptions.length === 0) {
      alert('Please select at least one export option');
      return;
    }
  
    try {
      const csvOptions = selectedOptions.filter(option => option !== 'attachments');
      for (const option of csvOptions) {
        await this.downloadFile(option);
      }
  
      if (selectedOptions.includes('attachments')) {
        const result = await this.downloadFile('attachments');
        window.open(result.redirect_url, '_blank');
      }
  
      this.close();
    } catch (error) {
      console.error('Export failed:', error);
      alert('Export failed. Please try again.');
    }
  }
}