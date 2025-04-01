// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import SearchController from "controllers/search_controller"
import FiltersController from "controllers/filters_controller"
import MapSearchController from "controllers/map_search_controller"
eagerLoadControllersFrom("controllers", application)

application.register("search", SearchController)
application.register("filters", FiltersController)
application.register("map_search", MapSearchController)
