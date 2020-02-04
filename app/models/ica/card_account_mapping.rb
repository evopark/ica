# frozen_string_literal: true

module ICA
  # This is mainly so we can keep track of which card has already been persisted to the remote system
  class CardAccountMapping < ApplicationRecord
    include UploadStatusScopes

    acts_as_paranoid

    belongs_to :customer_account_mapping, class_name: 'ICA::CustomerAccountMapping'
    belongs_to :rfid_tag
    has_one :customer, through: :customer_account_mapping
    has_one :garage_system, through: :customer_account_mapping

    scope :with_card_key, ->(key) { where(card_key: key) }
    scope :for_garage_system, ->(client_id) do
      joins(:garage_system).merge(ICA::GarageSystem.with_client_id(client_id))
    end

    validates :customer_account_mapping, presence: true
    # Internal key, generated by our code to find card data
    validates :card_key, presence: true

    before_validation :generate_card_key, on: :create

    def to_json_hash
      {
        CardKey: card_key,
        CardVariant: card_variant,
        Blocked: block_code,
        Media: media_list
      }
    end

    private

    # rubocop:disable Metrics/MethodLength
    # TODO: 2019-04-01, find stable solution for uniq tag numbers on data level
    def media_list
      [
        {
          MediaType: 1,
          MediaId: rfid_tag.uid
        },
        {
          MediaType: 255,
          MediaId: rfid_tag.decorate.external_id
        }
      ].tap do |list|
        legic_addon = rfid_tag.parking_card_add_ons.legic_prime.first
        next if legic_addon.nil?
        list << {
          MediaType: 31,
          MediaId: legic_addon.identifier
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def block_code
      garage_system.blocked_rfid_tags.where(id: rfid_tag.id).none? ? 0 : 1
    end

    def card_variant
      test_card? ? 1 : 0
    end

    def test_card?
      garage_system.test_groups
                   .joins(:customers)
                   .merge(Customer.where(id: customer_account_mapping.customer_id))
                   .exists?
    end

    def generate_card_key
      self.card_key ||= SecureRandom.uuid
    end
  end
end
