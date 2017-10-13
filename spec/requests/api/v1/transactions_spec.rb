# frozen_string_literal: true

RSpec.describe ICA::Endpoints::V1::Transactions do
  let!(:garage_system) { create(:garage_system) }
  let(:facade_class) { ICA.garage_system_facade }
  let(:transaction_id) { SecureRandom.uuid }

  let!(:carpark) { create(:carpark, garage_system: garage_system) }
  let(:api_path) { "/v1/transactions/#{transaction_id}" }

  let(:customer_account_mapping) { create(:customer_account_mapping, garage_system: garage_system) }
  let(:card_account_mapping) { create(:card_account_mapping, customer_account_mapping: customer_account_mapping) }
  let(:rfid_tag) { card_account_mapping.rfid_tag }

  def fake_facade_response(success = true, result = {})
    {
      'success' => success,
      'result' => result
    }
  end

  shared_examples 'unknown media id' do |verb|
    let(:facade_response) { fake_facade_response(false, reason: :unknown_medium) }

    it 'returns status 422 and a message' do
      api_request(garage_system, verb, api_path, params)
      expect(last_response.status).to eq(422)
      expect(last_response.body).to include_json(Media: { MediaId: I18n.t('errors.messages.invalid') })
    end
  end

  describe 'PUT /transactions/:transaction_id' do
    let(:exited_at) { 1.second.ago }
    let(:entered_at) { 1.hour.ago }

    let(:basic_params) do
      {
        CarParkId: carpark.carpark_id,
        AccountKey: customer_account_mapping.account_key,
        Media: {
          MediaType: 255,
          MediaId: rfid_tag.tag_number
        },
        DriveIn: {
          DateTime: entered_at.iso8601,
          Status: 1
        }
      }
    end

    let(:basic_facade_args) do
      {
        vendor: :ica,
        transaction: {
          external_key: transaction_id,
          started_at: entered_at.change(usec: 0)
        },
        rfid_tag: { tag_number: rfid_tag.tag_number },
        garage: { id: carpark.parking_garage_id }
      }
    end
    let(:facade_response) { fake_facade_response(true) }

    context 'with unknown carpark id' do
      let(:params) { basic_params.merge(CarParkId: 404) }

      it 'returns 422' do
        api_request(garage_system, :put, api_path, params)
        expect(last_response.status).to eq(422)
      end
    end

    context 'with a newly started transaction' do
      let(:params) { basic_params.merge(Status: 0) }
      let(:expected_facade_args) { basic_facade_args }

      before do
        expect_any_instance_of(facade_class).to receive(:rfid_tag_enters_parking_garage!)
          .with(expected_facade_args)
          .and_return(facade_response)
      end

      it_behaves_like 'unknown media id', :put

      it 'returns 204' do
        api_request(garage_system, :put, api_path, params)
        expect(last_response.status).to eq(204)
      end
    end

    context 'with invalid params' do
      let(:params) { basic_params.merge(Media: { MediaType: 0 }) }

      it 'returns 422' do
        api_request(garage_system, :put, api_path, params)
        expect(last_response.status).to eq(422)
      end
    end

    context 'with unknown HTTP verb' do
      it 'returns 405' do
        api_request(garage_system, :post, api_path, basic_params)
        expect(last_response.status).to eq(405)
      end
    end

    context 'with a finished transaction' do
      let(:params) do
        basic_params.merge(Status: 1, DriveOut: {
                             DateTime: exited_at.iso8601,
                             Status: 1
                           },
                           Price: {
                             PriceGross: 12.34,
                             VatPercentage: 19.0,
                             Currency: 'EUR'
                           })
      end
      let(:expected_facade_args) do
        args = basic_facade_args.dup
        args[:transaction][:finished_at] = exited_at.change(usec: 0)
        args[:payment] = {
          amount: 12.34,
          currency: 'EUR',
          vat_rate: 0.19
        }
        args
      end

      before do
        expect_any_instance_of(facade_class).to receive(:finish_transaction!)
          .with(expected_facade_args)
          .and_return(facade_response)
      end

      it_behaves_like 'unknown media id', :put

      it 'returns 204' do
        api_request(garage_system, :put, api_path, params)
        expect(last_response.status).to eq(204)
      end
    end
  end

  describe 'PATCH /transactions/:transaction_id' do
    let(:exited_at) { 1.second.ago }
    let(:params) do
      {
        CarParkId: carpark.carpark_id,
        AccountKey: customer_account_mapping.account_key,
        Media: {
          MediaType: 255,
          MediaId: rfid_tag.tag_number
        },
        Status: 1,
        DriveOut: {
          DateTime: exited_at.iso8601,
          Status: 1
        },
        Price: {
          PriceGross: 12.34,
          VatPercentage: 19.0,
          Currency: 'EUR'
        }
      }
    end
    let(:expected_facade_args) do
      {
        vendor: :ica,
        transaction: {
          external_key: transaction_id,
          finished_at: exited_at.change(usec: 0)
        },
        rfid_tag: { tag_number: rfid_tag.tag_number },
        garage: { id: carpark.parking_garage_id },
        payment: {
          amount: 12.34,
          currency: 'EUR',
          vat_rate: 0.19
        }
      }
    end
    let(:facade_response) { fake_facade_response(true) }

    context 'with an exit to a started transaction' do
      let(:facade_response) { fake_facade_response(true) }

      before do
        expect_any_instance_of(facade_class).to receive(:finish_transaction!)
          .with(expected_facade_args)
          .and_return(facade_response)
      end

      it 'returns status 204' do
        api_request(garage_system, :put, api_path, params)
        expect(last_response.status).to eq(204)
      end

      it_behaves_like 'unknown media id', :patch
    end

    context 'with a cancellation update' do
      before { params[:DriveOut][:Status] = 103 }

      it 'returns status 204' do
        expect_any_instance_of(facade_class).to receive(:cancel_transaction!)
          .with(expected_facade_args)
          .and_return(facade_response)
        api_request(garage_system, :put, api_path, params)
        expect(last_response.status).to eq(204)
      end
    end
  end

  describe 'DELETE /transactions/:transaction_id' do
    let(:expected_facade_args) do
      {
        vendor: :ica,
        transaction: {
          external_key: transaction_id
        }
      }
    end

    before do
      expect_any_instance_of(facade_class).to receive(:cancel_transaction!)
        .with(hash_including(expected_facade_args))
        .and_return(facade_response)
    end

    context 'for an unbilled transaction' do
      let(:facade_response) { fake_facade_response(true) }
      it 'returns status 204' do
        api_request(garage_system, :delete, api_path)
        expect(last_response.status).to eq(204)
      end
    end

    context 'for an unknown transaction' do
      let(:facade_response) { fake_facade_response(false, reason: :parking_transaction_not_found) }

      it 'returns status 404' do
        api_request(garage_system, :delete, api_path)
        expect(last_response.status).to eq(404)
      end
    end

    context 'for a fully processed transaction' do
      let(:facade_response) { fake_facade_response(false) }
      it 'returns status 409' do
        api_request(garage_system, :delete, api_path)
        expect(last_response.status).to eq(409)
      end
    end
  end
end
