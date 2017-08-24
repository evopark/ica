# frozen_string_literal: true

# Separate PaperTrail version model to prevent pollution of host application versions table as much as possible
class CreateICAPaperTrail < ActiveRecord::Migration[5.0]
  def change
    create_table :ica_versions do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false, foreign_key: false # suppress smart-assyness of schema_plus
      t.string   :event,     null: false
      t.string   :whodunnit
      t.json     :object          # PostgreSQL-specific JSON type
      t.jsonb    :object_changes
      t.datetime :created_at
    end
    add_index :ica_versions, %i[item_type item_id]
  end
end
