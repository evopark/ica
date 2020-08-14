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
      return unless Flipper.enabled?(:ica_sync)
      GarageSystem.all.each do |garage_system|
        log :info, "Start customer account transfer for #{garage_system.client_id}",
                   started_at: Time.current
        GarageSystemService.new(garage_system).synchronize_with_remote
        garage_system.update_attribute :last_account_sync_at, Time.current
      end
    end
  end
end
