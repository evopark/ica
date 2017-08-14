# frozen_string_literal: true

# Allows us to keep a record of which users already were uploaded to the remote system and under which account key
class CreateICACustomerAccountMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :ica_customer_account_mappings do |t|
      t.uuid :account_key, null: false, index: true
      t.integer :user_id, foreign_key: { references: :users }, null: false
      t.timestamp :uploaded_at
      t.integer :garage_system_id, foreign_key: { references: ICA::GarageSystem.table_name }, null: false
      t.timestamps
    end
  end
end
