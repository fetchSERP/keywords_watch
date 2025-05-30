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
    const rows = Array.from(this.element.querySelectorAll("tr"));
    const order = this.element.querySelector("[data-sorting-order]")?.dataset.sortingOrder || "asc";
  
    rows.sort((a, b) => {
      const aAttr = a.querySelector("[data-sorting-item]")?.dataset.sortingItem;
      const bAttr = b.querySelector("[data-sorting-item]")?.dataset.sortingItem;
  
      const aRank = parseInt(aAttr, 10);
      const bRank = parseInt(bAttr, 10);
  
      const aIsNaN = isNaN(aRank);
      const bIsNaN = isNaN(bRank);
  
      if (aIsNaN && bIsNaN) return 0;
      if (aIsNaN) return 1; // move a to end
      if (bIsNaN) return -1; // move b to end
  
      return order === "asc" ? aRank - bRank : bRank - aRank;
    });
  
    rows.forEach(row => this.element.appendChild(row));
  }
}
