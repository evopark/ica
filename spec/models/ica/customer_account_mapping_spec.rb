# frozen_string_literal: true

module ICA
  RSpec.describe CustomerAccountMapping do
    subject { build(:customer_account_mapping) }

    it { is_expected.to have_attribute(:uploaded_at) }
    it { is_expected.to respond_to(:uploaded?) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:garage_system).class_name('ICA::GarageSystem') }
    it { is_expected.to have_many(:card_account_mappings).class_name('ICA::CardAccountMapping').dependent(:destroy) }

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

    describe '#to_json_hash' do
      context 'for easy-to-park users' do
        before { subject.user.brand = 'easy_to_park' }
        context 'in easy-to-park systems' do
          before { subject.garage_system.variant = 'easy_to_park' }

          it 'contains the full address information' do
            user = subject.user
            address = subject.user.current_invoice_address
            expect(subject.to_json_hash).to include_json(
              Customer: {
                CustomerNo: user.customer_number,
                FirstName: address.first_name,
                LastName: address.last_name,
                PostalCode: address.zip_code,
                Location: address.city,
                Street: address.street,
                EmailAddress: user.email
              }
            )
          end

          it 'properly encodes address gender' do
            subject.user.current_invoice_address.gender = 'male'
            expect(subject.to_json_hash).to include_json(Customer: { Gender: 1 })
            subject.user.current_invoice_address.gender = 'female'
            expect(subject.to_json_hash).to include_json(Customer: { Gender: 2 })
          end

          context 'with academic title is present' do
            before { subject.user.current_invoice_address.academic_title = 'dr' }
            it 'is used as salutation' do
              expected_value = subject.user.current_invoice_address.translate_enum(:academic_title)
              expect(subject.to_json_hash).to include_json(Customer: { Title: expected_value })
            end
          end

          context 'without academic title' do
            it 'uses gender to determine salutation' do
              expected_value = subject.user.current_invoice_address.translate_enum(:gender)
              expect(subject.to_json_hash).to include_json(Customer: { Title: expected_value })
            end
          end
        end
      end

      context 'for non-easy-to-park users' do
        before { subject.user.brand = 'evopark' }

        it 'contains no address information' do
          expect(subject.to_json_hash).to_not include_json(Customer: {})
        end
      end

      it 'contains the account key' do
        expect(subject.to_json_hash).to include_json(AccountKey: subject.account_key)
      end

      it 'contains card information' do
        card_account_mappings = create_list(:card_account_mapping, 2, customer_account_mapping: subject)
        expect(subject.to_json_hash).to include_json(Card: card_account_mappings.map(&:to_json_hash))
      end
    end
  end
end
