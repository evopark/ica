# frozen_string_literal: true

module ICA
  RSpec.describe CardAccountMapping do
    subject { build(:card_account_mapping) }

    it { is_expected.to have_attribute(:uploaded_at) }
    it { is_expected.to respond_to(:uploaded?) }

    it { is_expected.to belong_to(:customer_account_mapping).class_name('ICA::CustomerAccountMapping') }
    it { is_expected.to belong_to(:rfid_tag) }
    it { is_expected.to have_one(:garage_system).through(:customer_account_mapping) }
    it { is_expected.to have_one(:customer).through(:customer_account_mapping) }

    it { is_expected.to validate_presence_of(:customer_account_mapping) }

    describe '#card_key' do
      it 'is automatically generated on create' do
        subject.card_key = nil
        expect(subject).to be_valid
        expect(subject.card_key).to match(UUID_REGEX)
      end
    end

    describe '#to_json_hash' do
      let(:garage_system) { build(:garage_system) }
      let(:customer_account_mapping) { create(:customer_account_mapping, garage_system: garage_system) }

      before { subject.customer_account_mapping = customer_account_mapping }

      it 'includes the CardKey' do
        expect(subject.to_json_hash).to include_json(CardKey: subject.card_key)
      end

      it 'includes the tag number in media type 255' do
        expect(subject.to_json_hash[:Media]).to include(MediaType: 255, MediaId: subject.rfid_tag.tag_number)
      end

      it 'includes the UID in media type 1' do
        expect(subject.to_json_hash[:Media]).to include(MediaType: 1, MediaId: subject.rfid_tag.uid)
      end

      context 'with LEGIC prime add-on' do
        let!(:legic_addon) { create(:parking_card_add_on, provider: 'legic_prime', rfid_tag: subject.rfid_tag) }

        it 'is included with media type 31' do
          expect(subject.to_json_hash[:Media]).to include(MediaType: 31, MediaId: legic_addon.identifier)
        end
      end

      context 'with another add-on' do
        let!(:shell_addon) { create(:parking_card_add_on, provider: 'shell', rfid_tag: subject.rfid_tag) }

        it 'is not included' do
          expect(subject.to_json_hash[:Media].map { |m| m[:MediaType] }).to match_array([1, 255])
        end
      end

      it 'sets CardVariant to 0 for regular cards' do
        expect(subject.to_json_hash).to include_json(CardVariant: 0)
      end

      it 'sets Blocked to 0 for unblocked cards' do
        expect(subject.to_json_hash).to include_json(Blocked: 0)
      end

      context 'with a blocklist entry to an associated garage' do
        before do
          carpark = create(:carpark, garage_system: subject.garage_system)
          create(:blocklist_entry, rfid_tag: subject.rfid_tag, parking_garage: carpark.parking_garage)
        end

        it 'sets Blocked to 1' do
          expect(subject.to_json_hash).to include_json(Blocked: 1)
        end
      end

      context 'in a test group' do
        before do
          carpark = create(:carpark, garage_system: subject.garage_system)
          test_group = create(:test_group, operator_companies: [carpark.parking_garage.operator_company])
          test_group.customers << subject.customer
        end

        it 'sets CardVariant to 1' do
          expect(subject.to_json_hash).to include_json(CardVariant: 1)
        end
      end
    end
  end
end
