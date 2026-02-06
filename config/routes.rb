# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  resources :sessions, only: %i[create show], param: :code do
    member do
      get :swipe
      get :results
    end
  end

  get 'join', to: 'participants#new'
  get 'join/:code', to: 'participants#new', as: :join_with_code
  post 'join', to: 'participants#create'

  resources :votes, only: [:create]

  get 'up' => 'rails/health#show', :as => :rails_health_check
end
