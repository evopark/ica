# frozen_string_literal: true

RSpec.describe ICA::Endpoints::V1::Command do
  let!(:garage_system) { create(:garage_system) }
  let(:facade_class) { ICA.garage_system_facade }

  describe 'POST /command' do
    it 'can trigger a full sync for the system' do
      api_request(garage_system, :post, '/v1/command', Command: 1)
      expect(ICA::FullAccountUpload).to have_enqueued_sidekiq_job(garage_system.id)
    end
  end

  describe 'GET /command' do
    it 'notifies the facade about garage activity' do
      carparks = Array.new(2) do
        create(:carpark, garage_system: garage_system, parking_garage: build(:parking_garage))
      end
      expected_facade_args = hash_including(vendor: :ica, garage_ids: carparks.map(&:parking_garage_id))
      expect_any_instance_of(facade_class).to receive(:ping).with(expected_facade_args).and_return(success: true)
      api_request(garage_system, :get, '/v1/command')
    end
  end
end
