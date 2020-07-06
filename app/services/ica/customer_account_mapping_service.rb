# frozen_string_literal: true

module ICA
  # Provides functionality to work with the host application parking garage model
  class CustomerAccountMappingService
    attr_reader :customer_account_mapping
    delegate :card_account_mappings, to: :customer_account_mapping
   
    def initialize(customer_account_mapping)
      @customer_account_mapping = customer_account_mapping
    end

    def mark_uploaded(uploaded_at: Time.current)
      customer_account_mapping.uploaded_at = uploaded_at
      card_account_mappings.each do |card|
        card.uploaded_at = uploaded_at
      end
      customer_account_mapping
    end
  end
end
