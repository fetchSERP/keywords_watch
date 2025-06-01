// app/javascript/controllers/submit_on_change_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  submitOnChange(event) {
    event.target.form.requestSubmit()
  }
}