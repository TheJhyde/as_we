Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "pages#root"

  mount ActionCable.server => "/cable"

  resources :games, only: [:create, :show, :update]
  resources :players, only: [:create, :show]
  resources :conversations, only: [:create, :show]
  resources :messages, only: [:create]
end
