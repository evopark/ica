# frozen_string_literal: true

FactoryGirl.define do
  factory :garage_system, class: ICA::GarageSystem do
    sequence(:client_id) { |n| format('User %d', n) }
    sig_key { SecureRandom.hex(32) }
    auth_key { SecureRandom.hex(32) }
    workflow_state 'live'
  end
end
