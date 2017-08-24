# frozen_string_literal: true

RSpec.describe ICA::Endpoints::V1::Cards do
  let(:garage_system) { create(:garage_system) }

  describe 'GET v1/cards/:card_key' do
    context 'for non-existing card key' do
      it 'returns 404' do
        api_request(garage_system, :get, "/v1/cards/#{SecureRandom.uuid}")
        expect(last_response.status).to eq(404)
      end
    end

    context 'for existing card key' do
      let(:customer_account_mapping) { create(:customer_account_mapping, garage_system: garage_system) }
      let!(:card_account_mapping) { create(:card_account_mapping, customer_account_mapping: customer_account_mapping) }

      it 'returns a JSON for that card' do
        api_request(garage_system, :get, "/v1/cards/#{card_account_mapping.card_key}")
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include_json(CardKey: card_account_mapping.card_key, Media: [])
      end
    end
  end

  describe 'POST v1/lock/cards/:card_key' do
    context 'for non-existing card key' do
      it 'returns 404' do
        api_request(garage_system, :post, "/v1/lock/cards/#{SecureRandom.uuid}")
        expect(last_response.status).to eq(404)
      end
    end

    context 'for existing card key' do
      let(:customer_account_mapping) { create(:customer_account_mapping, garage_system: garage_system) }
      let!(:card_account_mapping) { create(:card_account_mapping, customer_account_mapping: customer_account_mapping) }

      it 'returns 204' do
        garage_ids = Array.new(2) do
          create(:carpark, garage_system: garage_system, parking_garage: build(:parking_garage)).parking_garage_id
        end
        expect_any_instance_of(ICA.garage_system_facade).to receive(:block_rfid_tag).with(
          hash_including(rfid_tag: { id: card_account_mapping.rfid_tag_id },
                         garage_ids: garage_ids)
        )
        api_request(garage_system, :post, "/v1/lock/cards/#{card_account_mapping.card_key}")
        expect(last_response.status).to eq(204)
      end
    end
  end

  describe 'DELETE v1/lock/cards/:card_key' do
    context 'for non-existing card key' do
      it 'returns 404' do
        api_request(garage_system, :delete, "/v1/lock/cards/#{SecureRandom.uuid}")
        expect(last_response.status).to eq(404)
      end
    end

    context 'for existing card key' do
      let(:customer_account_mapping) { create(:customer_account_mapping, garage_system: garage_system) }
      let!(:card_account_mapping) { create(:card_account_mapping, customer_account_mapping: customer_account_mapping) }

      it 'returns 204' do
        garage_ids = Array.new(2) do
          create(:carpark, garage_system: garage_system, parking_garage: build(:parking_garage)).parking_garage_id
        end
        expect_any_instance_of(ICA.garage_system_facade).to receive(:unblock_rfid_tag).with(
          hash_including(rfid_tag: { id: card_account_mapping.rfid_tag_id },
                         garage_ids: garage_ids)
        )
        api_request(garage_system, :delete, "/v1/lock/cards/#{card_account_mapping.card_key}")
        expect(last_response.status).to eq(204)
      end
    end
  end
end
