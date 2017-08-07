# Simulate simple PaperTrail existence in the host application
class SimplePaperTrail < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false, foreign_key: false # suppress smart-assyness of schema_plus
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.json     :object          # PostgreSQL-specific JSON type
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]
  end
end
