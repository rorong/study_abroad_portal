import { Controller } from "@hotwired/stimulus";

export default class SearchController extends Controller {
  static targets = ["input", "queryResults", "queryText", "courseCount", "resultsContainer", "form", 
                    "minDuration", "maxDuration", "durationSlider",
                    "minApplicationFee", "maxApplicationFee", "applicationFeeSlider",
                    "minInternship", "maxInternship", "internshipSlider",
                    "minWorldRanking", "maxWorldRanking", "worldRankingSlider",
                    "minQsRanking", "maxQsRanking", "qsRankingSlider",
                    "minNationalRanking", "maxNationalRanking", "nationalRankingSlider",
                    "minTuitionFee", "maxTuitionFee", "tuitionFeeSlider",
                    "addressInput", "latitude", "longitude", "addressError"];

  connect() {
    this.timeout = null;
    this.searchTimeout = null;
    this.autocomplete = null;
    this.debounceTime = 300;
    
    // Add click outside listener only if queryResults target exists
    if (this.hasQueryResultsTarget) {
      document.addEventListener('click', this.handleClickOutside.bind(this));
    }

    // Initialize all sliders
    this.initializeSliders();

    // Initialize Google Places Autocomplete if address input exists
    if (this.hasAddressInputTarget) {
      this.initializeGooglePlaces();
    }
  }

  disconnect() {
    if (this.hasQueryResultsTarget) {
      document.removeEventListener('click', this.handleClickOutside.bind(this));
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.queryResultsTarget.classList.add('d-none');
    }
  }

  initializeSliders() {
    const sliderConfigs = [
      { target: 'duration', min: 'minDuration', max: 'maxDuration' },
      { target: 'applicationFee', min: 'minApplicationFee', max: 'maxApplicationFee' },
      { target: 'internship', min: 'minInternship', max: 'maxInternship' },
      { target: 'worldRanking', min: 'minWorldRanking', max: 'maxWorldRanking' },
      { target: 'qsRanking', min: 'minQsRanking', max: 'maxQsRanking' },
      { target: 'nationalRanking', min: 'minNationalRanking', max: 'maxNationalRanking' },
      { target: 'tuitionFee', min: 'minTuitionFee', max: 'maxTuitionFee' }
    ];

    sliderConfigs.forEach(config => {
      const sliderTarget = this[`${config.target}SliderTarget`];
      if (sliderTarget) {
        const minInput = this[`${config.min}Target`];
        const maxInput = this[`${config.max}Target`];

        if (minInput?.value) {
          sliderTarget.min = minInput.value;
        }
        if (maxInput?.value) {
          sliderTarget.value = maxInput.value;
        }
      }
    });
  }

  initializeGooglePlaces() {
    const initPlaces = () => {
      try {
        if (!window.google?.maps?.places) {
          this.showAddressError('Google Places API is not available');
          return;
        }

        const input = this.addressInputTarget;
        this.autocomplete = new google.maps.places.Autocomplete(input, {
          types: ['address']
        });

        this.autocomplete.addListener('place_changed', () => {
          const place = this.autocomplete.getPlace();
          
          if (place.geometry) {
            this.latitudeTarget.value = place.geometry.location.lat();
            this.longitudeTarget.value = place.geometry.location.lng();
            this.addressInputTarget.value = place.formatted_address;
            this.clearAddressError();
            this.search({ target: input });
          } else {
            this.showAddressError('Selected location is not valid');
          }
        });

        const pacContainer = document.querySelector('.pac-container');
        if (pacContainer) {
          pacContainer.style.zIndex = '1050';
        }
      } catch (error) {
        console.error('Error initializing Google Places:', error);
        this.showAddressError('Error initializing address search');
      }
    };

    if (window.google?.maps) {
      initPlaces();
    } else {
      window.addEventListener('google-maps-loaded', initPlaces);
    }
  }

  showAddressError(message) {
    const errorElement = this.addressErrorTarget;
    if (errorElement) {
      errorElement.textContent = message;
      errorElement.style.display = 'block';
    }
  }

  clearAddressError() {
    const errorElement = this.addressErrorTarget;
    if (errorElement) {
      errorElement.style.display = 'none';
    }
  }

  updateSliderInputs(event, type) {
    const slider = event.target;
    const maxInput = this[`max${type}Target`];
    const minInput = this[`min${type}Target`];

    maxInput.value = slider.value;
    
    if (parseInt(minInput.value) > parseInt(maxInput.value)) {
      minInput.value = maxInput.value;
    }

    this.search(event);
  }

  updateDurationInputs(event) {
    this.updateSliderInputs(event, 'Duration');
  }

  updateApplicationFeeInputs(event) {
    this.updateSliderInputs(event, 'ApplicationFee');
  }

  updateInternshipInputs(event) {
    this.updateSliderInputs(event, 'Internship');
  }

  updateWorldRankingInputs(event) {
    this.updateSliderInputs(event, 'WorldRanking');
  }

  updateQsRankingInputs(event) {
    this.updateSliderInputs(event, 'QsRanking');
  }

  updateNationalRankingInputs(event) {
    this.updateSliderInputs(event, 'NationalRanking');
  }

  updateTuitionFeeInputs(event) {
    this.updateSliderInputs(event, 'TuitionFee');
  }

  search(event) {
    clearTimeout(this.timeout);
    
    const form = event.target.closest('form');
    
    if (event.target.matches('[data-search-target="input"]') && this.hasQueryResultsTarget) {
      this.updateQueryResults(event);
    }
    
    this.timeout = setTimeout(() => {
      if (form) {
        Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
      }
    }, this.debounceTime);
  }

  updateQueryResults(event) {
    const query = event.target.value.trim();
    clearTimeout(this.searchTimeout);
    
    this.searchTimeout = setTimeout(() => {
      if (query.length > 0) {
        this.queryResultsTarget.classList.remove('d-none');
        this.fetchSearchResults(query);
      } else {
        this.queryResultsTarget.classList.add('d-none');
        if (this.hasResultsContainerTarget) {
          this.resultsContainerTarget.innerHTML = '';
        }
      }
    }, this.debounceTime);
  }

  async fetchSearchResults(query) {
    try {
      const response = await fetch(`/courses/search?query=${encodeURIComponent(query)}`);
      const data = await response.json();
      this.displaySearchResults(data.courses);
    } catch (error) {
      console.error("Error fetching results:", error);
    }
  }

  displaySearchResults(courses) {
    if (!this.hasResultsContainerTarget) return;

    const resultsHtml = courses.map(([id, name, university]) => `
      <div class="p-2 border-bottom course-result" 
          data-course-id="${id}"
          data-action="click->search#selectCourse">
        <div class="fw-bold">${name}</div>
        <div class="small text-muted">${university}</div>
      </div>
    `).join('');

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
    
    const form = this.element;
    if (form) {
      Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
    }
  }

  performSearch(event) {
    event.preventDefault();
    const query = this.inputTarget.value.trim();
    if (query.length > 0) {
      const form = this.element;
      Turbo.visit(form.action + '?' + new URLSearchParams(new FormData(form)), { action: "replace" });
    }
  }

  clear(event) {
    event.preventDefault();
    if (this.hasInputTarget) {
      this.inputTarget.value = '';
    }
    if (this.hasQueryResultsTarget) {
      this.queryResultsTarget.classList.add('d-none');
    }
    if (this.hasResultsContainerTarget) {
      this.resultsContainerTarget.innerHTML = '';
    }
  }

  handleAddressKeydown(event) {
    if (event.key === 'Enter' && this.latitudeTarget.value && this.longitudeTarget.value) {
      event.preventDefault();
      this.search(event);
    }
  }
}
 