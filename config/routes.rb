Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  get "info", to: "info#index"
  get "search_db", to: "search#search_db"
  get "search_cache", to: "search#search_cache"

  root "static#dex"
end
