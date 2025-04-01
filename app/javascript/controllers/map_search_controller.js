import { Controller } from "@hotwired/stimulus"

export default class MapSearchController extends Controller {
  static targets = ["input", "form"]

  connect() {
    console.log("Map search controller connected")
    this.searchDebounced = this.debounce(this.performSearch.bind(this), 300)
  }

  // Debounce helper function
  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }

  search(event) {
    event.preventDefault()
    this.searchDebounced(event)
  }

  performSearch(event) {
    const form = event.target.closest('form')
    if (!form) return

    const formData = new FormData(form)
    
    // Update URL with search parameters
    const searchParams = new URLSearchParams(formData)
    const url = `${window.location.pathname}?${searchParams.toString()}`
    
    // Update browser URL without reloading
    window.history.pushState({}, '', url)
    
    // Show loading state
    const listContainer = document.querySelector('.list-group.list-group-flush')
    if (listContainer) {
      listContainer.innerHTML = '<div class="text-center p-4"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>'
    }
    
    // Fetch updated results
    fetch(url, {
      headers: {
        "Accept": "application/json"
      }
    })
    .then(response => response.json())
    .then(data => {
      // Update the list of universities
      this.updateUniversityList(data.universities)
      
      // Update the map markers
      this.updateMapMarkers(data.universities)
      
      // Update the count
      const countElement = document.querySelector('.h5.mb-3')
      if (countElement) {
        countElement.textContent = `Universities (${data.total_count})`
      }
    })
    .catch(error => {
      console.error('Error:', error)
      // Show error message
      if (listContainer) {
        listContainer.innerHTML = '<div class="alert alert-danger m-3">Error loading universities. Please try again.</div>'
      }
    })
  }

  updateUniversityList(universities) {
    const listContainer = document.querySelector('.list-group.list-group-flush')
    if (!listContainer) return

    if (universities.length === 0) {
      listContainer.innerHTML = '<div class="text-center p-4 text-muted">No universities found matching your criteria.</div>'
      return
    }

    listContainer.innerHTML = universities.map(university => `
      <div class="list-group-item list-group-item-action" 
           data-lat="${university.latitude}" 
           data-lng="${university.longitude}"
           data-action="click->map-search#focusUniversity">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h5 class="mb-1">${university.name}</h5>
            <p class="mb-1 text-muted">
              <i class="fas fa-map-marker-alt me-1"></i>
              ${[university.city, university.country].filter(Boolean).join(", ")}
            </p>
          </div>
          <div class="text-end">
            ${university.world_ranking ? `<span class="badge bg-primary mb-1">World Rank: ${university.world_ranking}</span>` : ''}
            ${university.qs_ranking ? `<span class="badge bg-success">QS Rank: ${university.qs_ranking}</span>` : ''}
          </div>
        </div>
      </div>
    `).join('')
  }

  updateMapMarkers(universities) {
    // Clear existing markers
    if (window.markers) {
      window.markers.forEach(marker => marker.setMap(null))
      window.markers = []
    }

    // Create new markers for filtered universities
    universities.forEach(university => {
      if (university.latitude && university.longitude) {
        const position = {
          lat: parseFloat(university.latitude),
          lng: parseFloat(university.longitude)
        }

        const marker = new google.maps.Marker({
          position: position,
          map: window.map,
          title: university.name,
          animation: google.maps.Animation.DROP
        })

        // Add click listener to marker
        marker.addListener('click', () => {
          // Close any open info windows
          if (window.infoWindow) {
            window.infoWindow.close()
          }
          
          // Create info window content
          const content = `
            <div class="p-2">
              <h5 class="mb-2">${university.name}</h5>
              <p class="mb-1"><strong>Country:</strong> ${university.country || 'N/A'}</p>
              <p class="mb-1"><strong>Type:</strong> ${university.type_of_university || 'N/A'}</p>
              <p class="mb-1"><strong>Address:</strong> ${university.address || 'N/A'}</p>
              <a href="/universities/${university.id}" class="btn btn-primary btn-sm mt-2 w-100" data-turbo="false">
                View Details
              </a>
            </div>
          `
          
          // Open info window
          window.infoWindow.setContent(content)
          window.infoWindow.open(window.map, marker)
          
          // Center map on marker
          window.map.setCenter(marker.getPosition())
          window.map.setZoom(15)
        })

        window.markers.push(marker)
      }
    })

    // Fit bounds to show all markers if there are any
    if (window.markers && window.markers.length > 0) {
      const bounds = new google.maps.LatLngBounds()
      window.markers.forEach(marker => bounds.extend(marker.getPosition()))
      window.map.fitBounds(bounds)
      
      // If there's only one marker, zoom in closer
      if (window.markers.length === 1) {
        window.map.setZoom(15)
      }
    }
  }

  focusUniversity(event) {
    const item = event.currentTarget
    const lat = parseFloat(item.dataset.lat)
    const lng = parseFloat(item.dataset.lng)
    
    // Remove active class from all items
    document.querySelectorAll('.list-group-item').forEach(el => {
      el.classList.remove('active')
    })
    
    // Add active class to clicked item
    item.classList.add('active')
    
    // Center map on university
    if (window.map && lat && lng) {
      window.map.setCenter({ lat, lng })
      window.map.setZoom(15)
      
      // Find and click the corresponding marker
      window.markers.forEach(marker => {
        if (marker.getPosition().lat() === lat && marker.getPosition().lng() === lng) {
          google.maps.event.trigger(marker, 'click')
        }
      })
    }
  }
} 