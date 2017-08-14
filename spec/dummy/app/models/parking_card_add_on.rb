# frozen_string_literal: true

# A copy of the ParkingCardAddOn from the main application
class ParkingCardAddOn < ApplicationRecord
  belongs_to :rfid_tag

  enum provider: {
    shell: 'shell',
    legic_prime: 'legic_prime'
  }

  validates :identifier, uniqueness: { scope: :provider }, presence: true
end
