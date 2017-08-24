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

      ADDITIONAL_INFOS = {
        1 => :manual_authorisation
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
          optional :InfoId, type: Integer, values: ADDITIONAL_INFOS.keys
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
          garage_system.carparks.find_by(carpark_id: params[:CarParkId])
        end

        # Theoretically the API supports using different media for entry or exit
        # To keep things simple on our end, we just find the best-matching media:
        # That should be the one from the top-level media key which contains the card number
        # (it's specified that it's always card type 255 there)
        def rfid_tag_information
          {
            rfid_tag: { tag_number: params[:Media][:MediaId] }
          }
        end

        def default_facade_arguments
          {
            transaction: {
              external_key: params[:transaction_id]
            }
          }.tap do |args|
            args.merge!(rfid_tag_information) if params[:Media].present?
            args.merge!(garage: { id: carpark.parking_garage_id }) if params[:CarParkId].present?
          end
        end

        def merge_payment_information(facade_arguments)
          facade_arguments.merge!(payment: { currency: params[:Price][:Currency],
                                             amount: params[:Price][:PriceGross],
                                             vat_rate: params[:Price][:VatPercentage] / 100.to_d })
        end

        def merge_entry_information(facade_arguments)
          facade_arguments[:transaction].merge!(started_at: params[:DriveIn][:DateTime])
        end

        def merge_exit_information(facade_arguments)
          facade_arguments[:transaction].merge!(finished_at: params[:DriveOut][:DateTime])
        end

        def interpret_facade_result(facade_result)
          if facade_result['success']
            body false
          else
            status 409
            { message: facade_result['message'] }
          end
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

      desc 'Update information for an existing parking transaction.'
      params do
        use :Transaction
      end
      patch ':transaction_id' do
        # Luckily, the API documentation specifies a very limited set of possible changes: adding an exit... Phew...
        facade_arguments = default_facade_arguments
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
        optional :Amount, type: Hash do
          use :Price
        end
        optional :Info, type: String
      end
      delete ':transaction_id' do
        facade_arguments = default_facade_arguments
        merge_payment_information(facade_arguments) if params[:Price].present?
        facade_result = call_facade(:cancel_transaction!, facade_arguments)
        interpret_facade_result(facade_result)
      end
    end
  end
end
