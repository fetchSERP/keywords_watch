import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.sortRows()
    document.addEventListener("turbo:before-stream-render", this.handleStream.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.handleStream.bind(this))
  }

  handleStream(event) {
    // Wait for Turbo to update the DOM, then sort
    setTimeout(() => this.sortRows(), 10)
  }

  sortRows() {
    const rows = Array.from(this.element.querySelectorAll("tr"))
    rows.sort((a, b) => {
      const aRank = parseInt(a.querySelector("[data-keyword-rank]")?.dataset.keywordRank || "", 10)
      const bRank = parseInt(b.querySelector("[data-keyword-rank]")?.dataset.keywordRank || "", 10)
  
      // Handle NaN (e.g. when dataset is empty or invalid)
      const safeARank = isNaN(aRank) ? Infinity : aRank
      const safeBRank = isNaN(bRank) ? Infinity : bRank
  
      return safeARank - safeBRank
    })
  
    rows.forEach(row => this.element.appendChild(row))
  }
}
