# frozen_string_literal: true

require 'base_datatable'

module ICA::Admin
  # Shows all configured garages
  class CarparksTable < BaseDatatable
    def render_record(carpark)
      {
        id: carpark.id,
        parking_garage_name: carpark.parking_garage_name,
        garage_system_client_id: carpark.garage_system.client_id,
        carpark_id: carpark.carpark_uid
      }
    end

    protected

    def column_to_sort(column_name)
      case column_name
      when 'carpark_id' then 'carpark_id'
      when 'parking_garage_name' then "#{garages_table}.name"
      when 'garage_system_client_id' then "#{ICA::GarageSystems.table_name}.client_id"
      else raise ArgumentError, "Sorting by #{column_name} is not implemented"
      end
    end

    def filtered_query(search_string)
      base_query.where("#{garages_table}.name ILIKE :text", text: "%#{search_string}%")
    end

    def base_query
      ICA::Carpark.all.joins(:parking_garage).includes(:garage_system)
    end

    def garages_table
      ICA.parking_garage_class.table_name
    end
  end
end
