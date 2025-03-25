import { Controller } from "@hotwired/stimulus";

export default class SearchController extends Controller {
  static targets = ["input", "queryResults", "queryText", "courseCount", "resultsContainer", "form"];

  connect() {
    console.log("Search controller connected!");
    this.timeout = null;
    this.searchTimeout = null;
    
    // Add click outside listener
    document.addEventListener('click', (event) => {
      if (!this.element.contains(event.target)) {
        this.queryResultsTarget.classList.add('d-none');
      }
    });
  }

  search(event) {
    console.log("Searching...");
    clearTimeout(this.timeout);
    
    // Find the closest form element
    const form = event.target.closest('form');
    
    // Always update query results for search input
    if (event.target.matches('[data-search-target="input"]')) {
      this.updateQueryResults(event);
    }
    
    // Set timeout for form submission
    this.timeout = setTimeout(() => {
      if (form) {
        Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
      }
    }, 2000);
  }

  clear(event) {
    event.preventDefault();
    
    // Clear the search input
    this.inputTarget.value = '';
    
    // Clear all select elements in the form
    const form = this.element;
    form.querySelectorAll('select').forEach(select => {
      select.value = '';
    });
    
    // Clear all number inputs
    form.querySelectorAll('input[type="number"]').forEach(input => {
      input.value = '';
    });
    
    // Update the URL to remove all parameters
    const baseUrl = window.location.pathname;
    window.history.pushState({}, '', baseUrl);
    
    // Submit the form to update results
    // form.requestSubmit();
    Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });

  }

  updateQueryResults(event) {
    const query = event.target.value.trim();
    console.log("Updating query results for:", query);
    
    // Clear any existing timeout
    clearTimeout(this.searchTimeout);
    
    // Set a new timeout
    this.searchTimeout = setTimeout(() => {
      if (query.length > 0) {
        console.log("Showing results container");
        this.queryResultsTarget.classList.remove('d-none');
        
        console.log("Fetching results from:", `/courses/search?query=${encodeURIComponent(query)}`);
        fetch(`/courses/search?query=${encodeURIComponent(query)}`)
          .then(response => {
            console.log("Got response:", response);
            return response.json();
          })
          .then(data => {
            console.log("Got data:", data);
            this.displaySearchResults(data.courses);
          })
          .catch(error => {
            console.error("Error fetching results:", error);
          });
      } else {
        console.log("Hiding results container");
        this.queryResultsTarget.classList.add('d-none');
        if (this.hasResultsContainerTarget) {
          this.resultsContainerTarget.innerHTML = '';
        }
      }
    }, 300); // 300ms delay before making the API call
  }

  displaySearchResults(courses) {
    console.log("Displaying search results:", courses);
    if (!this.hasResultsContainerTarget) {
      console.log("No results container target found");
      return;
    }

    const resultsHtml = courses.map(([id, name, university]) => `
      <div class="p-2 border-bottom course-result" 
          data-course-id="${id}"
          data-action="click->search#selectCourse">
        <div class="fw-bold">${name}</div>
        <div class="small text-muted">${university}</div>
      </div>
    `).join('');
    
    console.log("Generated HTML:", resultsHtml);
    this.resultsContainerTarget.innerHTML = resultsHtml;
  }

  selectCourse(event) {
    const selectedName = event.currentTarget.querySelector('.fw-bold').textContent.trim();
    this.inputTarget.value = selectedName;
    this.queryResultsTarget.classList.add('d-none');
    
    // Submit the form with the selected course
    const form = this.element;
    if (form) {
      Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
    }
  }
}
 