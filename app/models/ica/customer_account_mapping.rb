# frozen_string_literal: true

module ICA
  # Allows us to keep a record of which users already were uploaded (and when) to
  # the remote system and under which account key.
  #
  # Note that the relation to the main applications {User} class is mainly to ensure data integrity:
  # all interaction with actual user information is done through the {UserDataFacade}.
  class CustomerAccountMapping < ICA::ApplicationRecord
    belongs_to :user, class_name: ICA.user_class.to_s
    belongs_to :garage_system, class_name: 'ICA::GarageSystem'

    has_many :card_account_mappings, class_name: 'ICA::CardAccountMapping'

    before_validation :generate_account_key, on: :create

    validates :garage_system, presence: true
    validate :either_user_or_card_identifier

    private

    def either_user_or_card_identifier; end

    def generate_account_key
      self.account_key ||= SecureRandom.uuid
    end
  end
end
