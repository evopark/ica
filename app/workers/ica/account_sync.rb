# frozen_string_literal: true

require 'ica/requests/update_accounts'
require 'ica/requests/create_accounts'
require 'ica/requests/delete_accounts'
require 'ica/errors'

module ICA
  # Uploads all missing account data, updates updated ones and removes outdated ones
  class AccountSync
    include Sidekiq::Worker

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
      delete_old_cards
      upload_unsynced_data
      @garage_system.update(last_account_sync_at: started_at)
    rescue ActiveRecord::RecordNotFound
      log(:error, 'Could not find garage system to sync', ica_garage_system_id: garage_system_id)
    rescue ICA::GarageSystemError => err
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
      execute_request(Requests::UpdateAccounts,
                      customer_account_service.outdated_accounts,
                      'Failed to update accounts')
    end

    def create_new_accounts
      execute_request(Requests::CreateAccounts,
                      @garage_system.customer_account_mappings.not_uploaded,
                      'Failed to upload new accounts')
    end

    def delete_old_accounts
      execute_request(Requests::DeleteAccounts,
                      garage_system_service.synced_obsolete_customer_account_mappings,
                      'Failed to remove outdated accounts')
    end

    def delete_old_cards
      execute_request(Requests::DeleteCards,
                      garage_system_service.synced_inactive_card_account_mappings,
                      'Failed to remove outdated cards')
    end

    def execute_request(clazz, data, error_message)
      return if data.none?
      request = clazz.new(@garage_system, data)
      return if request.execute
      raise ICA::GarageSystemError.new(@garage_system.id, error_message)
    end
  end
end
