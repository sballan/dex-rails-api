Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'info', to: 'info#index'
  get 'search', to: 'search#index'

  root 'static#home'
end
