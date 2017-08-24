# frozen_string_literal: true

require 'ica/requests/update_accounts'
require 'ica/requests/create_accounts'
require 'ica/requests/delete_accounts'
require 'ica/errors'

module ICA
  # Uploads all missing account data, updates updated ones and removes outdated ones
  class AccountSync
    include Sidekiq::Worker
    recurrence backfill: false # just continue with the next schedule, w/o backfills

    # better not retry automatically until we have some experience with the system
    # for now we better look into AppSignal first before retrying stuff as a retry would probably just result
    # in the same error repeating
    sidekiq_options retry: false, unique: true

    delegate :log, to: GraylogHelper

    # Note that while `last_account_sync_at` is only set after all individual requests have gone through,
    # the individual requests will still trigger modifications in the remote system and thus modify the `uploaded_at`
    # attribute for the individual mapping objects.
    def perform(garage_system_id)
      started_at = Time.now
      @garage_system = ICA::GarageSystem.find(garage_system_id)
      garage_system_service.create_missing_mappings
      delete_old_accounts
      upload_unsynced_data
      @garage_system.update(last_account_sync_at: started_at)
    rescue ActiveRecord::RecordNotFound
      log(:error, 'Could not find garage system to sync', ica_garage_system_id: garage_system_id)
    rescue ICA::Errors::GarageSystemError => err
      log(:error, "Failed to sync garage system: #{err.message}", ica_garage_system_id: garage_system_id)
      raise # AppSignal to the rescue -.-
    end

    private

    def garage_system_service
      @garage_system_service ||= GarageSystemService.new(@garage_system)
    end

    def customer_account_service
      @customer_system_service ||= CustomerAccountService.new(@garage_system)
    end

    def upload_unsynced_data
      @garage_system.transaction { create_new_accounts }
      @garage_system.transaction { update_existing_accounts }
    end

    def update_existing_accounts
      # first update accounts that changed, then we can still look for individually changed cards afterwards
      accounts_to_update = customer_account_service.outdated_accounts
      request = Requests::UpdateAccounts.new(@garage_system, accounts_to_update)
      return if request.execute
      raise ICA::Errors::GarageSystemError.new(@garage_system.id, 'Failed to update accounts')
    end

    def create_new_accounts
      accounts_to_upload = @garage_system.customer_account_mappings.not_uploaded
      request = Requests::CreateAccounts.new(@garage_system, accounts_to_upload)
      return if request.execute
      raise ICA::Errors::GarageSystemError.new(@garage_system.id, 'Failed to execute account creation request')
    end

    def delete_old_accounts
      to_delete = garage_system_service.synced_obsolete_customer_account_mappings
      request = Requests::DeleteAccounts.new(@garage_system, to_delete)
      return if request.execute
      raise ICA::Errors::GarageSystemError.new(@garage_system.id, 'Failed to remove outdated accounts')
    end
  end
end
