# frozen_string_literal: true

module ICA
  # Provides helper functions to work with garage system data
  class GarageSystemService
    def initialize(garage_system)
      @garage_system = garage_system
    end
    delegate :parking_garages, to: :@garage_system

    # Ensures that all users & parking cards have a mapping in the correct structure
    # The `uploaded_at` attribute is still null but they can then be picked up by the next sync
    def create_missing_mappings
      @garage_system.transaction do
        active_cards_without_mapping.includes(:user).each do |active_card|
          create_card_mapping(active_card)
        end
      end
    end

    # Here we don't take cards into accounts that were recently blocked because those are not supposed to be deleted
    # from the remote system. But that is not a problem for the full re-sync: in that case, we use `#allowed_tags`
    def synced_obsolete_customer_account_mappings(full_sync: false)
      base_query = full_sync ? allowed_tags : short_term_rfid_tags
      subquery = <<-SQL
        NOT EXISTS (SELECT icam.id FROM ica_card_account_mappings icam
                      JOIN (#{base_query.to_sql}) AS allowed_tags ON allowed_tags.id = icam.rfid_tag_id
                      WHERE icam.customer_account_mapping_id = ica_customer_account_mappings.id)
      SQL
      @garage_system.customer_account_mappings.where(subquery, @garage_system.id)
    end

    # Finds all tags that are currently in the remote system
    # but are not in the list of allowed tags of the garage anymore
    # Since we keep blocked cards in the remote system as long as they're active, don't consider them here
    def synced_inactive_card_account_mappings
      @garage_system.card_account_mappings.joins(:rfid_tag).where <<-SQL
        NOT EXISTS (SELECT * FROM (#{short_term_rfid_tags.to_sql}) allowed_tags WHERE allowed_tags.id=rfid_tags.id)
      SQL
    end

    private

    # Easy-To-Park systems contain all users whereas non-ETP-systems don't include ETP users
    def all_users
      return User.all if @garage_system.easy_to_park?
      User.where.not(brand: 'easy_to_park')
    end

    def allowed_tags
      rfid_tags_restricted_by_test_groups.excluding(blocked_rfid_tags)
    end

    # TODO: in order to get this as performant and straight-forward as possible, it does not take contract parking into
    # consideration at the moment.
    # Also `premium_location` support would complicate things much more (would need to make accounts specific to
    # individual carparks) and since this is not planned for the foreseeable future, I skipped this as well
    def short_term_rfid_tags
      RfidTag.with_active_state.short_term_allowed.joins(:user).merge(all_users)
    end

    # Since we cannot single out individual carparks when blocking a card, we need to find blocklist entries
    # pertaining to _any_ parking garage associated with this system. Ideally we'll reflect that in the UI
    # of the creation process but that's secondary as long as we only use blocklist entries as sparingly as right now
    RFID_BLOCKLIST_SUBQUERY = <<-SQL
        EXISTS (SELECT id FROM blocklist_entries be
                         WHERE be.rfid_tag_id = rfid_tags.id
                           AND be.parking_garage_id IN (SELECT parking_garage_id
                                                          FROM ica_carparks cp
                                                         WHERE cp.garage_system_id=:garage_system_id))
    SQL
    def blocked_rfid_tags
      RfidTag.where(RFID_BLOCKLIST_SUBQUERY, garage_system_id: @garage_system.id)
    end

    def rfid_tags_restricted_by_test_groups
      rfid_tags = short_term_rfid_tags
      case @garage_system.workflow_state
      when 'live'
        rfid_tags.excluding(RfidTag.joins(user: :test_groups).merge(TestGroup.setup_only))
      when 'testing'
        restrict_tags_by_test_groups(rfid_tags)
      else
        RfidTag.none
      end
    end

    def restrict_tags_by_test_groups(all_tags)
      all_tags
        .joins(user: :test_groups)
        .merge(relevant_test_groups)
        .distinct
    end

    def create_card_mapping(rfid_tag)
      account_mapping = find_or_create_account_mapping(rfid_tag)
      add_card_mapping_to_account(account_mapping, rfid_tag)
    end

    def find_or_create_account_mapping(rfid_tag)
      # for Easy-To-Park: check if there is an account for the user and add it
      # for everyone else: create a separate account
      if @garage_system.easy_to_park? && rfid_tag.user.easy_to_park?
        @garage_system.customer_account_mappings.find_or_create_by(user: rfid_tag.user)
      else
        @garage_system.customer_account_mappings.create(user: rfid_tag.user)
      end
    end

    def add_card_mapping_to_account(account_mapping, rfid_tag)
      account_mapping.card_account_mappings.create(rfid_tag: rfid_tag)
    end

    ACTIVE_CARDS_WITHOUT_MAPPING_QUERY = <<-SQL
      NOT EXISTS (SELECT card_mappings.id
                    FROM ica_card_account_mappings card_mappings
                    JOIN ica_customer_account_mappings customer_mappings
                      ON customer_mappings.garage_system_id = :garage_system_id
                     AND card_mappings.customer_account_mapping_id = customer_mappings.id
                   WHERE card_mappings.rfid_tag_id = rfid_tags.id)
    SQL

    # Finds all tags that are in the list of allowed tags
    # but have not yet been submitted to the remote system
    def active_cards_without_mapping
      allowed_tags.where(ACTIVE_CARDS_WITHOUT_MAPPING_QUERY, garage_system_id: @garage_system.id)
    end
  end
end