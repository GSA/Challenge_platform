import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  focus(event) {
    event.preventDefault();

    const targetId = event.currentTarget.dataset.targetId;
    let el = document.getElementById(targetId);

    if (!el) {
      console.log("Inside", `[data-field-name="${targetId}"]`);
      el = document.querySelector(`[data-field-name="${targetId}"]`);
    }

    if (!el) return;

    el.scrollIntoView({ behavior: "smooth", block: "center" });
    el.focus({ preventScroll: true }); // for accessibility
  }
}
