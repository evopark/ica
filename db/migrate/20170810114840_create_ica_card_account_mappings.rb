# frozen_string_literal: true

# Maps an {RfidTag} to a card on the remote system
class CreateICACardAccountMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :ica_card_account_mappings do |t|
      t.integer :customer_account_mapping_id,
                foreign_key: { references: :ica_customer_account_mappings },
                null: false, index: true
      t.uuid :card_key
      t.string :card_identifier, index: true
      t.timestamps
    end
  end
end
