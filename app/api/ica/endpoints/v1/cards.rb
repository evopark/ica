# frozen_string_literal: true

module ICA::Endpoints::V1
  # Allows access to individual cards of a user. A card may encompass multiple media.
  class Cards < Grape::API
    helpers do
      def mapping_from_card_key
        garage_system.card_account_mappings.find_by(card_key: params[:card_key]).tap do |mapping|
          raise ActiveRecord::RecordNotFound if mapping.nil?
        end
      end
    end

    desc 'Retrieve information about an individual card'
    get 'cards/:card_key' do
      mapping_from_card_key.to_json_hash
    end

    # Locking & Unlocking
    namespace 'lock/cards' do
      desc 'Lock an individual card'
      params do
        optional :Info, type: String
      end
      post ':card_key' do
        rfid_tag_id = mapping_from_card_key.rfid_tag_id
        garage_ids = garage_system.carparks.pluck(:parking_garage_id)
        call_facade :block_rfid_tag, rfid_tag: { id: rfid_tag_id }, garage_ids: garage_ids
        body false
      end

      desc 'Release the lock on a card'
      params do
        optional :Info, type: String
      end
      delete ':card_key' do
        rfid_tag_id = mapping_from_card_key.rfid_tag_id
        garage_ids = garage_system.carparks.pluck(:parking_garage_id)
        call_facade :unblock_rfid_tag, rfid_tag: { id: rfid_tag_id }, garage_ids: garage_ids
        body false
      end
    end
  end
end
