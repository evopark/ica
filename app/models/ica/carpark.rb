# frozen_string_literal: true

module ICA
  # Represents a {ParkingGarage}
  class Carpark < ApplicationRecord
    has_paper_trail class_name: ICA::Version.to_s

    belongs_to :parking_garage, class_name: ICA.parking_garage_class.to_s
    belongs_to :api_user, class_name: ApiUser.to_s, inverse_of: :carparks

    validates :parking_garage, presence: true
    validates :api_user, presence: true

    delegate :name, to: :parking_garage, prefix: true

    # We don't use any internal identifiers for external communication
    validates :carpark_id, presence: true, uniqueness: { scope: :api_user_id }
  end
end
