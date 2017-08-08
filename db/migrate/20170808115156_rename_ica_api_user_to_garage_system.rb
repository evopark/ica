# frozen_string_literal: true

# It is more appropriate after all since it needs more information than just authentication
class RenameICAApiUserToGarageSystem < ActiveRecord::Migration[5.0]
  def change
    rename_table :ica_api_users, :ica_garage_systems
    rename_column :ica_carparks, :api_user_id, :garage_system_id
    add_column :ica_garage_systems, :description, :text
  end
end
