# frozen_string_literal: true

module ICA::Endpoints::V1
  # Receives information about new or updated parking transactions
  class Transactions < Grape::API
    namespace 'transactions' do
      MEDIA_TYPES = ICA::Media::TYPES.invert.freeze

      TRANSACTION_STATUS = {
        0 => :started,
        1 => :finished,
        2 => :cancelled
      }.freeze

      ENTRY_STATUS = {
        1 => :created_by_system,
        2 => :created_by_operator,
        3 => :replaced_by_operator
      }.freeze

      EXIT_STATUS = {
        1 => :finished_by_system_auto_pricing,
        2 => :finished_by_operator_auto_pricing,
        3 => :finished_by_system_manual_pricing,
        4 => :finished_by_operator_manual_pricing,
        101 => :cancelled_by_system,
        102 => :cancelled_by_operator,
        103 => :cancelled_by_rollback,
        104 => :cancelled_by_system_duration_exceeded,
        105 => :cancelled_by_operator_for_replacement
      }.freeze

      helpers do
        params :Media do
          requires :Media, type: Array do
            requires :MediaType, values: MEDIA_TYPES.keys
            requires :MediaId, type: String
            optional :MediaKey, type: String
          end
        end
        params :EventInfo do
          use :Media
          optional :DeviceNumber, type: Integer
          requires :DateTime, type: DateTime
        end
        params :Price do
          requires :PriceGross, type: BigDecimal
          requires :VatPercentage, type: BigDecimal
          optional :DiscountsOnPriceGrossList, type: Array do
            requires :DiscountOnPriceGross, type: Hash do
              requires :Amount, type: BigDecimal
              requires :Source, type: String
              optional :LocationID, type: String
              optional :LocationName, type: String
              optional :Comment, type: String
            end
          end
        end
        params :Transaction do
          requires :Transaction, type: Hash do
            optional :CarParkOperatorName, type: String
            requires :CarParkId, type: Integer
            optional :CarParkName, type: String
            requires :AccountKey, type: UUID
            use :Media
            requires :Status, values: TRANSACTION_STATUS.keys
            optional :DriveIn, type: Hash do
              use :EventInfo
              requires :Status, values: ENTRY_STATUS.keys
            end
            optional :DriveOut, type: Hash do
              use :EventInfo
              requires :Status, values: EXIT_STATUS.keys
            end
            optional :Price, type: Hash do
              use :Price
            end
            at_least_one_of :DriveIn, :DriveOut
          end
        end
      end

      desc 'Submit information about a new parking transaction. Can either be new or finished'
      params do
        use :Transaction
      end
      put ':transaction_id' do
        status 503
      end

      desc 'Update information for an existing parking transaction.'
      params do
        use :Transaction
      end
      patch ':transaction_id' do
        status 503
      end

      desc 'Cancel a previously-submitted parking transaction'
      params do
        optional :Amount, type: Hash do
          use :Price
        end
        optional :Info, type: String
      end
      delete ':transaction_id' do
        status 409
      end
    end
  end
end
