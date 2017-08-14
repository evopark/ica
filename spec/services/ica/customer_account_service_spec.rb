# frozen_string_literal: true

RSpec.describe ICA::CustomerAccountService do
  let!(:garage_system) { create(:garage_system, last_account_sync_at: 2.weeks.ago) }
  let(:carpark) { create(:carpark, garage_system: garage_system, parking_garage: build(:parking_garage)) }

  describe '#outdated_accounts' do
    with_versioning do
      subject { described_class.new(garage_system).outdated_accounts }

      let(:unchanged_user) { build(:user) }
      let(:unchanged_user_with_changed_address) { build(:user) }
      let(:unchanged_user_with_changed_rfid_tag) { build(:user) }
      let(:user_with_new_blocklist_entry) { build(:user) }
      let(:user_with_removed_blocklist_entry) { build(:user) }
      let(:user_with_changed_email) { build(:user) }
      let(:user_with_changed_feature_set_id) { build(:user) }
      let(:user_with_changed_brand) { build(:user) }
      let(:user_with_unrelated_changes) { build(:user) }
      let(:blocked_rfid_tag) { build(:rfid_tag, :active, user: user_with_removed_blocklist_entry) }
      let(:removed_blocklist_entry) do
        build(:blocklist_entry, rfid_tag: blocked_rfid_tag,
                                parking_garage: carpark.parking_garage)
      end
      let(:user_with_unchanged_blocklist_entry) { build(:user) }
      let(:unchanged_blocked_rfid_tag) { build(:rfid_tag, :active, user: user_with_unchanged_blocklist_entry) }
      let(:unchanged_blocklist_entry) do
        build(:blocklist_entry, rfid_tag: unchanged_blocked_rfid_tag,
                                parking_garage: carpark.parking_garage)
      end

      before do
        Timecop.travel(1.month.ago) do
          unchanged_user.save!
          create(:invoice_address, user: unchanged_user)
          create(:rfid_tag, user: unchanged_user)
          unchanged_user_with_changed_address.save!
          create(:invoice_address, user: unchanged_user_with_changed_address)
          unchanged_user_with_changed_rfid_tag.save!
          create(:rfid_tag, user: unchanged_user_with_changed_rfid_tag)
          user_with_changed_email.save!
          user_with_changed_feature_set_id.save!
          user_with_changed_brand.save!
          user_with_unrelated_changes.save!
          user_with_new_blocklist_entry.save!
          create(:rfid_tag, :active, user: user_with_new_blocklist_entry)
          user_with_removed_blocklist_entry.save!
          removed_blocklist_entry.save!
          unchanged_blocklist_entry.save!
        end

        Timecop.travel(1.week.ago) do
          unchanged_user_with_changed_address.current_invoice_address.update(street: 'New Street 123')
          unchanged_user_with_changed_rfid_tag.rfid_tags.first.update(workflow_state: 'inactive')
          user_with_changed_email.update(email: 'new-email@evopark.de')
          user_with_changed_feature_set_id.update(feature_set_id: 11)
          user_with_changed_brand.update(brand: 'easy_to_park')
          user_with_unrelated_changes.update(customer_number: '00123')
          create(:blocklist_entry,
                 rfid_tag: user_with_new_blocklist_entry.rfid_tags.first,
                 parking_garage: carpark.parking_garage)
          removed_blocklist_entry.destroy!
        end

        User.all.find_each do |user|
          create(:customer_account_mapping, user: user, garage_system: garage_system, uploaded_at: 3.weeks.ago)
        end
        # simulate paper trail from the real application
        PaperTrail::Version.where(item_type: 'User').update_all(item_type: 'BaseUser')
      end

      def account_mapping_for(user)
        garage_system.customer_account_mappings.find_by(user: user).tap do |mapping|
          expect(mapping).to be_present
        end
      end

      it 'returns an ActiveRecord::Relation of ICA::CustomerAccountMapping' do
        expect(subject).to be_a(ActiveRecord::Relation)
        expect(subject.model).to eq(ICA::CustomerAccountMapping)
      end

      it 'includes account mappings for users with changed addresses' do
        expect(subject).to include(account_mapping_for(unchanged_user_with_changed_address))
      end

      it 'includes account mappings for users with changed RFID tags' do
        expect(subject).to include(account_mapping_for(unchanged_user_with_changed_rfid_tag))
      end

      it 'includes account mappings for users with changed email address' do
        expect(subject).to include(account_mapping_for(user_with_changed_email))
      end

      it 'includes account mappings for users with changed feature set' do
        expect(subject).to include(account_mapping_for(user_with_changed_feature_set_id))
      end

      it 'includes account mappings for users with changed brand' do
        expect(subject).to include(account_mapping_for(user_with_changed_brand))
      end

      it 'includes account mappings for users with new blocklist entries' do
        expect(subject).to include(account_mapping_for(user_with_new_blocklist_entry))
      end

      it 'includes account mappings for users with removed blocklist entries' do
        expect(subject).to include(account_mapping_for(user_with_removed_blocklist_entry))
      end

      it 'does not include account mappings for users with unrelated changes' do
        expect(subject).to_not include(account_mapping_for(user_with_unrelated_changes))
      end

      it 'does not include account mappings for unchanged users' do
        expect(subject).to_not include(account_mapping_for(unchanged_user))
      end

      it 'does not include account mappings for users with unchanged blocklist entries' do
        expect(subject).to_not include(account_mapping_for(user_with_unchanged_blocklist_entry))
      end
    end
  end
end
