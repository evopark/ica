# frozen_string_literal: true

module ICA
  # Service for customer account mappings
  class CustomerAccountMappingService
    attr_reader :customer_account_mapping

    def initialize(customer_account_mapping)
      @customer_account_mapping = customer_account_mapping
    end

    def publish(garage_system: nil, method: :post)
      method = :put if customer_account_mapping.uploaded?
      garage_system ||= customer_account_mapping.garage_system
      response = upload_request(garage_system).perform method, customer_account_mapping
      return unless response.status.success?

      mark_uploaded Time.current
    end

    private

    def mark_uploaded(uploaded_at)
      customer_account_mapping.uploaded_at = uploaded_at
      customer_account_mapping.card_account_mappings.each do |card|
        card.uploaded_at = uploaded_at
      end
      customer_account_mapping.save!
    end

    # because the BaseRequest class was built awkward, we have to work around it:
    def upload_request(garage_system)
      @upload_request ||= GarageSystemRequest.new garage_system
    end
  end
end
