import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["copyButton", "modal", "button", "content", "menu", "section"]
  static values = {
    url: String,
    title: String,
    description: String
  }

  connect() {
    window.addEventListener('hashchange', () => this.showActiveSection())
    this.showActiveSection()
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
    const url = this.urlValue
    const title = this.titleValue
    const description = this.descriptionValue
    
    switch(type) {
      case 'facebook':
        const fbUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`
        window.open(fbUrl, '_blank', 'noopener,noreferrer')
        break

      case 'linkedin':
        const linkedinText = `${title}\n\n${description}\n${url}`
        const linkedinUrl = `https://www.linkedin.com/feed/?shareActive=true&text=${encodeURIComponent(linkedinText)}`
        window.open(linkedinUrl, '_blank', 'noopener,noreferrer')
        break

      case 'twitter':
        const twitterParams = new URLSearchParams({
          url: url,
          text: title,
          via: 'ChallengeGov',
          hashtags: 'prizechallenge,innovation'
        })
        window.open(`https://twitter.com/intent/tweet?${twitterParams}`, '_blank', 'noopener,noreferrer')
        break

      case 'email':
        const subject = encodeURIComponent("Sharing a challenge from Challenge.Gov!")
        const body = encodeURIComponent(`Check out this challenge: ${url}`)
        window.location.href = `mailto:?subject=${subject}&body=${body}`
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