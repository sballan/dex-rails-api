Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'info', to: 'info#index'
  get 'search_db', to: 'search#search_db'
  get 'search_cache', to: 'search#search_cache'

  root 'static#dex'
end
