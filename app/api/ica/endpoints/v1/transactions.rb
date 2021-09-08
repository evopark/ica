# frozen_string_literal: true

module ICA::Endpoints::V1
  # Receives information about new or updated parking transactions
  # rubocop:disable Metrics/ClassLength
  class Transactions < Grape::API
    namespace 'transactions' do
      TRANSACTION_STATUS = {
        0 => :started,
        1 => :finished,
        2 => :cancelled
      }.freeze

      ENTRY_STATUS = {
        1 => :created_by_system,
        2 => :created_by_operator,
        3 => :replaced_by_operator,
        4 => :created_by_system_with_operator_auth
      }.freeze

      EXIT_STATUS = {
        1 => :finished_by_system_auto_pricing,
        2 => :finished_by_operator_auto_pricing,
        3 => :finished_by_system_manual_pricing,
        4 => :finished_by_operator_manual_pricing,
        5 => :finished_by_system_with_operator_auth,
        6 => :finished_by_system_with_operator_auth_manual_pricing,
        101 => :cancelled_by_system,
        102 => :cancelled_by_operator,
        103 => :cancelled_by_rollback,
        104 => :cancelled_by_system_duration_exceeded,
        105 => :cancelled_by_operator_for_replacement
      }.freeze

      helpers do
        params :Media do
          requires :MediaType, type: Integer, values: ICA::Media::TYPES.keys
          requires :MediaId, type: String
          optional :MediaKey, type: String
        end
        params :EventInfo do
          # the documentation is not 100% clear whether this is mandatory for DriveOut and we don't actually use it
          optional :Media, type: Hash do
            use :Media
          end
          optional :DeviceNumber, type: Integer
          requires :DateTime, type: DateTime
          optional :InfoId, type: Integer # we don't validate those anymore as they're dynamic
        end
        params :Price do
          requires :Currency, type: String, values: %w[EUR]
          requires :PriceGross, type: BigDecimal # note that rebates have already been subtracted from this one
          requires :VatPercentage, type: BigDecimal
          optional :DiscountOnPriceGross, type: Array do
            requires :Amount, type: BigDecimal
            requires :Source, type: String
            optional :LocationID, type: String
            optional :LocationName, type: String
            optional :Comment, type: String
          end
        end
        params :Transaction do
          optional :CarParkOperatorName, type: String
          requires :CarParkId, type: Integer
          optional :CarParkName, type: String
          requires :AccountKey, type: UUID
          # on this level it is mandatory
          requires :Media, type: Hash do
            use :Media
          end
          requires :Status, type: Integer, values: TRANSACTION_STATUS.keys
          optional :DriveIn, type: Hash do
            use :EventInfo
            requires :Status, type: Integer, values: ENTRY_STATUS.keys
          end
          optional :DriveOut, type: Hash do
            use :EventInfo
            requires :Status, type: Integer, values: EXIT_STATUS.keys
          end
          optional :Price, type: Hash do
            use :Price
          end
          at_least_one_of :DriveIn, :DriveOut
        end
      end

      helpers do
        def carpark
          garage_system.carparks.find_by(carpark_id: params[:CarParkId]).tap do |carpark|
            error!({ message: 'Carpark ID unknown' }, 422) if carpark.nil?
          end
        end

        # To avoid problems with duplicate card numbers, we need to look up the concrete RFID tag belonging to the
        # media key specified in the request.
        def rfid_tag_information
          {
            rfid_tag: {
              id: find_rfid_tag_id(card_key: params[:Media][:MediaKey],
                                   client_id: requested_client_id)
            }
          }
        end

        def find_rfid_tag_id(card_key:, client_id:)
          ICA::CardAccountMapping.with_deleted
                                 .with_card_key(card_key)
                                 .for_garage_system(client_id)
                                 .pluck('rfid_tag_id')
                                 .first
        end

        def default_facade_arguments
          {
            transaction: {
              external_key: params[:transaction_id]
            }
          }.tap do |args|
            args.merge!(rfid_tag_information) if params[:Media].present?
            args[:garage] = { id: carpark.parking_garage_id } if params[:CarParkId].present?
          end
        end

        def merge_payment_information(facade_arguments)
          facade_arguments.merge!(payment: { currency: params[:Price][:Currency],
                                             amount: params[:Price][:PriceGross],
                                             vat_rate: params[:Price][:VatPercentage] / 100.to_d })
        end

        def merge_entry_information(facade_arguments)
          facade_arguments[:transaction].merge!(started_at: params[:DriveIn][:DateTime],
                                                device_id: params[:DriveIn][:DeviceNumber])
        end

        def merge_exit_information(facade_arguments)
          facade_arguments[:transaction].merge!(finished_at: params[:DriveOut][:DateTime],
                                                device_id: params[:DriveOut][:DeviceNumber])
        end

        def interpret_facade_result(facade_result)
          if facade_result['success']
            body false
          else
            case facade_result.dig('result', 'reason').to_s
            when 'parking_transaction_not_found' then unknown_transaction
            when 'unknown_medium' then unknown_medium
            else default_error(facade_result)
            end
          end
        end

        def unknown_transaction
          status 404
          { Id: I18n.t('errors.messages.invalid') }
        end

        def unknown_medium
          status 422
          { Media: { MediaId: I18n.t('errors.messages.invalid') } }
        end

        def default_error(facade_result)
          status 409
          { message: facade_result['message'] }
        end

        def finish_or_cancel_parking_transaction(facade_arguments)
          if params[:DriveOut][:Status] < 100
            call_facade(:finish_transaction!, facade_arguments)
          else
            call_facade(:cancel_transaction!, facade_arguments)
          end
        end
      end

      desc 'Submit information about a new parking transaction. Can either be new or finished'
      params do
        use :Transaction
      end
      put ':transaction_id' do
        if Flipper.enabled?(:ica_message_dump)
          form = ::ICA::MessageForm.new message: params,
                                        headers: headers,
                                        external_key: params[:transaction_id]
          if form.valid?
            form.save!
            body false
          else
            status 409
            { message: "Message couldn't be processed" }
          end
        else
          facade_arguments = default_facade_arguments
          merge_entry_information(facade_arguments) if params[:DriveIn].present?
          merge_payment_information(facade_arguments) if params[:Price].present?
          facade_result = if params[:DriveOut].present?
                            merge_exit_information(facade_arguments)
                            finish_or_cancel_parking_transaction(facade_arguments)
                          else
                            call_facade(:rfid_tag_enters_parking_garage!, facade_arguments)
                          end
          interpret_facade_result(facade_result)
        end
      end

      desc 'Update information for an existing parking transaction.'
      params do
        use :Transaction
      end
      patch ':transaction_id' do
        # Luckily, the API documentation specifies a very limited set of possible changes: adding an exit... Phew...
        facade_arguments = default_facade_arguments
        merge_entry_information(facade_arguments) if params[:DriveIn].present?
        merge_exit_information(facade_arguments)
        facade_result = if params[:Price].present?
                          merge_payment_information(facade_arguments)
                          finish_or_cancel_parking_transaction(facade_arguments)
                        else
                          call_facade(:rfid_tag_exits_parking_garage!, facade_arguments)
                        end
        interpret_facade_result(facade_result)
      end

      desc 'Cancel a previously finished parking transaction'
      params do
        optional :Amount, type: BigDecimal
        optional :Info, type: String
        optional :InfoId, type: Integer
      end
      delete ':transaction_id' do
        facade_arguments = default_facade_arguments
        facade_arguments[:payment] = { amount: params[:Amount] } if params[:Amount].present?
        facade_result = call_facade(:cancel_transaction!, facade_arguments)
        interpret_facade_result(facade_result)
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
