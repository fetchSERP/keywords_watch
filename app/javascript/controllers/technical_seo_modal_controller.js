// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.handleEscape = this.handleEscape.bind(this)
  }

  open() {
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    window.addEventListener("keydown", this.handleEscape)
  }

  close() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    window.removeEventListener("keydown", this.handleEscape)
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}