# frozen_string_literal: true

# Simulate the test group structure from the main application
class CreateTestGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :test_groups do |t|
      t.string :garage_status, null: false
      t.column :system_types, :parking_system_type, array: true, default: '{}'
      t.timestamps
    end

    create_table :test_groups_users do |t|
      t.integer :user_id, null: false, foreign_key: { references: :users }
      t.integer :test_group_id, null: false, foreign_key: { references: :test_groups }
    end

    create_table :operator_companies do |t|
      t.timestamps
    end
    add_column :parking_garages, :operator_company_id, :integer, foreign_key: { references: :operator_companies }

    create_table :operator_companies_test_groups do |t|
      t.integer :test_group_id, null: false, foreign_key: { references: :test_groups }
      t.integer :operator_company_id, null: false, foreign_key: { references: :operator_companies }
    end
  end
end
