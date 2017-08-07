# frozen_string_literal: true

module ICA
  # Provides functionality to work with the host application parking garage model
  class ParkingGarageService
    class << self
      def unconfigured_parking_garages
        garage_class = ICA.parking_garage_class
        garage_class.ica.where.not(
          "EXISTS (SELECT id FROM #{ICA::Carpark.table_name} carparks "\
          "WHERE carparks.parking_garage_id=#{garage_class.table_name}.id)"
        )
      end
    end
  end
end
