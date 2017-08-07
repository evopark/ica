# frozen_string_literal: true

module ICA
  RSpec.describe ApiUser, type: :model do
    subject { build(:api_user) }

    it { is_expected.to validate_presence_of(:client_id) }
    it { is_expected.to validate_length_of(:client_id).is_at_least(6) }

    describe '#auth_key' do
      it { is_expected.to validate_presence_of(:auth_key) }
      it { is_expected.to_not allow_value('g'*64).for(:auth_key) }
    end

    describe '#sig_key' do
      it { is_expected.to validate_presence_of(:sig_key) }
      it { is_expected.to_not allow_value('g'*64).for(:sig_key) }
    end
  end
end
