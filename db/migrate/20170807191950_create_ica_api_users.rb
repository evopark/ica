# frozen_string_literal: true

class CreateICAApiUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :ica_api_users do |t|
      t.string :client_id, null: false
      t.string :auth_key, null: false
      t.string :sig_key, null: false
    end
    add_index :ica_api_users, %w[client_id auth_key]
  end
end
