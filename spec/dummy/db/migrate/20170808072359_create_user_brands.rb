# frozen_string_literal: true

# Basic User and RfidTag models for the gem to reference
class CreateUserBrands < ActiveRecord::Migration[5.0]
  disable_ddl_transaction! # types cannot be created from within a transaction

  def change
    execute <<-SQL
      CREATE TYPE user_brand AS ENUM('evopark', 'easy_to_park');
    SQL
  end
end
