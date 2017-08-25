# frozen_string_literal: true

require_relative 'create_accounts'

module ICA
  module Requests
    # Update existing information on the remote system.
    class UpdateAccounts < CreateAccounts
      private

      def request_method
        :patch
      end
    end
  end
end
