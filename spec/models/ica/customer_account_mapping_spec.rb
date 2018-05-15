# frozen_string_literal: true

module ICA
  RSpec.describe CustomerAccountMapping do
    subject { build(:customer_account_mapping) }

    it { is_expected.to have_attribute(:uploaded_at) }
    it { is_expected.to respond_to(:uploaded?) }

    it { is_expected.to respond_to(:deleted_at) }

    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:garage_system).class_name('ICA::GarageSystem') }
    it { is_expected.to have_many(:card_account_mappings).class_name('ICA::CardAccountMapping').dependent(:destroy) }
    it { is_expected.to have_many(:rfid_tags).through(:card_account_mappings) }

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
      context 'for easy-to-park customers' do
        before { subject.customer.brand = 'easy_to_park' }
        context 'in easy-to-park systems' do
          before { subject.garage_system.variant = 'easy_to_park' }

          it 'contains the full address information' do
            customer = subject.customer
            address = subject.customer.current_invoice_address
            expect(subject.to_json_hash).to include_json(
              Customer: {
                CustomerNo: customer.customer_number,
                FirstName: address.first_name,
                LastName: address.last_name,
                PostalCode: address.zip_code,
                Location: address.city,
                Street: address.street,
                EmailAddress: customer.user.email
              }
            )
          end

          it 'properly encodes address gender' do
            subject.customer.current_invoice_address.gender = 'male'
            expect(subject.to_json_hash).to include_json(Customer: { Gender: 1 })
            subject.customer.current_invoice_address.gender = 'female'
            expect(subject.to_json_hash).to include_json(Customer: { Gender: 2 })
          end

          context 'with academic title is present' do
            before { subject.customer.current_invoice_address.academic_title = 'dr' }
            it 'is used as salutation' do
              expected_value = subject.customer.current_invoice_address.translate_enum(:academic_title)
              expect(subject.to_json_hash).to include_json(Customer: { Title: expected_value })
            end
          end

          context 'without academic title' do
            it 'uses gender to determine salutation' do
              expected_value = subject.customer.current_invoice_address.translate_enum(:gender)
              expect(subject.to_json_hash).to include_json(Customer: { Title: expected_value })
            end
          end
        end
      end

      context 'for non-easy-to-park customers' do
        before { subject.customer.brand = 'evopark' }
        let(:customer_data) { subject.to_json_hash[:Customer] }

        context 'without associated card' do
          it 'is empty' do
            expect(customer_data).to be_empty
          end
        end

        context 'with associated card' do
          let!(:card_account_mapping) { create(:card_account_mapping, customer_account_mapping: subject) }
          let(:rfid_tag) { card_account_mapping.rfid_tag }

          it 'contains the card number' do
            expect(customer_data).to include_json(CustomerNo: rfid_tag.tag_number, LastName: rfid_tag.tag_number)
          end
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
