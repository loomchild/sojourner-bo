Rails.application.routes.draw do
  root 'dashboard#index'
  get 'events', to: 'events#index'
end
