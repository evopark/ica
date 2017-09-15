# frozen_string_literal: true

require 'ica/requests/delete_cards'

RSpec.describe ICA::Requests::DeleteCards do
  let(:garage_system) { create(:garage_system) }
  let(:card_mapping) { create(:card_account_mapping, :uploaded, garage_system: garage_system) }
  subject { described_class.new(garage_system, [card_mapping]) }

  let(:expected_url) { "http://#{garage_system.hostname}/api/v1/cards" }
  let(:http_status) { 204 }
  let!(:stub) { stub_request(:delete, expected_url).and_return(status: http_status) }

  it 'deletes the card from the remote system' do
    expect(subject.execute).to be_truthy
    expect(stub).to have_been_requested
  end

  context 'on success' do
    it 'destroys the local mapping' do
      expect(card_mapping).to receive(:destroy!)
      subject.execute
    end
  end

  context 'on failure' do
    let(:http_status) { 422 }
    it 'keeps local data' do
      expect(card_mapping).to_not receive(:destroy!)
      subject.execute
    end
  end
end
