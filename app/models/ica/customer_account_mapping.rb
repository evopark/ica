# frozen_string_literal: true

module ICA
  # Allows us to keep a record of which users already were uploaded (and when) to
  # the remote system and under which account key.
  #
  # Note that the relation to the main applications {User} class is mainly to ensure data integrity:
  # all interaction with actual user information is done through the {UserDataFacade}.
  class CustomerAccountMapping < ICA::ApplicationRecord
    acts_as_paranoid
    include UploadStatusScopes

    belongs_to :customer
    belongs_to :garage_system, class_name: 'ICA::GarageSystem'

    has_many :card_account_mappings, class_name: 'ICA::CardAccountMapping',
                                     dependent: :destroy,
                                     autosave: true
    has_many :rfid_tags, through: :card_account_mappings

    before_validation :generate_account_key, on: :create

    validates :garage_system, presence: true

    scope :out_of_sync, -> do
      joins(:card_account_mappings)
        .where("#{table_name}.uploaded_at IS NULL OR "\
               "(ica_card_account_mappings.uploaded_at IS NULL AND #{table_name}.uploaded_at IS NOT NULL)")
        .uniq
    end
    # Determine whether the associated user is a test user in this system
    def test_user?
      customer.test_groups.merge(garage_system.test_groups).any?
    end

    def to_json_hash
      {
        AccountKey: account_key,
        Card: card_data,
        Customer: customer_data
      }
    end

    private

    def invoice_address
      customer.current_invoice_address
    end

    def card_data
      card_account_mappings.map(&:to_json_hash)
    end

    def customer_data
      if easy_to_park?
        full_customer_data
      else
        minimal_customer_data
      end
    end

    def minimal_customer_data
      # we know that for non-easy-to-park users there is a 1:1 relation between account and card
      card_number = rfid_tags.first&.tag_number
      return {} if card_number.blank?
      {
        CustomerNo: card_number,
        LastName: card_number
      }
    end

    def full_customer_data
      {
        CustomerNo: customer.customer_number,
        Gender: numeric_gender,
        Title: translated_salutation,
        FirstName: invoice_address.first_name,
        LastName: invoice_address.last_name,
        PostalCode: invoice_address.zip_code,
        Location: invoice_address.city,
        Street: invoice_address.street,
        EmailAddress: customer.user.email
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
      customer.easy_to_park? && garage_system.easy_to_park?
    end

    def generate_account_key
      self.account_key ||= SecureRandom.uuid
    end
  end
end
