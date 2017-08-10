# frozen_string_literal: true

module ICA
  RSpec.describe CardAccountMapping do
    subject { build(:card_account_mapping) }

    it { is_expected.to belong_to(:customer_account_mapping).class_name('ICA::CustomerAccountMapping') }
    it { is_expected.to have_one(:garage_system).through(:customer_account_mapping) }

    it { is_expected.to validate_presence_of(:card_identifier) }

    describe '#card_key' do
      it 'is automatically generated on create' do
        subject.card_key = nil
        expect(subject).to be_valid
        expect(subject.card_key).to match(UUID_REGEX)
      end
    end
  end
end
