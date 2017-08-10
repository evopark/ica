# frozen_string_literal: true

# No future code, only a simple, Easy-To-Park-specific flag...
class AddExposeEasyToParkToGarageSystems < ActiveRecord::Migration[5.0]
  def change
    add_column :ica_garage_systems, :expose_easy_to_park, :boolean, default: false, null: false
  end
end
