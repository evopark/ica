# frozen_string_literal: true

FactoryBot.define do
  factory :carpark, class: 'ICA::Carpark' do
    sequence(:carpark_id)

    association :garage_system, strategy: :build
    association :parking_garage, strategy: :build
  end
end
