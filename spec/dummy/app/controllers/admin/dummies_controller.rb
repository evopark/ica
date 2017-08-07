# frozen_string_literal: true

module Admin
  # Provides a dummy route that can be used in the layout to test the namespace isolation
  # while still being able to render the host applications layout
  class DummiesController < BaseController
    def index
    end
  end
end