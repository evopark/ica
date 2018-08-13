# frozen_string_literal: true

# Add timestamp column for acts_as_paranoid
class AddDeletedAtToICACustomerAccountMapping < ActiveRecord::Migration[5.0]
  def change
    add_column :ica_customer_account_mappings, :deleted_at, :timestamp
  end
end
