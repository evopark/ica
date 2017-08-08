# frozen_string_literal: true

# Just a simple user model for the gem to referenc
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do
    end
  end
end
