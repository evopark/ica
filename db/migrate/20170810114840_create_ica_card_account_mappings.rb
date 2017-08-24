# frozen_string_literal: true

# Maps an {RfidTag} to a card on the remote system
class CreateICACardAccountMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :ica_card_account_mappings do |t|
      t.integer :customer_account_mapping_id,
                foreign_key: { references: :ica_customer_account_mappings },
                null: false
      t.integer :rfid_tag_id, foreign_key: { references: :rfid_tags }, null: false
      t.uuid :card_key
      t.timestamp :uploaded_at
      t.timestamps
    end
  end
end
