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
      const sourceDomain = row.querySelector("[data-backlink-source-domain]")?.textContent.toLowerCase() || ""
      const targetUrl = row.querySelector("[data-backlink-target-url]")?.textContent.toLowerCase() || ""
      
      const shouldShow = sourceDomain.includes(searchTerm) || targetUrl.includes(searchTerm)
      row.classList.toggle("hidden", !shouldShow)
    })
  }

  // Clear the search
  clear() {
    this.inputTarget.value = ""
    this.filter()
  }
} 