import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hotdog"
export default class extends Controller {
  static targets = ["rightPane", "leftPane", "hotdogCollapse", "hotdogExpand", "burgerCollapse", "burgerExpand", "burgerCollapsible", "evaluationForm"];

  connect() {
    this.moveEvaluationForm();

    this.resizeHandler = this.moveEvaluationForm.bind(this);
    window.addEventListener('resize', this.resizeHandler);
  }

  disconnect() {
    window.removeEventListener('resize', this.resizeHandler);
  }

  moveEvaluationForm() {
    const evaluationFormContent = document.getElementById('evaluation-form-container');
    const mobileContainer = document.getElementById('mobile-evaluation-form');
    const desktopContainer = document.getElementById('desktop-evaluation-form');
    
    const breakpoint = 640; // tablet breakpoint
    const isMobile = window.innerWidth < breakpoint;
    const isDesktop = window.innerWidth >= breakpoint;
    
    if (isMobile && evaluationFormContent.parentElement !== mobileContainer) {
      mobileContainer.appendChild(evaluationFormContent);
    } else if (isDesktop && evaluationFormContent.parentElement !== desktopContainer) {
      desktopContainer.appendChild(evaluationFormContent);
    }
  }

  hotdogCollapse(e) {
    this.rightPaneTarget.classList.add("display-none")
    this.hotdogCollapseTarget.classList.add("display-none")
    this.hotdogExpandTarget.classList.remove("display-none")
    this.leftPaneTarget.classList.add("width-full")
    this.leftPaneTarget.classList.remove("width-half")
  }

  hotdogExpand(e) {
    this.rightPaneTarget.classList.remove("display-none")
    this.hotdogCollapseTarget.classList.remove("display-none")
    this.hotdogExpandTarget.classList.add("display-none")
    this.leftPaneTarget.classList.remove("width-full")
    this.leftPaneTarget.classList.add("width-half")
  }

  burgerCollapse(e) {
    this.burgerCollapsibleTarget.classList.add("display-none")
    this.burgerCollapseTarget.classList.add("display-none")
    this.burgerExpandTarget.classList.remove("display-none")
  }

  burgerExpand(e) {
    this.burgerCollapsibleTarget.classList.remove("display-none")
    this.burgerCollapseTarget.classList.remove("display-none")
    this.burgerExpandTarget.classList.add("display-none")
  }
}
