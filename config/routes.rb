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

  root to: 'home#index'
end
