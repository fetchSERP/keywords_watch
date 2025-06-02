import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "row"]
  static values = {
    searchTerm: String
  }

  connect() {
    // Initialize with empty search
    this.searchTermValue = ""
  }

  // Called when the search input changes
  filter() {
    const searchTerm = this.inputTarget.value.toLowerCase()
    this.searchTermValue = searchTerm

    this.rowTargets.forEach(row => {
      const domainName = row.querySelector("[data-competitor-domain]")?.textContent.toLowerCase() || ""
      const keywords = Array.from(row.querySelectorAll("[data-competitor-keyword]"))
        .map(el => el.textContent.toLowerCase())
        .join(" ")
      
      const shouldShow = domainName.includes(searchTerm) || keywords.includes(searchTerm)
      row.classList.toggle("hidden", !shouldShow)
    })
  }

  // Clear the search
  clear() {
    this.inputTarget.value = ""
    this.filter()
  }
}