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
    const order = this.element.dataset.sortingOrder
    const sortBy = this.element.dataset.sortingItem

    if (order === "asc") {
      rows.sort((a, b) => {
        const aRank = parseInt(a.querySelector("[data-sorting-item]")?.dataset.sortingItem || "", 10)
        const bRank = parseInt(b.querySelector("[data-sorting-item]")?.dataset.sortingItem || "", 10)

        return aRank - bRank
      })
    } else {
      rows.sort((a, b) => {
        const aRank = parseInt(a.querySelector("[data-sorting-item]")?.dataset.sortingItem || "", 10)
        const bRank = parseInt(b.querySelector("[data-sorting-item]")?.dataset.sortingItem || "", 10)

        return bRank - aRank
      })
    }

    rows.forEach(row => this.element.appendChild(row))
  }
}
