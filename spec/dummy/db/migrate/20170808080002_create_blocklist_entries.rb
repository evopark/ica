# frozen_string_literal: true
class CreateBlocklistEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :blocklist_entries do |t|
      t.integer :rfid_tag_id, foreign_key: { references: :rfid_tags }, null: false
      t.integer :parking_garage_id, foreign_key: { references: :parking_garages }, null: false
      t.timestamp :deleted_at
      t.timestamps
    end
  end
end
