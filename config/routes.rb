Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "courses#search_page"
  resources :courses, only: [:index]
  resources :courses do
    get :check_index, on: :member
    collection do
      get :debug_index
    end
    collection do
      get :search_page
      get :search
      get :map
    end
    collection do
      get :suggest_addresses
    end
  end
  
  # Define universities routes with collection action first
  resources :universities do
    collection do
      get :map_search
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  get 'debug_search/:query' => 'courses#debug_search'
end
