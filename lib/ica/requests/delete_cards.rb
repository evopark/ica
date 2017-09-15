# frozen_string_literal: true

module ICA
  module Requests
    # When just individual cards have disappeared from an account,
    # they're deleted with this request
    class DeleteCards < BaseRequest
      PATH = '/v1/cards'

      def initialize(garage_system, card_mappings)
        @card_mappings = card_mappings
        super(garage_system)
      end

      def execute
        log(:info, 'Deleting cards from ICA system')
        request(:delete, PATH, request_body)
        if response_ok?
          @card_mappings.each(&:destroy!)
        else
          log(:error, 'Failed to delete cards from ICA system', card_keys: card_keys)
        end
      end

      private

      def card_keys
        @card_keys ||= @card_mappings.map(&:card_key)
      end

      def request_body
        # using `map` here instead of `pluck` because we'll want to `#destroy` them individually anyway
        JSON.dump(card_keys)
      end
    end
  end
end
