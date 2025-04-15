import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  focus(event) {
    const targetId = event.currentTarget.getAttribute("href").slice(1);
    const el = document.getElementById(targetId);

    if (!el) return;

    el.focus();
  }
}
