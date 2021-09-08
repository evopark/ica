# frozen_string_literal: true

module ICA
  # Represents a {ParkingGarage}
  class Carpark < ICA::ApplicationRecord
    has_paper_trail class_name: ICA::Version.to_s

    belongs_to :parking_garage, class_name: ICA.parking_garage_class.to_s
    belongs_to :garage_system, class_name: 'ICA::GarageSystem', inverse_of: :carparks

    validates :parking_garage, presence: true
    validates :garage_system, presence: true

    delegate :name, to: :parking_garage, prefix: true

    # We don't use any internal identifiers for external communication
    validates :carpark_id, presence: true, uniqueness: { scope: :garage_system_id }
    scope :for_client, -> (client_id) do
      joins(:garage_system).merge ::ICA::GarageSystem.with_client_id(client_id)
    end
  end
end
