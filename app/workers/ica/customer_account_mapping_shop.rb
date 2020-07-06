# frozen_string_literal: true

require 'ica/errors'

module ICA
  # Creates all missing customer account mappings for the newly active RFID tags
  class CustomerAccountMappingShop
    include Sidekiq::Worker
    include Sidetiq::Schedulable

#    recurrence(backfill: false) { hourly }

    delegate :log, to: GraylogHelper

    def perform
      GarageSystem.all { |garage_system| create_missing_accounts garage_system }
    end

    private

    def create_missing_accounts(garage_system)
      service = GarageSystemService.new garage_system
      service.active_cards_without_mapping.includes(:customer).find_each do |rfid_tag|
        card_account_mapping = service.build_card_account_mapping rfid_tag
        card_account_mapping.save!
      end
    end
  end
end
