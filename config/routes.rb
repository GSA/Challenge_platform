# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'auth/result', to: 'sessions#result'
  resource 'session', only: [:new, :create, :destroy]
  post 'sessions/renew', to: 'sessions#renew'
  delete 'sessions/timeout', to: 'sessions#timeout'

  get '/', to: "dashboard#index"
  get '/dashboard', to: "dashboard#index"

  resources :evaluations, only: [:index]
  get '/evaluation_forms/confirmation', to: 'evaluation_forms#confirmation'
  resources :evaluation_forms
  post '/evaluation_forms/clone', to: 'evaluation_forms#create_from_existing'
  resources :manage_submissions, only: [:index]
  resources :challenges, only: [] do
    resources :manage_submissions, only: [:show]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  if Rails.env.development? || Rails.env.dev? || Rails.env.test?
    namespace :dev do
      get "/sandbox", to: "sandbox#index"
      get "/accounts", to: "accounts#index"
      post "/login", to: "accounts#login"
    end
  end

  resources :challenges, only: [] do
    resources :manage_evaluators, only: [:index, :create, :destroy]
    resources :evaluator_invitations, only: [] do
      member do
        post 'resend'
      end
    end
  end
end
