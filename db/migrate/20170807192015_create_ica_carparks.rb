# frozen_string_literal: true

class CreateICACarparks < ActiveRecord::Migration[5.0]
  def change
    create_table :ica_carparks do |t|
      t.integer :carpark_id, foreign_key: false
      t.integer :parking_garage_id, foreign_key: {
        references: ICA.parking_garage_class.table_name
      }
      t.integer :api_user_id, foreign_key: {
        references: :ica_api_users
      }
    end
  end
end
