# frozen_string_literal: true

# So we can differentiate between setup-phase and live systems
class AddWorkflowStateToGarageSystems < ActiveRecord::Migration[5.0]
  def change
    add_column :ica_garage_systems, :workflow_state, :string, null: false
  end
end
