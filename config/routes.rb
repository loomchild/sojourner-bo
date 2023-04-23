Rails.application.routes.draw do
  root 'root#index'

  resources :conferences, param: :conference_id, only: [:show] do
    member do
      get 'events'
    end
  end
end
