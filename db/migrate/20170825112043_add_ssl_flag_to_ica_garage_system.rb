# frozen_string_literal: true

# Some/most systems go through IPSec tunnels and don't use SSL on the HTTP level
class AddSslFlagToICAGarageSystem < ActiveRecord::Migration[5.0]
  def change
    add_column :ica_garage_systems, :use_ssl, :boolean, default: false, null: false
  end
end
