Rails.application.routes.draw do
  root to: "home#index"
  devise_for :users

  resources :products do
    member do
      post "add_to_cart"
    end
  end

  resource :cart, only: %i[show], controller: "cart" do
    delete ":product_id", to: "cart#destroy", as: :remove_item
  end

  resources :orders, only: %i[index show]

  namespace :webhooks do
    post "stripe", to: "stripe#create"
  end

  resources :checkout, only: [] do
    collection do
      post "create"
      get "success"
      get "cancel"
    end
  end

  get "/about", to: "home#about", as: :about

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
