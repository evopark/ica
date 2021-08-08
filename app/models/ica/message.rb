# frozen_string_literal: true

module ICA
  # Dump incoming messages
  class Message < ApplicationRecord
    belongs_to :rfid_tag
    belongs_to :parking_transaction
    belongs_to :parking_garage
  end
end
