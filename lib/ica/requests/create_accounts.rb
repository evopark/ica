# frozen_string_literal: true

require_relative 'base_request'

module ICA
  module Requests
    # Create a set of accounts on the remote system
    # Can be used to send updates or even re-upload everything
    # In any case, the caller is responsible for starting a database transaction
    class CreateAccounts < BaseRequest
      PATH = 'api/v1/accounts'

      def initialize(garage_system, account_mappings)
        super(garage_system)
        @account_mappings = account_mappings
      end

      def execute
        uploaded_at = Time.now
        response = request(request_method, PATH, request_body)
        if response_ok? # \o/
          update_upload_timestamps(uploaded_at)
          log(:info, 'Successfully uploaded accounts to ICA system',
              account_count: @account_mappings.count)
          true
        else
          log(:error, 'Failed to upload user account data',
              response_body: response.body.to_s,
              response_code: response.code)
          false
        end
      end

      private

      def update_upload_timestamps(uploaded_at)
        @account_mappings.update_all(uploaded_at: uploaded_at)
        CardAccountMapping.joins(:customer_account_mapping).merge(@account_mappings)
                          .update_all(uploaded_at: uploaded_at)
      end

      # when uploading a list of all accounts, use PUT, otherwise POST
      # the count should be a good indication here...
      def request_method
        if @garage_system.customer_account_mappings.count == @account_mappings.count
          :put
        else
          :post
        end
      end

      # The request body can become quite large -> use a stream
      def request_body
        ICA::CollectionStreamer.new(@account_mappings)
      end

      # Prevents the lib from trying to determine content length before starting to send
      def http
        super.headers(HTTP::Headers::TRANSFER_ENCODING => :chunked)
      end
    end
  end
end
