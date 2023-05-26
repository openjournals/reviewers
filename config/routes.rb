Rails.application.routes.draw do

  namespace :api do
    resources :stats, only: [] do
      collection do
        post "update/:username/:what", action: :update, as: :update_stat
      end
    end
  end

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

  resources :users, only: [:show, :edit, :update, :destroy] do
    put :status, on: :member
  end

  resources :reviewers, only: [:show, :index, :new, :create] do
    get :search, on: :collection
  end

  resources :areas, only: [] do
    get :search, on: :collection
  end

  resources :feedbacks, only: [:create, :destroy]

  get '/join', to: 'home#reviewer_signup', as: :reviewer_signup
  get '/lookup', to: 'home#no_reviewer_signup', as: :no_reviewer_signup
  root to: 'home#index'
end
