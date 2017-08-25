# frozen_string_literal: true

module ICA
  RSpec.describe GarageSystem do
    subject { build(:garage_system) }

    it { is_expected.to validate_presence_of(:hostname) }
    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_length_of(:client_id).is_at_least(6) }
    it { is_expected.to validate_uniqueness_of(:client_id) }
    it { is_expected.to have_attribute(:last_account_sync_at) }

    it { is_expected.to respond_to(:use_ssl?) }

    describe '#auth_key' do
      it { is_expected.to validate_presence_of(:auth_key) }
      it { is_expected.to_not allow_value('g' * 64).for(:auth_key) }
    end

    describe '#sig_key' do
      it { is_expected.to validate_presence_of(:sig_key) }
      it { is_expected.to_not allow_value('g' * 64).for(:sig_key) }
    end

    describe 'associations' do
      it { is_expected.to have_many(:carparks) }
      it { is_expected.to have_many(:parking_garages).through(:carparks) }
      it { is_expected.to have_many(:blocklist_entries).through(:parking_garages) }

      it { is_expected.to have_many(:customer_account_mappings).class_name('ICA::CustomerAccountMapping') }
      it { is_expected.to have_many(:card_account_mappings).class_name('ICA::CardAccountMapping') }
    end

    describe 'enums' do
      describe 'variants' do
        subject { described_class.variants }
        it 'contains EasyToPark and ICA' do
          expect(subject).to eq('easy_to_park' => 'easy_to_park', 'ica' => 'ica')
        end
      end
    end

    describe 'workflow' do
      it 'is "prepared" by default' do
        expect(described_class.new).to be_prepared
      end

      context 'prepared' do
        before { subject.workflow_state = 'prepared' }

        it 'can start testing' do
          expect(subject.can_start_testing?).to be_truthy
        end

        it 'transitions to testing state' do
          subject.start_testing!
          expect(subject).to be_testing
          expect(subject).to_not be_changed
        end
      end

      context 'testing' do
        before { subject.workflow_state = 'testing' }
        it 'can go live' do
          expect(subject.can_go_live?).to be_truthy
        end

        it 'transitions into live state' do
          subject.go_live!
          expect(subject).to be_live
          expect(subject).to_not be_changed
        end
      end

      context 'live' do
        before { subject.workflow_state = 'live' }

        it 'can be suspended' do
          expect(subject.can_suspend?).to be_truthy
        end

        it 'transitions to suspended state' do
          subject.suspend!
          expect(subject).to be_suspended
          expect(subject).to_not be_changed
        end
      end

      context 'suspended' do
        before { subject.workflow_state = 'suspended' }

        it 'can go live again' do
          expect(subject.can_go_live?).to be_truthy
        end

        it 'transitions into live state' do
          subject.go_live!
          expect(subject).to be_live
          expect(subject).to_not be_changed
        end
      end
    end
  end
end
