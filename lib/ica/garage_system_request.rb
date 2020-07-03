# frozen_string_literal: true

require_relative 'collection_streamer'
require 'ica/requests/base_request'

module ICA
  # Deals with gaarge system related requests at the ICA remote system
  class GarageSystemRequest < ICA::Requests::BaseRequest
    attr_reader :response
    PATH = '/v1/accounts'

    # Transfers an account mapping to ICA remote system
    def self.post(account_mapping)
      body = ICA::CollectionStreamer.new account_mapping
      log :info, 'Upload account to ICA', account_key: account_mapping.account_key,
                                          body: body
      response = request :post, PATH, body
      log_error(account_mapping.account_key, response) unless response.status.success?
      response
    end

    private

    def log_error(account_key, response)
      log :error, 'Account upload to ICA failed', account_key: account_key,
                                                  status: response.code,
                                                  response: response.body.to_s
    end

    # Prevents the lib from trying to determine content length before starting to send
    def http
      super.headers(HTTP::Headers::TRANSFER_ENCODING => :chunked)
    end
  end
end
