# frozen_string_literal: true

module ICA
  # Enqueues synchronization of all live systems
  class AllGarageSystemsSync
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence(backfill: false) { daily.hour_of_day(12) }

    def perform
      return unless Flipper.enabled?(:ica_sync)
      ICA::GarageSystem.with_live_state.ids.each do |system_id|
        AccountSync.perform_async(system_id)
      end
    end
  end
end
