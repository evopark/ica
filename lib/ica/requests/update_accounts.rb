# frozen_string_literal: true

require_relative 'base_request'

module ICA
  # Update existing information on the remote system.
  class UpdateAccounts < CreateAccounts
    private

    def request_method
      :patch
    end
  end
end
