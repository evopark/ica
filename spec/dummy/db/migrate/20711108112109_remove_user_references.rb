# frozen_string_literal: true

# Access to constants
require_relative '20171107162407_add_customer_model'

# Once all data has been migrated correctly, remove references to the users table
class RemoveUserReferences < ActiveRecord::Migration[5.0]
  def up
    AddCustomerModel::MIGRATED_COLUMNS.each do |column|
      remove_column :users, column
    end
    AddCustomerModel::TABLES.each do |table|
      remove_column table, :user_id
    end
    drop_table :test_groups_users
  end

  def down
    add_column :users, :customer_number, :string
    add_column :users, :brand, :user_brand_type
    add_column :users, :feature_set_id, :integer
    add_column :users, :workflow_state, :string

    AddCustomerModel::TABLES.each do |table|
      add_column table, :user_id, :integer, foreign_key: true
    end
    create_table :test_groups_users do |t|
      t.column :test_group_id, :integer, null: false, foreign_key: true
      t.column :user_id, :integer, null: false, foreign_key: true
    end
  end

  def rollback
    execute <<-SQL
      UPDATE users 
        SET (#{AddCustomerModel::MIGRATED_COLUMNS})=(SELECT #{AddCustomerModel::MIGRATED_COLUMNS}
                                                       FROM customers 
                                                      WHERE customers.id=users.customer_id);
      INSERT INTO test_groups_users(user_id, test_group_id) 
           SELECT u.id, ctg.test_group_id 
             FROM customers_test_groups ctg JOIN users u ON u.customer_id=ctg.customer_id
    SQL

    TABLES.each do |table|
      execute <<-SQL
        UPDATE #{table} SET user_id=(SELECT id FROM users u WHERE u.customer_id=#{table}.customer_id)
      SQL
    end
    change_column_null :users, :customer_number, false
    change_column_null :users, :feature_set_id, false
    change_column_null :users, :brand, false
    change_column_null :users, :signup_device_type, false
  end
end
