# Adapts the host application's `garage_system_type` enum to include `ica` for all garages controlled by this gem
class AddICAParkingGarageType < ActiveRecord::Migration[5.0]
  disable_ddl_transaction! # enums cannot be altered from within a transaction

  def change
    execute <<-SQL
      ALTER TYPE parking_system_type ADD VALUE 'ica';
    SQL
  end
end
