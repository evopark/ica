# frozen_string_literal: true

# Simulates the blocklist entry from the main application
class BlocklistEntry < ApplicationRecord
  acts_as_paranoid

  belongs_to :parking_garage
  belongs_to :rfid_tag
end
