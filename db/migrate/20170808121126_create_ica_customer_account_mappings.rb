# frozen_string_literal: true

# Allows us to keep a record of which users already were uploaded to the remote system and under which account key
class CreateICACustomerAccountMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :ica_customer_account_mappings do |t|
      t.uuid :account_key, null: false, index: true
      t.integer :user_id, references: ICA.user_class.table_name, null: false
      t.integer :garage_system_id, references: ICA::GarageSystem.table_name, null: false
      t.timestamps
    end
  end
end
