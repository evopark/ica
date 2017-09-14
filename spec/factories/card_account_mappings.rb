# frozen_string_literal: true

FactoryGirl.define do
  factory :card_account_mapping, class: 'ICA::CardAccountMapping' do
    association :rfid_tag, factory: %i[rfid_tag active], strategy: :build
    association :customer_account_mapping, strategy: :build

    after(:build) do |mapping|
      mapping.rfid_tag.user = mapping.customer_account_mapping.user
    end

    trait :uploaded do
      uploaded_at 1.day.ago
    end
  end
end
