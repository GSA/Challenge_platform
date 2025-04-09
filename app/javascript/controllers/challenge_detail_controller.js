import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["copyButton", "modal", "button", "content", "menu", "section"]

  connect() {
    window.addEventListener('hashchange', () => this.showActiveSection())
  }

  // Navbar
  showActiveSection() {
    document.querySelectorAll('.challenge-section').forEach(section => {
      section.style.display = 'none'
    })

    document.querySelectorAll('.nav.navbar-nav li').forEach(item => {
      item.classList.remove('active')
    })

    // Get the hash from URL or default to overview
    let hash = window.location.hash || '#overview'
    hash = hash.replace('#', '')

    // Show the selected section
    const activeSection = document.getElementById(hash)
    if (activeSection) {
      activeSection.style.display = 'block'
      
      activeSection.style.display = 'none'
      activeSection.offsetHeight
      activeSection.style.display = 'block'
    }

    // Add active class to current nav item
    const activeNavItem = document.querySelector(`.nav.navbar-nav li a[href$="#${hash}"]`)?.parentElement
    if (activeNavItem) {
      activeNavItem.classList.add('active')
    }
  }

  // Share social icons
  toggle(event) {
    event.preventDefault()
    this.menuTarget.classList.toggle("is-visible")
  }

  share(event) {
    event.preventDefault()
    const type = event.currentTarget.dataset.shareType
  
    switch(type) {
      case 'facebook':
        window.open('https://www.facebook.com/ChallengeGov', '_blank')
        break
      case 'twitter':
        window.open('https://www.twitter.com/ChallengeGov', '_blank')
        break
      case 'linkedin':
        window.open('https://www.linkedin.com/company/challengegov/', '_blank')
        break
      case 'email':
        window.open('https://public.govdelivery.com/accounts/USGSATTS/signup/30826', '_blank')
        break
    }
  }

  handleClickOutside = (event) => {
    if (this.hasMenuTarget && !this.element.contains(event.target)) {
      this.menuTarget.classList.remove("is-visible")
    }
  }


  // Copy URL
  copyUrl() {
    navigator.clipboard.writeText(window.location.href).then(() => {
      const button = this.copyButtonTarget;
      const originalText = button.innerHTML;
      
      button.innerHTML = `
        <img src="${this.element.dataset.checkIconUrl}" class="usa-icon usa-icon--size-3 icon-primary-orange" alt="copied">
        <span class="text-primary">Copied!</span>
      `;
      
      setTimeout(() => {
        button.innerHTML = originalText;
      }, 2000);
    }).catch((err) => {
      console.error('Failed to copy URL: ', err);
    });
  }
}