# frozen_string_literal: true

RSpec.describe ICA::Requests::CreateAccounts do
  let(:garage_system) { create(:garage_system) }
  let!(:customer_account_mapping1) { create(:customer_account_mapping, garage_system: garage_system) }
  let!(:customer_account_mapping2) { create(:customer_account_mapping, garage_system: garage_system) }
  let(:expected_url) { "https://#{garage_system.hostname}/api/v1/accounts" }

  shared_examples 'valid account request' do
    it 'uses chunked transfer encoding' do
      expected_headers = { 'Transfer-Encoding' => 'chunked' }
      stub_request(expected_http_verb, expected_url).with(headers: expected_headers).and_return(status: 204)
      expect(subject.execute).to be_truthy
    end

    it 'provides and accepts JSON' do
      expected_headers = { 'Accept' => %r{\Aapplication/json},
                           'Content-Type' => %r{\Aapplication/json} }
      stub_request(expected_http_verb, expected_url).with(headers: expected_headers).and_return(status: 204)
      expect(subject.execute).to be_truthy
    end

    it 'sends valid JSON with account data' do
      stub_request(expected_http_verb, expected_url).with do |request|
        expect(request.body).to be_a(Enumerable)
      end.to_return(status: 204)
      expect(subject.execute).to be_truthy
    end
  end

  context 'when passing all mappings' do
    let(:expected_http_verb) { :put }
    subject { described_class.new(garage_system, garage_system.customer_account_mappings) }

    it_behaves_like 'valid account request'
  end

  context 'for a subset of mappings' do
    let(:expected_http_verb) { :post }
    subject { described_class.new(garage_system, garage_system.customer_account_mappings.limit(1)) }

    it_behaves_like 'valid account request'
  end
end
