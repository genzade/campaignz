# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "campaigns#index"

  # Defines the campaigns resource routes
  resources :campaigns, only: %i[index]
end
