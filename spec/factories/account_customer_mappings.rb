# frozen_string_literal: true

FactoryGirl.define do
  factory :account_customer_mapping, class: ICA::AccountCustomerMapping do
    association :garage_system, strategy: :build
    association :user, strategy: :build
  end
end
