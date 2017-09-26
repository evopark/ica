# frozen_string_literal: true

RSpec.describe ICA::GarageSystemService do
  let(:garage_system) { create(:garage_system) }
  subject { described_class.new(garage_system) }

  describe '#create_missing_mappings' do
    context 'with inactive or blocked cards' do
      let!(:active_tag) { create(:rfid_tag, :active, user: build(:user)) }
      let!(:inactive_tag) { create(:rfid_tag, :inactive, user: build(:user)) }
      let(:blocked_tag) { create(:rfid_tag, :active, user: build(:user)) }
      let!(:blocklist_entry) { create(:blocklist_entry, rfid_tag: blocked_tag, parking_garage: build(:parking_garage)) }
      let!(:carpark) { create(:carpark, garage_system: garage_system, parking_garage: blocklist_entry.parking_garage) }
      let(:tag_with_existing_mappings) { create(:rfid_tag, :active, user: build(:user)) }
      let(:existing_account_mapping) do
        create(:customer_account_mapping, garage_system: garage_system, user: tag_with_existing_mappings.user)
      end
      let!(:existing_card_mapping) do
        create(:card_account_mapping, garage_system: garage_system,
                                      customer_account_mapping: existing_account_mapping,
                                      rfid_tag: tag_with_existing_mappings)
      end

      it 'creates new mappings for active, unblocked cards' do
        expect { subject.create_missing_mappings }.to change { garage_system.customer_account_mappings.count }.by(1)
        created_mapping = ICA::CardAccountMapping.find_by(rfid_tag: active_tag)
        expect(created_mapping).to_not be_uploaded
      end

      context 'with RFID tags that have no UID' do
        before { active_tag.update(uid: nil) }

        it 'does not create a mapping' do
          expect { subject.create_missing_mappings }.to_not change { garage_system.customer_account_mappings.count }
        end
      end

      context 'in testing mode' do
        before { garage_system.update(workflow_state: 'testing') }

        let(:test_card) { create(:rfid_tag, :active, user: build(:user)) }
        let!(:test_group) { create(:test_group, users: [test_card.user]) }

        it 'only creates mappings for users in test groups' do
          expect { subject.create_missing_mappings }.to change { garage_system.customer_account_mappings.count }.by(1)
          created_mapping = ICA::CardAccountMapping.find_by(rfid_tag: test_card)
          expect(created_mapping).to be_present
        end
      end
    end

    context 'EASY TO PARK' do
      let(:garage_system) { create(:garage_system, :easy_to_park) }
      let!(:etp_card) { create(:rfid_tag, :active, user: build(:user, :easy_to_park)) }
      let!(:evopark_card) { create(:rfid_tag, :active, user: build(:user, :evopark)) }

      it 'only creates mappings for ETP cards' do
        expect { subject.create_missing_mappings }.to change { garage_system.customer_account_mappings.count }.by(1)
        created_mapping = ICA::CardAccountMapping.find_by(rfid_tag: etp_card)
        expect(created_mapping).to be_present
      end
    end

    context 'non-EASY-TO-PARK' do
      let(:garage_system) { create(:garage_system, :ica) }
      let!(:etp_card) { create(:rfid_tag, :active, user: build(:user, :easy_to_park)) }
      let!(:evopark_card) { create(:rfid_tag, :active, user: build(:user, :evopark)) }

      it 'only creates mappings for non-ETP cards' do
        expect { subject.create_missing_mappings }.to change { garage_system.customer_account_mappings.count }.by(1)
        created_mapping = ICA::CardAccountMapping.find_by(rfid_tag: evopark_card)
        expect(created_mapping).to be_present
      end
    end
  end

  describe '#synced_obsolete_customer_account_mappings' do
    def create_card_with_mappings(workflow_state = :active)
      tag = create(:rfid_tag, workflow_state, user: build(:user))
      customer_mapping = create(:customer_account_mapping, garage_system: garage_system, user: tag.user)
      create(:card_account_mapping, customer_account_mapping: customer_mapping, rfid_tag: tag)
    end

    let!(:mapping_for_active_tag) { create_card_with_mappings }
    let!(:mapping_for_inactive_tag) { create_card_with_mappings(:inactive) }
    let!(:mapping_for_tag_with_blocklist_entry) { create_card_with_mappings }
    let!(:blocklist_entry) do
      create(:blocklist_entry,
             rfid_tag: mapping_for_tag_with_blocklist_entry.rfid_tag,
             parking_garage: build(:parking_garage))
    end
    let!(:carpark) { create(:carpark, garage_system: garage_system, parking_garage: blocklist_entry.parking_garage) }

    context 'in full sync mode' do
      let(:obsolete_mappings) { subject.synced_obsolete_customer_account_mappings(full_sync: true) }
      it 'includes blocked cards' do
        expect(obsolete_mappings).to match_array([mapping_for_tag_with_blocklist_entry.customer_account_mapping,
                                                  mapping_for_inactive_tag.customer_account_mapping])
      end
    end

    context 'in regular mode' do
      let(:obsolete_mappings) { subject.synced_obsolete_customer_account_mappings(full_sync: false) }
      it 'does not include blocked cards' do
        expect(obsolete_mappings).to match_array([mapping_for_inactive_tag.customer_account_mapping])
      end
    end
  end
end
