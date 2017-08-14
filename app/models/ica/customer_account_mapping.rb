# frozen_string_literal: true

module ICA
  # Allows us to keep a record of which users already were uploaded (and when) to
  # the remote system and under which account key.
  #
  # Note that the relation to the main applications {User} class is mainly to ensure data integrity:
  # all interaction with actual user information is done through the {UserDataFacade}.
  class CustomerAccountMapping < ICA::ApplicationRecord
    include UploadStatusScopes

    belongs_to :user
    belongs_to :garage_system, class_name: 'ICA::GarageSystem'

    has_many :card_account_mappings, class_name: 'ICA::CardAccountMapping', dependent: :destroy

    before_validation :generate_account_key, on: :create

    validates :garage_system, presence: true

    # Determine whether the associated user is a test user in this system
    def test_user?
      user.test_groups.merge(garage_system.test_groups).any?
    end

    def to_json_hash
      {
        AccountKey: account_key,
        Card: card_data
      }.tap do |data|
        next unless easy_to_park?
        data.merge!(Customer: customer_data)
      end
    end

    private

    def invoice_address
      user.current_invoice_address
    end

    def card_data
      card_account_mappings.map(&:to_json_hash)
    end

    def customer_data
      {
        CustomerNo: user.customer_number,
        Gender: numeric_gender,
        Title: translated_salutation,
        FirstName: invoice_address.first_name,
        LastName: invoice_address.last_name,
        PostalCode: invoice_address.zip_code,
        Location: invoice_address.city,
        Street: invoice_address.street,
        EmailAddress: user.email
      }
    end

    def numeric_gender
      case invoice_address.gender.to_s
      when 'male' then 1
      when 'female' then 2
      else 0
      end
    end

    def translated_salutation
      if invoice_address.academic_title.present?
        invoice_address.translate_enum(:academic_title)
      else
        invoice_address.translate_enum(:gender)
      end
    end

    def easy_to_park?
      user.easy_to_park? && garage_system.easy_to_park?
    end

    def generate_account_key
      self.account_key ||= SecureRandom.uuid
    end
  end
end
