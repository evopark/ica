# frozen_string_literal: true

require 'ica/errors'

module ICA
  # Creates all missing customer account mappings for the newly active RFID tags
  class CustomerAccountMappingShop
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence(backfill: false) { hourly }

    delegate :log, to: GraylogHelper

    def perform
      return unless Flipper.enabled?(:ica_sync)
      GarageSystem.all.each { |garage_system| create_missing_accounts garage_system }
    end

    private

    def create_missing_accounts(garage_system)
      service = GarageSystemService.new garage_system
      service.active_cards_without_mapping
             .includes(:customer)
             .where("customers.brand" => supported_brands)
             .find_each do |rfid_tag|
        card_account_mapping = service.build_card_account_mapping rfid_tag
        card_account_mapping.save!
      end
    end

    # Since the ICA API is designed to give a card permission for all or none of
    # their parking garages, we can not distinguish on garage-level
    def supported_brands
      @supported_brands ||= Brand.joins(:parking_garages)
                                 .where("parking_garages.system_type" => :ica)
                                 .group('brands.id')
                                 .pluck(:name)
    end
  end
end
