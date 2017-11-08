# frozen_string_literal: true

require 'ica/requests/update_accounts'

RSpec.describe ICA::Requests::UpdateAccounts do
  let(:garage_system) { create(:garage_system) }
  let!(:customer_account_mapping1) do
    create(:customer_account_mapping, :uploaded, garage_system: garage_system)
  end
  let!(:card_account_mapping1) do
    create(:card_account_mapping, :uploaded, customer_account_mapping: customer_account_mapping1)
  end
  let!(:customer_account_mapping2) do
    create(:customer_account_mapping, garage_system: garage_system)
  end
  subject { described_class.new(garage_system, garage_system.customer_account_mappings) }

  let(:expected_url) { "http://#{garage_system.hostname}/api/v1/accounts" }
  let(:http_status) { 204 }

  let!(:stub) { stub_request(:patch, expected_url).and_return(status: http_status) }

  it 'sends streamed JSON with account data' do
    stub.with do |request|
      expect(request.headers).to include_json('Accept' => 'application/json')
      expect { JSON.parse(request.body) }.to_not raise_exception
    end
    expect(subject.execute).to be_truthy
    expect(stub).to have_been_requested
  end

  context 'on success' do
    it 'updates the upload timestamp for both account and card mapping' do
      Timecop.freeze(Time.now.change(usec: 0)) do
        subject.execute
        expect(customer_account_mapping1.reload.uploaded_at).to eq(Time.now)
        expect(card_account_mapping1.reload.uploaded_at).to eq(Time.now)
      end
    end
  end

  context 'on failure' do
    let(:http_status) { 422 }
    it 'does not touch the upload timestamp' do
      subject.execute
      expect(customer_account_mapping1.reload.uploaded_at).to eq(customer_account_mapping1.uploaded_at)
      expect(card_account_mapping1.reload.uploaded_at).to eq(card_account_mapping1.uploaded_at)
    end
  end
end
