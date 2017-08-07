# A simplified garage model: just so that it can be referenced from the gem
class CreateParkingGarages < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute "CREATE TYPE parking_system_type AS ENUM('snb_customer_media', 'snb_econnect', 'skidata_svp4')"
        create_table :parking_garages, force: true do |t|
          t.string :name
          t.column :system_type, :parking_system_type, null: false
          t.timestamps
        end
      end

      dir.down do
        drop_table :parking_garages
        execute 'DROP TYPE parking_system_type'
      end
    end
  end
end
