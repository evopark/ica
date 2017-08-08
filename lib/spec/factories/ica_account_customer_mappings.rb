# frozen_string_literal: true

FactoryGirl.define do
  factory :ica_account_customer_mapping, class: 'Ica::AccountCustomerMapping' do
    account_key 'MyString'
    user_id 1
  end
end
