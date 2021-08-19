# frozen_string_literal: true

module ICA
  # Service for customer account mappings
  class MessageService
    attr_reader :message, :headers

    def initialize(message, headers:)
      @message = message
      @headers = headers
    end

    def build_ica_message(facade_response = {})
      return build_message(remark: facade_response) unless facade_response['success']

      build_message parking_transaction: parking_transaction
    end

    private

    def build_message(attributes)
      ::ICA::Message.new attributes.merge(rfid_tag: rfid_tag,
                                          parking_garage: parking_garage,
                                          message: message,
                                          headers: headers)
    end

    def uid
      message.dig 'DriveIn', 'Media', 'MediaId'
    end

    def rfid_tag
      ::RfidTag.with_deleted.find_by_uid uid
    end

    def parking_transaction
      return if message['transaction_id'].blank?

      ::ParkingTransaction.find_by_external_key message['transaction_id']
    end

    def carpark
      @carpark ||= ::ICA::Carpark.find_by_carpark_id message[:CarParkId]
    end

    delegate :parking_garage, to: :carpark, allow_nil: true
  end
end
