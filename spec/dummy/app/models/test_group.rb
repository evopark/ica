# frozen_string_literal: true

# Simulates the TestGroup model from the main application
class TestGroup < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :rfid_tags, through: :users
  has_and_belongs_to_many :operator_companies

  enum garage_status: { setup_only: 'setup_only', always: 'always' }

  ParkingGarage.system_types.each do |key, value|
    scope key, -> do
      where("ARRAY_LENGTH(system_types, 1) IS NULL OR '#{value}' = ANY(system_types)")
    end
  end

  scope :for_operator_company, ->(operator_company) do
    where('EXISTS (SELECT * FROM operator_companies_test_groups join_table '\
          'WHERE join_table.test_group_id=test_groups.id AND join_table.operator_company_id=?) '\
          'OR NOT EXISTS (SELECT * FROM operator_companies_test_groups join_table '\
          'WHERE join_table.test_group_id=test_groups.id)' ,
          operator_company.id)
  end
end
