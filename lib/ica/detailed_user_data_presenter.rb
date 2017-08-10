# frozen_string_literal: true

require_relative 'user_data_presenter'

module ICA
  # exposes one Account for the customer with all cards and containing customer number, address information etc
  class DetailedUserDataPresenter < UserDataPresenter
    def presented_data
      {
        Account: {
          AccountKey: account_key,
          Customer: customer_data,
          CardList: card_list
        }
      }
    end

    private

    def account_key
      "du#{@data['customer_number']}"
    end

    def card_list
      @data['rfid_tags'].map do |rfid_tag|
        { Card: card_data(rfid_tag) }
      end
    end

    def customer_data
      {
        CustomerNo: @data['customer_number'],
        Gender: coded_gender,
        Title: invoice_address['title'],
        FirstName: invoice_address['first_name'],
        LastName: invoice_address['last_name'],
        PostalCode: invoice_address['zip_code'],
        Location: invoice_address['city'],
        Street: invoice_address['street'],
        EmailAddress: @data['email']
      }
    end

    def coded_gender
      case invoice_address['gender']
      when 'male' then 1
      when 'female' then 2
      else 0
      end
    end

    def invoice_address
      @data['invoice_address']
    end
  end
end
