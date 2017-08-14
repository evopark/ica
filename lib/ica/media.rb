# frozen_string_literal: true

module ICA
  class Media
    TYPES = {
      1 => :rfid_uhf,
      2 => :lpn,
      21 => :mifare_classic,
      22 => :mifare_ultralight,
      23 => :mifare_desfire,
      31 => :legic_prime,
      32 => :legic_advant,
      255 => :card_number
    }.freeze
  end
end
