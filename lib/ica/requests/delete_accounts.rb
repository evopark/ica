# frozen_string_literal: true

require_relative 'base_request'

module ICA
  # Deletes an account from the remote system
  class DeleteAccounts < BaseRequest
    PATH = 'api/v1/accounts'

    def initialize(garage_system, customer_account_mappings)
      super(garage_system)
      @customer_account_mappings = customer_account_mappings
    end

    def execute
      log(:info, 'Removing accounts from ICA system', log_params)
      request(:delete, PATH, request_body)
      if response_ok?
        # Usually it won't destroy that many of them so it's better to log what happened instead of calling destroy_all
        @customer_account_mappings.each { |mapping| processing_success(mapping) }
      else
        log(:error, 'Failed to remove accounts from ICA system', log_params)
      end
    end

    private

    def processing_success(mapping)
      log(:info, 'Successfully removed account from ICA system', log_params.merge(user_id: mapping.user_id))
      mapping.destroy!
    end

    def request_body
      JSON.dump(@customer_account_mappings.pluck(:account_key))
    end
  end
end
