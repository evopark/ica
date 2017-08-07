# frozen_string_literal: true

FactoryGirl.define do
  factory :carpark, class: 'ICA::Carpark' do
    sequence(:carpark_id)

    association :api_user, strategy: :build
    association :parking_garage, strategy: :build
  end
end
