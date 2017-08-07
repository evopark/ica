# frozen_string_literal: true

require 'base_datatable'

module ICA::Admin
  # Shows all configured garages
  class CarparksTable < BaseDatatable
    def render_record(carpark)
      {
        id: carpark.id,
        parking_garage_name: carpark.parking_garage_name,
        carpark_id: carpark.carpark_uid
      }
    end

    protected

    def column_to_sort(column_name)
      case column_name
      when 'carpark_iid' then 'carpark_iid'
      when 'parking_garage_name' then 'parking_garages.name'
      else raise ArgumentError, "Sorting by #{column_name} is not implemented"
      end
    end

    def filtered_query(search_string)
      base_query.where("#{garages_table}.name ILIKE :text", text: "%#{search_string}%")
    end

    def base_query
      ICA::Carpark.all.joins(:parking_garage).includes(:api_user)
    end

    def garages_table
      ICA.parking_garage_class.table_name
    end
  end
end
