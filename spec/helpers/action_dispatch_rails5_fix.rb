# frozen_string_literal: true

require 'action_dispatch/testing/integration'

module ActionDispatch
  module Integration
    # This is a workaround to prevent ActionDispatch mistaking the Grape API
    # for a Rails application just because it responds to `routes`
    module Runner
      def create_session(app)
        klass = APP_SESSIONS[app] ||= Class.new(Integration::Session) do
          if app.respond_to?(:routes) && app.routes.respond_to?(:url_helpers)
            include app.routes.url_helpers
            include app.routes.mounted_helpers
          end
        end
        klass.new(app)
      end
    end
  end
end
