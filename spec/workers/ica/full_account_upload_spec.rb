# frozen_string_literal: true

RSpec.describe ICA::FullAccountUpload do
  let!(:carpark) { create(:carpark, garage_system: garage_system) }
  let(:parking_garage) { carpark.parking_garage }
  # don't use an ETP system here because then we'd also need to consider this for every tag user
  let!(:garage_system) { create(:garage_system) }

  context 'with previously updated data' do
    let!(:active_account_mapping) { create(:customer_account_mapping, :uploaded, garage_system: garage_system) }
    let!(:active_card_mapping) do
      create(:card_account_mapping, :uploaded,
             customer_account_mapping: active_account_mapping,
             rfid_tag: create(:rfid_tag, :active, user: active_account_mapping.user))
    end
    let!(:obsolete_card_mapping) do
      create(:card_account_mapping, :uploaded,
             customer_account_mapping: active_account_mapping,
             rfid_tag: create(:rfid_tag, :inactive, user: active_account_mapping.user))
    end
    let!(:blocked_card_mapping) do
      create(:card_account_mapping, :uploaded,
             customer_account_mapping: active_account_mapping,
             rfid_tag: create(:rfid_tag, :active, user: active_account_mapping.user).tap do |tag|
               create(:blocklist_entry,
                      parking_garage: parking_garage, rfid_tag: tag)
             end)
    end
    let!(:obsolete_account_mapping) { create(:customer_account_mapping, :uploaded, garage_system: garage_system) }
    let!(:obsolete_card_mapping2) do
      create(:card_account_mapping, :uploaded,
             customer_account_mapping: obsolete_account_mapping,
             rfid_tag: create(:rfid_tag, :inactive, user: obsolete_account_mapping.user))
    end

    it 'destroys all obsolete mappings' do
      allow_any_instance_of(ICA::Requests::CreateAccounts).to receive(:execute).and_return(true)
      subject.perform(garage_system.id)
      expect(garage_system.customer_account_mappings.ids).to match_array([active_account_mapping.id])
      expect(garage_system.card_account_mappings.ids).to match_array([active_card_mapping.id])
    end

    it 'uploads valid mappings to the remote system' do
      Timecop.freeze(Time.now.change(usec: 0)) do
        expect(ICA::Requests::CreateAccounts).to receive(:new) do |gs, mappings|
          expect(gs).to eq(garage_system)
          expect(mappings).to match_array(garage_system.customer_account_mappings)
          double.tap { |d| expect(d).to receive(:execute).and_return(true) }
        end
        subject.perform(garage_system.id)
        # not 100% correct since we don't test that it's the beginning of the block but everything else is hard to test
        expect(garage_system.reload.last_account_sync_at).to eq(Time.now)
      end
    end
  end
end
