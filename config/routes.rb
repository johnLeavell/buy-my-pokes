Rails.application.routes.draw do
  root to: "home#index"
  # root to: "products#index"
  devise_for :users

  resources :products

  namespace :webhooks do
    post 'stripe', to: 'stripe#create'
  end

resources :checkout do 
  collection do
    post "create"
    get "success"
    get "cancel"
  end
end

post "products/add_to_cart/:id", to: "products#add_to_cart", as: :add_to_cart

get "/about", to: "home#about", as: :about

  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
