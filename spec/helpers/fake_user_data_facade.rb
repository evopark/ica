# frozen_string_literal: true

module ICA
  # Provides the infrastructure for a fake user data facade
  class FakeUserDataFacade
    METHODS = %i[
        block_user
        unblock_user
        user_information
        all_permitted_users
      ].freeze

    METHODS.each do |name|
      define_method(name) do |_params|
        raise NotImplementedError, "Please add a double for #{name}"
      end
    end
  end
end
