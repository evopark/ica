# frozen_string_literal: true

# To be run after the first main application migration
class SplitUserCustomerModels < ActiveRecord::Migration[5.0]
  def up
    add_column :ica_customer_account_mappings, :customer_id, :integer, foreign_key: true
    execute <<-SQL
      UPDATE ica_customer_account_mappings SET customer_id=(SELECT customer_id FROM users WHERE users.id=user_id)
    SQL
    change_column_null :ica_customer_account_mappings, :customer_id, false
    remove_column :ica_customer_account_mappings, :user_id
  end

  def down
    add_column :ica_customer_account_mappings, :user_id, :integer, foreign_key: true
    execute <<-SQL
      UPDATE ica_customer_account_mappings
         SET user_id=(SELECT id FROM users WHERE users.customer_id=ica_customer_account_mappings.customer_id)
    SQL
    change_column_null :ica_customer_account_mappings, :user_id, false
    remove_column :ica_customer_account_mappings, :customer_id
  end
end
