# frozen_string_literal: true

require_relative 'user_data_presenter'

module ICA
  # Exposes an individual account for each card of the user and without any additional information about the user
  class SparseUserDataPresenter < UserDataPresenter
    def presented_data
      @data['rfid_tags'].map do |rfid_tag_data|
        {
          Account: {
            AccountKey: account_key(rfid_tag_data),
            CardList: [{ Card: card_data(rfid_tag_data) }]
          }
        }
      end
    end

    private

    def account_key(rfid_tag_data)
      "sur#{rfid_tag_data['tag_number']}"
    end
  end
end
