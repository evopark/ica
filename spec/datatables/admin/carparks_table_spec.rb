# frozen_string_literal: true

module ICA::Admin
  describe CarparksTable do
    let(:garage_system) { build(:garage_system) }
    let(:carpark) { build(:carpark, garage_system: garage_system) }

    let(:view_context) { ApplicationController.new.view_context }
    subject { described_class.new(view_context) }

    describe '#render_record' do
      let(:json) { subject.render_record(carpark) }
    end
  end
end
