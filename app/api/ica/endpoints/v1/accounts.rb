# frozen_string_literal: true

require 'ica/collection_streamer'

module ICA::Endpoints::V1
  # Allows the remote to retrieve information about a single user account
  class Accounts < Grape::API
    namespace 'accounts' do
      helpers do
        def account_mappings
          garage_system.customer_account_mappings.uploaded.includes(:card_account_mappings, :user)
        end
      end

      # here we only support accessing information that was already uploaded to the remote system
      get ':account_key' do
        customer_account_mapping = account_mappings.find_by(account_key: params[:account_key])
        raise ActiveRecord::RecordNotFound if customer_account_mapping.nil?
        customer_account_mapping.to_json_hash
      end

      # This is a minimal implementation which only returns data that was previously uploaded to the remote system,
      # in order to avoid race conditions with re-synchronisation. If the remote wants to have a re-upload, it needs
      # to use the command interface
      get do
        stream ICA::CollectionStreamer.new(account_mappings)
      end
    end
  end
end
