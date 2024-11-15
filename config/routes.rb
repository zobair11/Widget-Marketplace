Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users

  resources :widgets
  resources :payments, only: [:new, :create]

  resources :transactions, only: [:index, :show, :new, :create]

  resource :balance, only: [:show]

  # Root path
  root to: 'widgets#index' # Home page shows available widgets
end
