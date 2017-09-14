# frozen_string_literal: true

FactoryGirl.define do
  factory :customer_account_mapping, class: ICA::CustomerAccountMapping do
    association :garage_system, strategy: :build
    association :user, strategy: :build

    trait :uploaded do
      uploaded_at 1.day.ago
    end
  end
end
