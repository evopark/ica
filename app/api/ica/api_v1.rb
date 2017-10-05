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
          if client_id.blank?
            error!({ message: 'Client ID header missing. Cannot establish context for carpark id' }, 401)
          else
            ICA::GarageSystem.find_by(client_id: client_id)
          end
        end
      end

      def call_facade(method_name, args)
        ICA.garage_system_facade.new.public_send(method_name, { vendor: :ica }.merge(args)).deep_stringify_keys
      end
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error!(e, 422)
    end

    rescue_from Grape::Exceptions::MethodNotAllowed do |e|
      error!(e, 405)
    end

    rescue_from ActiveRecord::RecordNotFound do
      error!({ message: I18n.t('errors.messages.not_found') }, 404)
    end

    # temporarily disabled until ICA implements it on their side
    # before do
    #   authenticate_request
    # end

    after do
      @garage_system = nil
    end

    mount ICA::Endpoints::V1::Accounts
    mount ICA::Endpoints::V1::Cards
    mount ICA::Endpoints::V1::Transactions
    mount ICA::Endpoints::V1::Command
  end
end
