# frozen_string_literal: true

module ICA
  # Fake facade for tests
  class FakeFacade
    METHODS = %i[
      ping
      check_authentication?
      entry_allowed?
      exit_allowed?
      rfid_tag_enters_parking_garage!
      rfid_tag_leaves_parking_garage!
      payment_allowed?
      register_payment!
      finish_transaction!
      update_parking_garage_availability!
    ].freeze

    METHODS.each do |name|
      define_method(name) do |_params|
        raise NotImplementedError, "Please add a double for #{name}"
      end
    end
  end
end
