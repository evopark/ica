# frozen_string_literal: true

module ICA
  # Functionality to work with {CustomerAccountMapping} and the {User} model
  # TODO: Handle the scenario where a non-ETP-user suddenly becomes an ETP user but has multiple cards which were
  # already uploaded to the remote system. There might even be the other direction but that's not really supported.
  class CustomerAccountService
    def initialize(garage_system)
      @garage_system = garage_system
    end

    def outdated_accounts
      @garage_system.customer_account_mappings.joins(:user)
                    .where('uploaded_at IS NOT NULL AND uploaded_at < :last_sync', last_sync: last_sync)
                    .merge(updated_users_since_last_sync)
    end

    private

    def last_sync
      @garage_system.last_account_sync_at
    end

    # brace yourselves... the most straightforward way to find users for whom any one of the following match:
    # - their email, feature set, brand or workflow state changed
    # - their address changed
    # - one of their RFID tags changed (workflow state), got blocked or unblocked
    # rubocop:disable Metrics/MethodLength
    def updated_users_since_last_sync
      versions_with_changes = versions_with_changes(%w[email feature_set_id brand workflow_state])
      changes_query = <<-SQL
        (EXISTS
          (SELECT versions.id FROM (#{versions_with_changes.to_sql}) versions WHERE versions.item_id = users.id)
        OR EXISTS
          (SELECT addresses.id FROM addresses WHERE addresses.user_id = users.id
                                                AND addresses.type = 'InvoiceAddress'
                                                AND addresses.default = true
                                                AND addresses.updated_at >= :last_sync)
        OR EXISTS
          (SELECT rfid_tags.id FROM rfid_tags WHERE rfid_tags.user_id=users.id AND (rfid_tags.updated_at >= :last_sync
            OR EXISTS (SELECT blocks.id
                         FROM blocklist_entries blocks
                        WHERE blocks.rfid_tag_id = rfid_tags.id
                          AND (blocks.created_at >= :last_sync OR blocks.deleted_at >= :last_sync)
                          AND blocks.parking_garage_id IN (SELECT parking_garage_id
                                                             FROM ica_carparks
                                                            WHERE ica_carparks.garage_system_id = :garage_system_id))))
        )
      SQL
      User.where(changes_query, last_sync: last_sync, garage_system_id: @garage_system.id)
    end
    # rubocop:enable Metrics/MethodLength

    def versions_with_changes(attrs)
      quoted = attrs.map { |attr| "'#{attr}'" }
      # the versions.item_type is a notable difference between the dummy app and the real one :(
      # the PostgreSQL `?|` operator works with JSONB columns and yields any record where the JSON contains one of the
      # specified keys
      version_sql = <<-SQL
        versions.item_type='BaseUser'
          AND versions.created_at >= :last_sync
          AND object_changes::jsonb ?| array[#{quoted.join(',')}]
      SQL
      PaperTrail::Version.where(version_sql, last_sync: last_sync)
    end
  end
end
