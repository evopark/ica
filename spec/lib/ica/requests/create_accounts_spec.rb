# frozen_string_literal: true

RSpec.describe ICA::Requests::CreateAccounts do
  let(:garage_system) { create(:garage_system) }

  let(:customer_account_mapping1) { create(:customer_account_mapping, garage_system: garage_system) }
  # accounts w/o cards will be ignored, so we need some cards
  let!(:card_account_mapping1) { create(:card_account_mapping, customer_account_mapping: customer_account_mapping1) }

  let(:customer_account_mapping2) { create(:customer_account_mapping, garage_system: garage_system) }
  let!(:card_account_mapping2) { create(:card_account_mapping, customer_account_mapping: customer_account_mapping2) }

  let(:expected_url) { "http://#{garage_system.hostname}/api/v1/accounts" }
  let!(:stub) { stub_request(expected_http_verb, expected_url).with(headers: expected_headers).and_return(status: 204) }
  let(:expected_headers) { { 'Transfer-Encoding' => 'chunked' } }

  shared_examples 'valid account request' do
    it 'uses chunked transfer encoding' do
      expect(subject.execute).to be_truthy
    end

    it 'provides and accepts JSON' do
      expected_headers.merge!('Accept' => %r{\Aapplication/json},
                              'Content-Type' => %r{\Aapplication/json})
      expect(subject.execute).to be_truthy
    end

    it 'sends valid JSON with account data' do
      stub.with do |request|
        expect(request.body).to be_a(ICA::CollectionStreamer)
      end
      expect(subject.execute).to be_truthy
      expect(stub).to have_been_requested
    end

    it 'contains a signature' do
      Timecop.freeze do
        stub_request(expected_http_verb, expected_url).with do |request|
          expect(request.headers['Clientid']).to eq(garage_system.client_id)
          expect(request.headers['Authkey']).to eq(garage_system.auth_key)
          expect(request.headers['Localtime']).to eq(Time.now.iso8601)
          expect(request.headers['Signature']).to match(/\A\w{64}\Z/)
        end.to_return(status: 204)
        expect(subject.execute).to be_truthy
      end
    end

    it 'sets the updated_at timestamp of all mappings' do
      Timecop.freeze(Time.now.change(usec: 0)) do
        subject.execute
        expect(customer_account_mapping1.reload.uploaded_at).to eq(Time.now)
        expect(card_account_mapping1.reload.uploaded_at).to eq(Time.now)
      end
    end
  end

  context 'when passing all mappings' do
    let(:expected_http_verb) { :put }
    # regression test to avoid duplicates for users w/ multiple cards
    let!(:card_account_mapping3) { create(:card_account_mapping, customer_account_mapping: customer_account_mapping1) }

    subject { described_class.new(garage_system, garage_system.customer_account_mappings.not_uploaded) }

    it_behaves_like 'valid account request'
  end

  context 'for a subset of mappings' do
    let(:expected_http_verb) { :post }
    subject do
      described_class.new(garage_system, garage_system.customer_account_mappings
                                                      .where('ica_customer_account_mappings.id < ?', customer_account_mapping2.id))
    end

    it_behaves_like 'valid account request'
  end
end
