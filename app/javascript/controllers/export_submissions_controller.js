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

  async exportSubmissions(event) {
    event.preventDefault();
    const options = this.getSelectedOptions();
    
    if (options.length === 0) {
      alert('Please select at least one export option');
      return;
    }
  
    try {
      await this.downloadAll(options);
      this.close();
    } catch (error) {
      console.error('Export failed:', error);
      alert('Export failed. Please try again.');
    }
  }
  
  async downloadAll(options) {
    for (const option of options) {
      const response = await this.requestFile(option);
      
      if (!response.ok && response.status !== 303) {
        throw new Error('Export failed');
      }
  
      await this.saveFile(response, option);
    }
  }
  
  async requestFile(option) {
    const params = new URLSearchParams({
      options: option,
      filename: this.createFilename(option)
    });
  
    return fetch(
      `/phases/${this.phaseIdValue}/export_submissions?${params}`,
      { 
        method: 'GET',
        headers: { 
          'Accept': option === 'attachments' ? 'application/json' : 'text/csv',
          'X-Requested-With': 'XMLHttpRequest' 
        }
      }
    );
  }
  
  async saveFile(response, option) {
    if (option === 'attachments') {
      const { redirect_url } = await response.json();
      if (!redirect_url) throw new Error('No redirect URL provided');
      
      this.createLink(redirect_url, { newTab: true });
      return;
    }
  
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    this.createLink(url, { download: this.createFilename(option) });
    window.URL.revokeObjectURL(url);
  }
  
  createLink(url, options = {}) {
    const a = document.createElement('a');
    a.href = url;
    
    if (options.newTab) {
      a.target = '_blank';
      a.rel = 'noopener noreferrer';
    } else {
      a.download = options.download;
    }
  
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }
}
