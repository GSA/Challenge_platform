# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'auth/result', to: 'sessions#result'
  get 'auth/failure_to_proof', to: 'sessions#failure_to_proof'
  resource 'session', only: [:new, :create, :destroy] do
    post 'renew'
    delete 'timeout'
  end

  resources :evaluations, only: %i[index edit create update] do
    member do
      get 'submissions'
      get 'revision', to: 'evaluation_overrides#show'
      patch 'revision', to: 'evaluation_overrides#update', as: 'revise'
    end
  end

  resources :phases, only: [:index] do
    member do
      get 'submissions'
      get 'export_submissions'
    end
    resources :evaluators, only: [:index, :create, :destroy] do
      member do
        post 'resend_invite'
      end
    end
    resources :evaluator_submission_assignments, only: [:index, :update, :create]
    resources :evaluation_forms, except: [:index] do
      member do
        get 'confirmation'
        post 'clone'
      end
    end
  end

  resources :submissions, only: [:show, :update] do
    resources :evaluations, only: [:new] do
      patch 'recuse', on: :collection
    end
    get 'materials', on: :member, to: "submission_materials#show"
  end

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

  get '/assets/*path.:ext' => 'pages#assets'
  get '/*path' => 'pages#index'
  get '/' => 'pages#root'
end
