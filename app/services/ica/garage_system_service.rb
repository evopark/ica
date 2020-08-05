# frozen_string_literal: true

module ICA
  # Provides helper functions to work with garage system data
  class GarageSystemService
    attr_reader :garage_system

    delegate :customer_account_mappings, :parking_garages, to: :garage_system

    def initialize(garage_system)
      @garage_system = garage_system
    end

    def synchronize_with_remote
      customer_account_mappings.out_of_sync.find_each(batch_size: 50) do |account|
        publish account 
      end
    end

    def build_card_account_mapping(rfid_tag)
      account_mapping = find_or_build_account_mapping rfid_tag.customer
      account_mapping.account_key = SecureRandom.uuid
      account_mapping.card_account_mappings
                     .build card_key: SecureRandom.uuid,
                            rfid_tag: rfid_tag,
                            garage_system: garage_system
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
    def synced_inactive_card_account_mappings(full_sync: false)
      card_query = full_sync ? allowed_tags : short_term_rfid_tags
      @garage_system.card_account_mappings.joins(:rfid_tag).where <<-SQL
        NOT EXISTS (SELECT * FROM (#{card_query.to_sql}) card_query WHERE card_query.id=rfid_tags.id)
      SQL
    end

    # Finds all tags that are in the list of allowed tags
    # but have not yet been submitted to the remote system
    def active_cards_without_mapping
      allowed_tags.where(ACTIVE_CARDS_WITHOUT_MAPPING_QUERY, garage_system_id: @garage_system.id)
    end

    private

    def publish(customer_account_mapping)
      method = :put if customer_account_mapping.persisted?
      response = upload_request.perform method, customer_account_mapping
      return unless response.status.success?

      mark_uploaded Time.current
    end

    def mark_uploaded(uploaded_at)
      customer_account_mapping.uploaded_at = uploaded_at
      card_account_mappings.each do |card|
        card.uploaded_at = uploaded_at
      end
      customer_account_mapping.save!
    end

    # because the BaseRequest class was built awkward, we have to work around it:
    def upload_request
      @upload_request ||= GarageSystemRequest.new garage_system
    end
    
    def find_or_build_account_mapping(customer)
      if garage_system.easy_to_park? && customer.easy_to_park?
        garage_system.customer_account_mappings
                     .find_or_initialize_by customer: customer
      else
        garage_system.customer_account_mappings
                     .build customer: customer
      end
    end

    # Easy-To-Park systems receive easy-to-park customers whereas non-ETP-systems only receive non-ETP customers
    # That means that ECE systems will need to be set up twice: once for ETP and once for evopark
    # This is due to the way that ICA works internally to map the customers to the corresponding vendor
    def all_customers
      return Customer.where(brand: 'easy_to_park') if @garage_system.easy_to_park?
      Customer.where.not(brand: 'easy_to_park')
    end

    def allowed_tags
      # unfortunately there might be some cards with UID nil, we need to exclude those or it will break things
      rfid_tags_restricted_by_test_groups.excluding(blocked_rfid_tags)
                                         .where.not(uid: nil)
    end

    # TODO: in order to get this as performant and straight-forward as possible, it does not take contract parking into
    # consideration at the moment.
    # Also `premium_location` support would complicate things much more (would need to make accounts specific to
    # individual carparks) and since this is not planned for the foreseeable future, I skipped this as well
    def short_term_rfid_tags
      RfidTag.with_active_state.short_term_allowed.joins(:customer).merge(all_customers)
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
        rfid_tags.excluding(RfidTag.joins(customer: :test_groups).merge(TestGroup.setup_only))
      when 'testing'
        restrict_tags_by_test_groups(rfid_tags)
      else
        RfidTag.none
      end
    end

    def restrict_tags_by_test_groups(all_tags)
      all_tags
        .joins(customer: :test_groups)
        .merge(@garage_system.test_groups)
        .distinct
    end

    ACTIVE_CARDS_WITHOUT_MAPPING_QUERY = <<-SQL
      NOT EXISTS (SELECT card_mappings.id
                    FROM ica_card_account_mappings card_mappings
                    JOIN ica_customer_account_mappings customer_mappings
                      ON customer_mappings.garage_system_id = :garage_system_id
                     AND card_mappings.customer_account_mapping_id = customer_mappings.id
                   WHERE card_mappings.rfid_tag_id = rfid_tags.id)
    SQL
  end
end
