# frozen_string_literal: true

RSpec.describe 'API /v1/accounts' do
  let!(:garage_system) { create(:garage_system) }

  describe 'GET /:account_key' do
    context 'for a known key' do
      let!(:customer_account_mapping) do
        create(:customer_account_mapping,
               garage_system: garage_system,
               uploaded_at: 1.day.ago)
      end

      it 'returns the JSON for that account' do
        api_request(garage_system, :get, "/v1/accounts/#{customer_account_mapping.account_key}")
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include_json(AccountKey: customer_account_mapping.account_key)
      end
    end

    context 'for an unknown key' do
      it 'returns 404' do
        api_request(garage_system, :get, '/v1/accounts/5443934')
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'GET /' do
    let!(:customer_account_mappings) { create_list(:customer_account_mapping, 10, garage_system: garage_system) }

    it 'returns a JSON of all existing mappings' do
      api_request(garage_system, :get, '/v1/accounts')
      expect(last_response.status).to eq(200)
      expect { JSON.parse(last_response.body) }.to_not raise_exception
    end
  end
end
