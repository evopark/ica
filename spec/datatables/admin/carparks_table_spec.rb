# frozen_string_literal: true

module ICA::Admin
  describe CarparksTable do
    let(:user) { build(:api_user) }
    let(:carpark) { build(:carpark, api_user: user) }

    let(:view_context) { ApplicationController.new.view_context }
    subject { described_class.new(view_context) }

    describe '#render_record' do
      let(:json) { subject.render_record(carpark) }
    end
  end
end
