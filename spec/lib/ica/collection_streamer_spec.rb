# frozen_string_literal: true

RSpec.describe ICA::CollectionStreamer do
  let(:garage_system) { create(:garage_system) }
  let!(:customer_account_mapping1) { create(:customer_account_mapping, garage_system: garage_system) }
  let!(:customer_account_mapping2) { create(:customer_account_mapping, garage_system: garage_system) }
  let(:target_collection) { garage_system.customer_account_mappings }

  subject { described_class.new(target_collection) }

  it { is_expected.to respond_to(:each) }
  it { is_expected.to be_a(Enumerable) }

  it 'yields the whole collection as valid JSON by calling `to_json_hash`' do
    result = subject.reduce('') { |a, e| a + e }
    parsed = nil
    expect { parsed = JSON.parse(result) }.to_not raise_exception
    expect(parsed).to include_json([
                                     { AccountKey: customer_account_mapping1.account_key },
                                     { AccountKey: customer_account_mapping2.account_key }
                                   ])
  end
end
