# frozen_string_literal: true

module ICA
  RSpec.describe Carpark do
    subject { build(:carpark) }

    it { is_expected.to be_versioned }
    it { is_expected.to be_a(ICA::ApplicationRecord) }

    it {
      is_expected.to validate_uniqueness_of(:carpark_id)
        .scoped_to(:garage_system_id)
    }

    it { is_expected.to belong_to(:garage_system).class_name('ICA::GarageSystem') }
    it { is_expected.to validate_presence_of(:garage_system) }

    it { is_expected.to belong_to(:parking_garage).class_name('ParkingGarage') }
    it { is_expected.to validate_presence_of(:parking_garage) }

    it { is_expected.to delegate_method(:name).to(:parking_garage).with_prefix }
  end
end
