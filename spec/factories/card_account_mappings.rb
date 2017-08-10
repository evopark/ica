# frozen_string_literal: true

FactoryGirl.define do
  factory :card_account_mapping, class: 'ICA::CardAccountMapping' do
    sequence(:card_identifier) { |n| "uhf-#{format('%09d', n)}" }
  end
end
