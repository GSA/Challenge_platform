import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hotdog"
export default class extends Controller {
  static targets = ["rightPane", "collapseBar", "leftPane", "expandBar"];

  handleCollapse(e) {
    this.rightPaneTarget.classList.add("display-none")
    this.collapseBarTarget.classList.add("display-none")
    this.expandBarTarget.classList.remove("display-none")
    this.leftPaneTarget.classList.add("width-full")
    this.leftPaneTarget.classList.remove("width-half")
  }

  handleExpand(e) {
    this.rightPaneTarget.classList.remove("display-none")
    this.collapseBarTarget.classList.remove("display-none")
    this.expandBarTarget.classList.add("display-none")
    this.leftPaneTarget.classList.remove("width-full")
    this.leftPaneTarget.classList.add("width-half")
  }
}
