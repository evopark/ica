# frozen_string_literal: true

module ICA
  RSpec.describe AccountCustomerMapping do
    UUID_REGEX = /\A[0-9a-f]{8}-?[0-9a-f]{4}-?[1-5][0-9a-f]{3}-?[89ab][0-9a-f]{3}-?[0-9a-f]{12}\Z/i

    subject { build(:account_customer_mapping) }

    describe '#account_key' do
      context 'empty on create' do
        before { subject.account_key = nil }
        it 'is auto-generated on validation' do
          subject.valid?
          expect(subject.account_key).to match(UUID_REGEX)
        end
      end
    end

    it { is_expected.to belong_to(:user).class_name(ICA.user_class.to_s) }
    it { is_expected.to belong_to(:garage_system).class_name('ICA::GarageSystem') }
  end
end
