# frozen_string_literal: true

RSpec.describe ICA::CustomerAccountService do
  let!(:garage_system) { create(:garage_system, last_account_sync_at: 2.weeks.ago) }
  let(:carpark) { create(:carpark, garage_system: garage_system, parking_garage: build(:parking_garage)) }

  describe '#outdated_accounts' do
    with_versioning do
      subject { described_class.new(garage_system).outdated_accounts }

      let(:unchanged_customer) { build(:customer) }
      let(:unchanged_customer_with_changed_address) { build(:customer) }
      let(:unchanged_customer_with_changed_rfid_tag) { build(:customer) }
      let(:customer_with_new_blocklist_entry) { build(:customer) }
      let(:customer_with_removed_blocklist_entry) { build(:customer) }
      let(:customer_with_changed_email) { build(:customer) }
      let(:customer_with_changed_feature_set_id) { build(:customer) }
      let(:customer_with_changed_brand) { build(:customer) }
      let(:customer_with_unrelated_changes) { build(:customer) }
      let(:blocked_rfid_tag) { build(:rfid_tag, :active, customer: customer_with_removed_blocklist_entry) }
      let(:removed_blocklist_entry) do
        build(:blocklist_entry, rfid_tag: blocked_rfid_tag,
                                parking_garage: carpark.parking_garage)
      end
      let(:customer_with_unchanged_blocklist_entry) { build(:customer) }
      let(:unchanged_blocked_rfid_tag) { build(:rfid_tag, :active, customer: customer_with_unchanged_blocklist_entry) }
      let(:unchanged_blocklist_entry) do
        build(:blocklist_entry, rfid_tag: unchanged_blocked_rfid_tag,
                                parking_garage: carpark.parking_garage)
      end

      before do
        Timecop.travel(1.month.ago) do
          unchanged_customer.save!
          create(:invoice_address, customer: unchanged_customer)
          create(:rfid_tag, customer: unchanged_customer)
          unchanged_customer_with_changed_address.save!
          create(:invoice_address, customer: unchanged_customer_with_changed_address)
          unchanged_customer_with_changed_rfid_tag.save!
          create(:rfid_tag, customer: unchanged_customer_with_changed_rfid_tag)
          customer_with_changed_email.save!
          customer_with_changed_feature_set_id.save!
          customer_with_changed_brand.save!
          customer_with_unrelated_changes.save!
          customer_with_new_blocklist_entry.save!
          create(:rfid_tag, :active, customer: customer_with_new_blocklist_entry)
          customer_with_removed_blocklist_entry.save!
          removed_blocklist_entry.save!
          unchanged_blocklist_entry.save!
        end

        Timecop.travel(1.week.ago) do
          unchanged_customer_with_changed_address.current_invoice_address.update(street: 'New Street 123')
          unchanged_customer_with_changed_rfid_tag.rfid_tags.first.update(workflow_state: 'inactive')
          customer_with_changed_email.user.update(email: 'new-email@evopark.de')
          customer_with_changed_feature_set_id.update(feature_set_id: 11)
          customer_with_changed_brand.update(brand: 'easy_to_park')
          customer_with_unrelated_changes.update(customer_number: '00123')
          create(:blocklist_entry,
                 rfid_tag: customer_with_new_blocklist_entry.rfid_tags.first,
                 parking_garage: carpark.parking_garage)
          removed_blocklist_entry.destroy!
        end

        Customer.all.find_each do |customer|
          create(:customer_account_mapping, customer: customer, garage_system: garage_system, uploaded_at: 3.weeks.ago)
        end
      end

      def account_mapping_for(customer)
        garage_system.customer_account_mappings.find_by(customer: customer).tap do |mapping|
          expect(mapping).to be_present
        end
      end

      it 'returns an ActiveRecord::Relation of ICA::CustomerAccountMapping' do
        expect(subject).to be_a(ActiveRecord::Relation)
        expect(subject.model).to eq(ICA::CustomerAccountMapping)
      end

      it 'includes account mappings for customers with changed addresses' do
        expect(subject).to include(account_mapping_for(unchanged_customer_with_changed_address))
      end

      it 'includes account mappings for customers with changed RFID tags' do
        expect(subject).to include(account_mapping_for(unchanged_customer_with_changed_rfid_tag))
      end

      it 'includes account mappings for customers with changed email address' do
        expect(subject).to include(account_mapping_for(customer_with_changed_email))
      end

      it 'includes account mappings for customers with changed feature set' do
        expect(subject).to include(account_mapping_for(customer_with_changed_feature_set_id))
      end

      it 'includes account mappings for customers with changed brand' do
        expect(subject).to include(account_mapping_for(customer_with_changed_brand))
      end

      it 'includes account mappings for customers with new blocklist entries' do
        expect(subject).to include(account_mapping_for(customer_with_new_blocklist_entry))
      end

      it 'includes account mappings for customers with removed blocklist entries' do
        expect(subject).to include(account_mapping_for(customer_with_removed_blocklist_entry))
      end

      it 'does not include account mappings for customers with unrelated changes' do
        expect(subject).to_not include(account_mapping_for(customer_with_unrelated_changes))
      end

      it 'does not include account mappings for unchanged customers' do
        expect(subject).to_not include(account_mapping_for(unchanged_customer))
      end

      it 'does not include account mappings for customers with unchanged blocklist entries' do
        expect(subject).to_not include(account_mapping_for(customer_with_unchanged_blocklist_entry))
      end
    end
  end
end
