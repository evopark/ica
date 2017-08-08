# frozen_string_literal: true

module ICA::Endpoints::V1
  # Allows access to individual cards of a user. A card may encompass multiple media.
  class Cards < Grape::API
    desc 'Retrieve information about an individual card'
    get 'cards/:card_key' do
    end

    # Locking & Unlocking
    namespace 'lock/cards' do
      desc 'Lock an individual card'
      params do
        optional :Info, type: String
      end
      post ':card_key' do
      end

      desc 'Release the lock on a card'
      params do
        optional :Info, type: String
      end
      delete ':card_key' do
      end
    end
  end
end
