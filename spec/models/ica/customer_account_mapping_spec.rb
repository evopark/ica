# frozen_string_literal: true

module ICA
  RSpec.describe CustomerAccountMapping do
    subject { build(:account_customer_mapping) }

    it { is_expected.to belong_to(:user).class_name(ICA.user_class.to_s) }
    it { is_expected.to belong_to(:garage_system).class_name('ICA::GarageSystem') }
    it { is_expected.to have_many(:card_account_mappings).class_name('ICA::CardAccountMapping') }

    it { is_expected.to validate_presence_of(:garage_system) }

    describe '#account_key' do
      context 'empty on create' do
        before { subject.account_key = nil }
        it 'is auto-generated on validation' do
          subject.valid?
          expect(subject.account_key).to match(UUID_REGEX)
        end
      end
    end
  end
end
