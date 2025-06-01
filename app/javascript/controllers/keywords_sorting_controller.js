import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.sortRows()

    // keep a bound reference so we can remove it cleanly
    this.boundHandleStream = this.handleStream.bind(this)
    document.addEventListener("turbo:before-stream-render", this.boundHandleStream)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.boundHandleStream)
  }

  // re-sort after Turbo streams mutate the DOM
  handleStream() {
    setTimeout(() => this.sortRows(), 10)
  }

  sortRows() {
    const rows  = Array.from(this.element.querySelectorAll("tr"))
    let order = this.element.querySelector("[data-sorting-order]")?.dataset.sortingOrder || "asc"

    rows.sort((a, b) => {
      // ---------- field #1 : is_tracked ----------
      const aTracked = parseInt(a.querySelector("[data-sorting-field-one]")?.dataset.sortingFieldOne || "0", 10)
      const bTracked = parseInt(b.querySelector("[data-sorting-field-one]")?.dataset.sortingFieldOne || "0", 10)
      if (aTracked !== bTracked) return bTracked - aTracked      // true (1) first

      // ---------- field #2 : rank ----------
      const aRank  = this.parseNumber(a.querySelector("[data-sorting-field-two]")?.dataset.sortingFieldTwo)
      const bRank  = this.parseNumber(b.querySelector("[data-sorting-field-two]")?.dataset.sortingFieldTwo)
      order = "asc"
      if (aRank !== bRank) return order === "asc" ? aRank - bRank : bRank - aRank

      // ---------- field #3 : score / note ----------
      const aScore = this.parseNumber(a.querySelector("[data-sorting-field-three]")?.dataset.sortingFieldThree)
      const bScore = this.parseNumber(b.querySelector("[data-sorting-field-three]")?.dataset.sortingFieldThree)
      order = "desc"
      return order === "asc" ? aScore - bScore : bScore - aScore
    })

    // re-insert rows in the new order
    rows.forEach(row => this.element.appendChild(row))
  }

  // helper: converts undefined / NaN to Infinity so “missing” values sort last
  parseNumber(value) {
    const num = parseFloat(value)
    return isNaN(num) ? Infinity : num
  }
}