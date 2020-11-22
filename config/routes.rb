Rails.application.routes.draw do
  get 'info', to: 'info#index'
  root 'info#index'
end
