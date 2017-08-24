# frozen_string_literal: true
class AddICAGarageSystemVariant < ActiveRecord::Migration[5.0]
  disable_ddl_transaction! # types cannot be created from within a transaction

  def change
    execute <<-SQL
      CREATE TYPE ica_garage_system_variant AS ENUM('easy_to_park', 'ica');
    SQL
  end
end
