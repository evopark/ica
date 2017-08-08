# frozen_string_literal: true

module ICA
  # Uploads all missing account data, updates updated ones and removes outdated ones
  class AccountSync
    include Sidekiq::Worker

    def perform(garage_system_id)
      @garage_system = ICA::GarageSystem.find(garage_system_id)
      return unless @garage_system.live?
    end
  end
end
