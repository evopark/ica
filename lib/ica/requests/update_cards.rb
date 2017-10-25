# frozen_string_literal: true

module ICA
  module Requests
    class UpdateCards < BaseRequest
      PATH = '/v1/cards'

      def initialize(garage_system, card_mappings)
        @card_mappings = card_mappings
        super(garage_system)
      end

      def execute
        log(:info, 'Updating cards from ICA system')
        request(:patch, PATH, request_body)
        return if response_ok?
        log(:error, 'Failed to update cards in ICA system', card_mapping_ids: @card_mappings.ids)
      end

      private

      def request_body
        hash = @card_mappings.map do |card_mapping|
          {
            AccountKey: card_mapping.customer_account_mapping.account_key,
            Card: [card_mapping.to_json_hash]
          }
        end
        JSON.dump(hash)
      end
    end
  end
end