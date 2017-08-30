# frozen_string_literal: true

# Just got word that the API doesn't begin with /ica after all...
class AddPathPrefixToICAGarageSystems < ActiveRecord::Migration[5.0]
  def change
    add_column :ica_garage_systems, :path_prefix, :string
  end
end
