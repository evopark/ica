# frozen_string_literal: true

module ICA
  # Entry point for the mobile JSON-based API, powered by Grape
  class ApiV1 < Grape::API
    version 'v1', using: :path

    helpers do
      def authentication(garage_system)
        ICA::Authentication.new(garage_system.client_id,
                                garage_system.sig_key,
                                garage_system.auth_key)
      end

      def authenticate_request
        error!({ message: 'Unknown Client ID' }, 404) if garage_system.blank?
        return if authentication(garage_system).verify(self)
        error!({ message: 'Invalid or missing signature on request' }, 401)
      end

      def garage_system
        @garage_system ||= begin
          client_id = headers['Clientid']
          error!({ message: 'Client ID missing' }, 401) if client_id.blank?
          ICA::GarageSystem.find_by(client_id: client_id)
        end
      end

      def call_facade(method_name, args)
        ICA.garage_system_facade.new.public_send(method_name, { vendor: :ica }.merge(args))
      end
    end

    before do
      authenticate_request
    end

    after do
      @garage_system = nil
    end

    rescue_from ActiveRecord::RecordNotFound do
      error!({ message: I18n.t('errors.messages.not_found') }, 404)
    end

    mount ICA::Endpoints::V1::Accounts
    mount ICA::Endpoints::V1::Cards
    mount ICA::Endpoints::V1::Transactions
    mount ICA::Endpoints::V1::Command
  end
end
