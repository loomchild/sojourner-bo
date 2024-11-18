Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root 'root#index'

  resources :conferences, param: :conference_id, only: [:show] do
    member do
      get 'events'
      get 'tracks'
    end
  end
end
