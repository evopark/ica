# frozen_string_literal: true

require 'ica/errors'

module ICA
  # Uploads all missing customer account mappings and marks them as uploaded
  # by batch processing
  class CustomerAccountTransfer
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence(backfill: false) { hourly }

    delegate :log, to: GraylogHelper

    def perform
      GarageSystem.all { |garage_system| transfer_missing_accounts garage_system }
    end

    private

    def transfer_missing_accounts(garage_system)
      log :info, "Start customer account transfer for #{garage_system.client_id}",
                 started_at: Time.current
      garage_system_service = GarageSystemService.new garage_system
      garage_system.customer_account_mappings.not_uploaded.find_each(50) do |account|
        garage_system_service.upload account
      end
      garage_system.update_attribute last_account_sync_at: Time.current
    end
  end
end
