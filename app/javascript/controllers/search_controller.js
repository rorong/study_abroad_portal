import { Controller } from "@hotwired/stimulus";

export default class SearchController extends Controller {
  static targets = ["input", "queryResults", "queryText", "courseCount", "resultsContainer", "form", 
                    "minDuration", "maxDuration", "durationSlider",
                    "minApplicationFee", "maxApplicationFee", "applicationFeeSlider",
                    "minInternship", "maxInternship", "internshipSlider",
                    "minWorldRanking", "maxWorldRanking", "worldRankingSlider",
                    "minQsRanking", "maxQsRanking", "qsRankingSlider",
                    "minNationalRanking", "maxNationalRanking", "nationalRankingSlider"];

  connect() {
    console.log("Search controller connected!");
    this.timeout = null;
    this.searchTimeout = null;
    
    // Add click outside listener only if queryResults target exists
    if (this.hasQueryResultsTarget) {
      document.addEventListener('click', (event) => {
        if (!this.element.contains(event.target)) {
          this.queryResultsTarget.classList.add('d-none');
        }
      });
    }

    // Initialize all sliders
    this.initializeSliders();
  }

  initializeSliders() {
    // Initialize duration slider if it exists
    if (this.hasDurationSliderTarget) {
      this.initializeDurationSlider();
    }

    // Initialize application fee slider if it exists
    if (this.hasApplicationFeeSliderTarget) {
      this.initializeApplicationFeeSlider();
    }

    // Initialize internship slider if it exists
    if (this.hasInternshipSliderTarget) {
      this.initializeInternshipSlider();
    }

    // Initialize world ranking slider if it exists
    if (this.hasWorldRankingSliderTarget) {
      this.initializeWorldRankingSlider();
    }

    // Initialize QS ranking slider if it exists
    if (this.hasQsRankingSliderTarget) {
      this.initializeQsRankingSlider();
    }

    // Initialize national ranking slider if it exists
    if (this.hasNationalRankingSliderTarget) {
      this.initializeNationalRankingSlider();
    }
  }

  initializeDurationSlider() {
    const slider = this.durationSliderTarget;
    const minInput = this.minDurationTarget;
    const maxInput = this.maxDurationTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeApplicationFeeSlider() {
    const slider = this.applicationFeeSliderTarget;
    const minInput = this.minApplicationFeeTarget;
    const maxInput = this.maxApplicationFeeTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeInternshipSlider() {
    const slider = this.internshipSliderTarget;
    const minInput = this.minInternshipTarget;
    const maxInput = this.maxInternshipTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeWorldRankingSlider() {
    const slider = this.worldRankingSliderTarget;
    const minInput = this.minWorldRankingTarget;
    const maxInput = this.maxWorldRankingTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeQsRankingSlider() {
    const slider = this.qsRankingSliderTarget;
    const minInput = this.minQsRankingTarget;
    const maxInput = this.maxQsRankingTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  initializeNationalRankingSlider() {
    const slider = this.nationalRankingSliderTarget;
    const minInput = this.minNationalRankingTarget;
    const maxInput = this.maxNationalRankingTarget;

    // Set initial values
    if (minInput.value) {
      slider.min = minInput.value;
    }
    if (maxInput.value) {
      slider.value = maxInput.value;
    }
  }

  updateDurationInputs(event) {
    const slider = event.target;
    const maxInput = this.maxDurationTarget;
    const minInput = this.minDurationTarget;

    // Update max duration input with slider value
    maxInput.value = slider.value;
    
    // If min duration is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateApplicationFeeInputs(event) {
    const slider = event.target;
    const maxInput = this.maxApplicationFeeTarget;
    const minInput = this.minApplicationFeeTarget;

    // Update max application fee input with slider value
    maxInput.value = slider.value;
    
    // If min application fee is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateInternshipInputs(event) {
    const slider = event.target;
    const maxInput = this.maxInternshipTarget;
    const minInput = this.minInternshipTarget;

    // Update max internship input with slider value
    maxInput.value = slider.value;
    
    // If min internship is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateWorldRankingInputs(event) {
    const slider = event.target;
    const maxInput = this.maxWorldRankingTarget;
    const minInput = this.minWorldRankingTarget;

    // Update max world ranking input with slider value
    maxInput.value = slider.value;
    
    // If min world ranking is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateQsRankingInputs(event) {
    const slider = event.target;
    const maxInput = this.maxQsRankingTarget;
    const minInput = this.minQsRankingTarget;

    // Update max QS ranking input with slider value
    maxInput.value = slider.value;
    
    // If min QS ranking is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  updateNationalRankingInputs(event) {
    const slider = event.target;
    const maxInput = this.maxNationalRankingTarget;
    const minInput = this.minNationalRankingTarget;

    // Update max national ranking input with slider value
    maxInput.value = slider.value;
    
    // If min national ranking is greater than max, update min to match max
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    // Trigger search
    this.search(event);
  }

  search(event) {
    console.log("Searching...");
    clearTimeout(this.timeout);
    // Find the closest form element
    const form = event.target.closest('form');
    // Always update query results for search input if target exists
    if (event.target.matches('[data-search-target="input"]') && this.hasQueryResultsTarget) {
      this.updateQueryResults(event);
    }
    // Set timeout for form submission
    this.timeout = setTimeout(() => {
      if (form) {
        Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
      }
    }, 300);
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
    if (this.hasInputTarget) {
      this.inputTarget.value = selectedName;
    }
    if (this.hasQueryResultsTarget) {
      this.queryResultsTarget.classList.add('d-none');
    }
    // Submit the form with the selected course
    const form = this.element;
    if (form) {
      Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
    }
  }

  performSearch(event) {
    event.preventDefault();
    const query = this.inputTarget.value.trim();
    if (query.length > 0) {
      // Find the closest form element
      const form = this.element;
      // Submit the form with the search query
      Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
    }
  }

  clear(event) {
    event.preventDefault();
    // Clear the search input if it exists
    if (this.hasInputTarget) {
      this.inputTarget.value = '';
    } 
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
    Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
  }
}
 