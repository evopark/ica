# frozen_string_literal: true

FactoryGirl.define do
  factory :api_user, class: ICA::ApiUser do
    sequence(:client_id) { |n| format('User %d', n) }
    sig_key { SecureRandom.hex(32) }
    auth_key { SecureRandom.hex(32) }
  end
end
