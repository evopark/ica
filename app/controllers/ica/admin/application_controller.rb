# frozen_string_literal: true

module ICA::Admin
  # Base controller for the admin interface
  class ApplicationController < ActionController::Base
    layout 'admin'
  end
end
