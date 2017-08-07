# frozen_string_literal: true

# Authentication should be done from the outside
ICA::Admin::Engine.routes.draw do
  resources :carparks, controller: 'admin/carparks'
end
