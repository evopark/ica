# frozen_string_literal: true

# Basic User and RfidTag models for the gem to reference
class CreateUsersAndRfidTags < ActiveRecord::Migration[5.0]
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.integer :feature_set_id, null: false
      t.string :customer_number, null: false
      t.string :workflow_state, null: false
      t.column :brand, :user_brand, null: false, default: 'evopark'
      t.timestamps
    end

    create_table :addresses do |t|
      t.integer :user_id, foreign_key: { references: :users }, null: false
      t.boolean :default
      t.string :first_name
      t.string :last_name
      t.integer :gender
      t.integer :academic_title
      t.string :zip_code
      t.string :country_code
      t.string :city
      t.string :additional
      t.string :street
      t.string :type, default: 'InvoiceAddress'
      t.timestamps
    end

    create_table :rfid_tags do |t|
      t.integer :user_id, foreign_key: { references: :users }
      t.string :tag_number, null: false, index: true
      t.string :uid, index: true # theoretically not null, unfortunately missing in some envs
      t.string :workflow_state, null: false
      t.timestamps
    end

    execute "CREATE TYPE parking_card_add_on_provider AS ENUM('shell', 'legic_prime')"

    create_table :parking_card_add_ons do |t|
      t.string :identifier, null: false
      t.integer :rfid_tag_id, foreign_key: true
      t.column :provider, :parking_card_add_on_provider
      t.timestamps
    end
    add_index :parking_card_add_ons, %i[provider identifier],
              unique: true, name: 'idx_parking_card_add_on_unique_identifier'
  end

  def down
    drop_table :parking_card_add_ons
    drop_table :rfid_tags
    drop_table :users
    execute 'DROP TYPE parking_card_add_on_provider'
  end
end
