import { Controller } from "@hotwired/stimulus";

export default class SearchController extends Controller {
  static targets = ["input", "queryResults", "queryText", "courseCount", "resultsContainer"];

  connect() {
    console.log("Search controller connected!");
    this.timeout = null;
  }

  search(event) {
    console.log("Searching...");
    clearTimeout(this.timeout);
    
    // Find the closest form element
    const form = event.target.closest('form');
    
    this.timeout = setTimeout(() => {
      if (form) {
        form.requestSubmit();
      }
    }, 300);
    
    this.updateQueryResults(event);
  }

  updateQueryResults(event) {
    const query = event.target.value.trim();
    
    if (query.length > 0) {
      this.queryResultsTarget.classList.remove('d-none');
      
      fetch(`/courses/search?query=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(data => {
          this.displaySearchResults(data.courses);
        });
    } else {
      this.queryResultsTarget.classList.add('d-none');
      if (this.hasResultsContainerTarget) {
        this.resultsContainerTarget.innerHTML = '';
      }
    }
  }

  displaySearchResults(courses) {
    if (!this.hasResultsContainerTarget) return;

    const resultsHtml = courses.map(([id, name]) => `
      <div class="p-2 border-bottom course-result" 
           data-course-id="${id}"
           data-action="click->search#selectCourse">
        ${name}
      </div>
    `).join('');
    
    this.resultsContainerTarget.innerHTML = resultsHtml;
  }

  selectCourse(event) {
    const selectedName = event.currentTarget.textContent.trim();
    this.inputTarget.value = selectedName;
    this.queryResultsTarget.classList.add('d-none');
    
    // Submit the form with the selected course
    const form = this.element.closest('form');
    if (form) {
      form.requestSubmit();
    }
  }
}
 