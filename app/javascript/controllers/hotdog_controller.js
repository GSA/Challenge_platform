import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hotdog"
export default class extends Controller {
  static targets = ["rightPane", "leftPane", "hotdogCollapse", "hotdogExpand", "burgerCollapse", "burgerExpand", "burgerCollapsible"];

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
