import { Controller } from "@hotwired/stimulus";

export default class SearchController extends Controller {
  static targets = ["input"];

  connect() {
    console.log("Search controller connected!");
    this.timeout = null;
  }

  search() {
    console.log("Searching...");
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 300);
  }
}
 