import Rails from "@rails/ujs";
window.Rails = Rails
Rails.start()
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "output"];
  static values = { url: String };

  handleChange(event) {
    console.log("!")
    Rails.ajax({
      url: this.urlValue,
      type: "POST",
      data: new FormData(this.formTarget),
      success: (data) => {
        this.outputTarget.innerHTML = data;
      },
    });
  }
}