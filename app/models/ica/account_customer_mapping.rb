# frozen_string_literal: true

module ICA
  # Allows us to keep a record of which users already were uploaded to the remote system and under which account key
  class AccountCustomerMapping < ICA::ApplicationRecord
    belongs_to :user, class_name: ICA.user_class.to_s
    belongs_to :garage_system, class_name: 'ICA::GarageSystem'

    before_validation :generate_account_key, on: :create

    validates :user, presence: true
    validates :garage_system, presence: true

    private

    def generate_account_key
      self.account_key ||= SecureRandom.uuid
    end
  end
end
