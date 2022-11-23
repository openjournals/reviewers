Rails.application.routes.draw do
  get '/auth/github/callback', to: 'sessions#create'
  get '/auth/orcid/callback', to: 'profiles#orcid'
  get '/auth/failure', to: 'sessions#auth_failure'
  get '/signout', to: 'sessions#destroy', as: :signout

  resource :profile, only: [:show, :update] do
    member do
      get :orcid
    end
  end

  resource :admin, only: :show do
    get :find_users, on: :collection
  end

  resources :users, only: [:show, :update, :destroy]

  resources :reviewers, only: [:show, :index] do
    get :search, on: :collection
  end

  resources :areas, only: [] do
    get :search, on: :collection
  end

  resources :feedbacks, only: [:create, :destroy]

  root to: 'home#index'
end
