Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'dashboard', to: 'pages#dashboard'
  delete 'dashboard', to: 'pages#destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :recommendations, only: [:new, :create, :show]
  resources :recommendation_movies, only: [:new, :create]
  resources :movies, only: [:show]
end
