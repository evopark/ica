# frozen_string_literal: true

FactoryBot.define do
  factory :card_account_mapping, class: 'ICA::CardAccountMapping' do
    association :rfid_tag, factory: %i[rfid_tag active], strategy: :build
    association :customer_account_mapping, strategy: :build
    card_key 'ABC123'

    after(:build) do |mapping|
      mapping.rfid_tag.customer = mapping.customer_account_mapping.customer
    end

    trait :uploaded do
      uploaded_at 1.day.ago
    end
  end
end
