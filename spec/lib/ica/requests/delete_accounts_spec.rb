# frozen_string_literal: true

require 'ica/requests/delete_accounts'

RSpec.describe ICA::Requests::DeleteAccounts do
  let(:garage_system) { create(:garage_system) }
  let(:account_mapping) { create(:customer_account_mapping, :uploaded, garage_system: garage_system) }
  subject { described_class.new(garage_system, [account_mapping]) }

  let(:expected_url) { "http://#{garage_system.hostname}/api/v1/accounts" }
  let(:http_status) { 204 }
  let!(:stub) { stub_request(:delete, expected_url).and_return(status: http_status) }

  it 'deletes the account from the remote system' do
    expect(subject.execute).to be_truthy
    expect(stub).to have_been_requested
  end

  context 'on success' do
    it 'destroys the local mapping' do
      expect(account_mapping).to receive(:destroy!)
      subject.execute
    end
  end

  context 'on failure' do
    let(:http_status) { 422 }
    it 'keeps local data' do
      expect(account_mapping).to_not receive(:destroy!)
      subject.execute
    end
  end
end
