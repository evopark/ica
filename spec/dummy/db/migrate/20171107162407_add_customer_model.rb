# frozen_string_literal: true

# Simulate the changes in the main application
class AddCustomerModel < ActiveRecord::Migration[5.0]
  TABLES = %i[addresses rfid_tags].freeze
  MIGRATED_COLUMNS = %i[customer_number brand feature_set_id workflow_state].freeze

  def change
    create_table :customers do |t|
      t.column :customer_number, :string, null: false
      t.column :workflow_state, :string, null: false
      t.column :feature_set_id, :integer, foreign_key: true
      t.column :brand, :user_brand, null: false, default: 'evopark'
    end
    add_column :users, :customer_id, :integer, foreign_key: true

    TABLES.each do |table|
      add_column table, :customer_id, :integer, foreign_key: true
    end

    create_table :customers_test_groups do |t|
      t.integer :test_group_id, foreign_key: true
      t.integer :customer_id, foreign_key: true
    end
  end

  def data
    columns = MIGRATED_COLUMNS.join(',')
    execute <<-SQL
      INSERT INTO customers (#{columns}) SELECT #{columns} FROM users;
      UPDATE users SET customer_id=(select id from customers c where c.customer_number=users.customer_number);
      INSERT INTO customers_test_groups(customer_id, test_group_id) 
        SELECT u.customer_id, tgu.test_group_id 
          FROM test_groups_users tgu JOIN users u ON u.id=tgu.user_id;
    SQL
    change_column_null :users, :customer_id, false

    TABLES.each do |table|
      execute <<-SQL
        UPDATE #{table} SET customer_id=(SELECT customer_id FROM users WHERE users.id=#{table}.user_id)
      SQL
    end

    # table structure will be cleaned in follow-up migration
  end

  def rollback
    execute <<-SQL
      UPDATE users SET (#{MIGRATED_COLUMNS})=(SELECT #{MIGRATED_COLUMNS} FROM customers WHERE customers.id=users.customer_id);
    SQL
  end
end
