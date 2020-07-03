# frozen_string_literal: true

require 'ica/errors'

module ICA
  # Uploads all missing customer account mappings and marks them as uploaded
  # by batch processing
  class CustomerAccountTransfer
    include Sidekiq::Worker

    recurrence(backfill: false) { hourly }

    delegate :log, to: GraylogHelper

    def perform
      GarageSystem.all { |garage_system| transfer_missing_accounts garage_system }
    end

    private

    def transfer_missing_accounts(garage_system)
      garage_system_service = GarageSystemService.new garage_system
      each_unsynchronized_customer_account_mapping(garage_system) do |account_mapping|
        garage_system_service.upload account_mapping
      end
      garage_system.update_attribute last_account_sync_at: Time.current
    end

    def each_unsynchronized_customer_account_mapping(garage_system)
      garage_system.customer_account_mappings.not_uploaded.find_each do |account_mappings|
        account_mappings.each do |account_mapping|
          yield account_mapping
        end
      end
    end
  end
end
