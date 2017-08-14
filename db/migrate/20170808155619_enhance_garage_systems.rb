# frozen_string_literal: true

# So we can differentiate between setup-phase and live systems
class EnhanceGarageSystems < ActiveRecord::Migration[5.0]
  def change
    add_column :ica_garage_systems, :workflow_state, :string, null: false
    add_column :ica_garage_systems, :last_account_sync_at, :timestamp
    add_column :ica_garage_systems, :hostname, :string, null: false
    add_column :ica_garage_systems, :variant, :ica_garage_system_variant, null: false
  end
end
