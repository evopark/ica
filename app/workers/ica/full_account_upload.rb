# frozen_string_literal: true

require 'ica/requests/create_accounts'
require 'ica/errors'

module ICA
  # Uploads a full export of account information to the remote system
  class FullAccountUpload
    include Sidekiq::Worker

    def perform(garage_system_id)
      started_at = Time.now
      @garage_system = ICA::GarageSystem.find(garage_system_id)
      @garage_system.transaction do
        clear_existing_data
        upload_all_accounts
        @garage_system.update(last_account_sync_at: started_at)
      end
    end

    private

    def clear_existing_data
      garage_system_service.synced_obsolete_customer_account_mappings(full_sync: true).destroy_all
      @garage_system.customer_account_mappings.update_all(uploaded_at: nil)
      @garage_system.card_account_mappings.update_all(uploaded_at: nil)
    end

    def upload_all_accounts
      return if Requests::CreateAccounts.new(@garage_system,
                                             @garage_system.customer_account_mappings).execute
      raise ActiveRecord::Rollback, 'Failed to execute upload request'
    end

    def garage_system_service
      @garage_system_service ||= ICA::GarageSystemService.new(@garage_system)
    end
  end
end
