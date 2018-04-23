# frozen_string_literal: true

# Add timestamp column for acts_as_paranoid
class AddDeletedAtToICACardAccountMapping < ActiveRecord::Migration[5.0]
  def change
    add_column :ica_card_account_mappings, :deleted_at, :timestamp
  end
end
