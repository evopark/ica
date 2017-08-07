# frozen_string_literal: true

# Simplified parking garage model for the host application
class ParkingGarage < ActiveRecord::Base
  enum system_type: {
    evopark: 'evopark',
    ica: 'ica'
  }
end
