# frozen_string_literal: true

module ICA::Admin
  # Configures the settings required for each parking garage
  class CarparksController < ICA::Admin::ApplicationController
    before_action :load_carpark, except: %i[new create index]

    def index
      respond_to do |format|
        format.json do
          render json: CarparksTable.new(view_context)
        end
        format.html
      end
    end

    def new
      if ICA::ParkingGarageService.unconfigured_parking_garages.any?
        @carpark = ICA::Carpark.new
      else
        flash[:alert] = 'There are no unconfigured parking garages with type ICA'
        redirect_to action: :index
      end
    end

    def create
      @carpark = ICA::Carpark.create(carpark_params)
      if @carpark.save
        redirect_to carpark_path(@carpark)
      else
        render(action: :new, status: 422)
      end
    end

    def destroy
      @carpark.destroy!
    end

    def update
      @carpark.attributes = carpark_params
      @carpark.save
      render action: :show
    end

    def show; end

    protected

    SETTINGS_PARAM = 'carpark'
    PERMITTED_ATTRIBUTES = %i[parking_garage_id carpark_id garage_system_id].freeze
    def carpark_params
      params.require(SETTINGS_PARAM).permit(*PERMITTED_ATTRIBUTES)
    end

    def load_carpark
      @carpark = ICA::Carpark.find(params[:id])
    end
  end
end
