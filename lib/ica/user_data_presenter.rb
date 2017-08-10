# frozen_string_literal: true

require_relative 'media'

module ICA
  # takes a record as returned from the {UserDataFacade} and decides on how to format it for the ICA system
  class UserDataPresenter
    def initialize(data)
      @data = data
    end

    private

    # Right now we only have RFID tags with optional LEGIC
    def card_data(rfid_tag)
      {
        CardKey: card_key_for_rfid_tag(rfid_tag),
        CardVariant: test_user? ? 1 : 0,
        Blocked: 0, # if the card gets blocked, the facade will just not return it
        BlockedInfo: '',
        CardBrand: translate_tag_design(rfid_tag['design']),
        MediaList: media_list_for_rfid_tag(rfid_tag)
      }
    end

    LEGIC_MEDIA_TYPE = Media.TYPES.invert[:legic_prime]

    def media_list_for_rfid_tag(rfid_tag)
      [
        Media: {
          MediaType: 1,
          MediaId: rfid_tag['tag_number'] # TODO: find out whether to use tag number (EPC) or UID
        }
      ].tap do |list|
        legic_addon = rfid_tag['addons'].find { |addon| addon['provider'] == 'legic' }
        next if legic_addon.nil?
        list << {
          Media: {
            MediaType: LEGIC_MEDIA_TYPE, # TODO: find out whether it's LEGIC prime or advant
            MediaId: legic_addon['identifier']
          }
        }
      end
    end

    def translate_tag_design(tag_design)
      I18n.t("enums.rfid_tag.design.#{tag_design}")
    end

    def card_key_for_rfid_tag(rfid_tag)
      "UHF-#{rfid_tag.tag_number}"
    end

    def test_user?
      !!@data['test_user']
    end
  end
end
