# frozen_string_literal: true

Rails.application.routes.draw do
  # Admin interface
  namespace :admin do
    resources :dummies, only: :index
    mount ICA::Admin::Engine => '/ica'
  end

  mount ICA::API => '/api'
end
