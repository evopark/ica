# frozen_string_literal: true

FactoryGirl.define do
  factory :parking_garage, class: ICA.parking_garage_class do
    sequence(:name) { |n| format('Test Garage %d', n) }
    system_type 'ica'
  end
end
