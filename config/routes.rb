# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'auth/result', to: 'sessions#result'
  resource 'session', only: [:new, :create, :destroy] do
    post 'renew'
    delete 'timeout'
  end

  get '/dashboard', to: "dashboard#index"

  resources :evaluations, only: [:index] do
    member do
      get :submissions
    end
  end
  resources :evaluation_forms do
    member do
      get 'confirmation'
      post 'clone'
    end
  end
  resources :phases, only: [:index] do
    member do
      get :submissions
    end
    resources :evaluators, only: [:index, :create, :destroy] do
      member do
        post 'resend_invite'
      end
    end
    resources :evaluator_submission_assignments, only: [:index, :update, :create]
  end
  resources :submissions, only: [:index, :show, :update]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.development? || Rails.env.dev? || Rails.env.test?
    namespace :dev do
      get "/sandbox", to: "sandbox#index"
      get "/accounts", to: "accounts#index"
      post "/login", to: "accounts#login"
    end
  end

  match '/assets/*path.:ext' => 'pages#assets', via: [:get]
  match '/*path' => 'pages#index', via: [:get]
  match '/' => 'pages#root', via: [:get]
end
