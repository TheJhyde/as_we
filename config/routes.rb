# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#root"
  get "players/login", to: "players#login_page"
  post "players/login", to: "players#login"

  mount ActionCable.server => "/cable"

  get "secret/admin_page", to: "players#index"
  resources :games, only: [:create, :show, :update]
  resources :players, only: [:create, :show, :update, :edit]
  resources :conversations, only: [:create, :show]
  resources :messages, only: [:create]
end
