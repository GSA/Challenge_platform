# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'auth/result', to: 'sessions#result'
  resource 'session', only: [:new, :create, :destroy]

  get '/', to: "dashboard#index"
  get '/dashboard', to: "dashboard#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  if Rails.env.development? || Rails.env.dev?
    get "/sandbox", to: "sandbox#index"
  end
end
