# frozen_string_literal: true

require 'ica/authentication'

RSpec.describe ICA::Authentication do
  let(:client_id) { 'garage_operator_identifier' }
  let(:auth_key) { 'bb86296747fa74384aaaeb129ca549d67c00d5284560a03ae6b9d67528456034' }
  let(:sig_key) { '152f20ab789d25e947506ee6485d4cb1959066f970bb65560ad8b4b2112f9b8f' }
  let(:local_time) { '2017-01-01T18:00:00' }
  let(:correct_signature) { 'a8b0d807c79f66e54666bb3836e43bee8b472a3dece433bbb02cfc959366e140' }

  let(:headers) { {} }
  let(:fake_request) do
    double('request').tap do |req|
      allow(req).to receive(:headers).and_return(headers)
    end
  end

  subject { described_class.new(client_id, sig_key, auth_key) }

  describe '#sign' do
    # the timestamp from the documentation is not really ISO8601: fake it
    before do
      allow(Time).to receive(:now).and_return(double('now').tap do |fake_now|
        allow(fake_now).to receive(:iso8601).and_return(local_time)
      end)
    end

    it 'adds the correct signature' do
      subject.sign(fake_request)
      expect(headers['Signature']).to eq(correct_signature)
    end
  end

  describe '#verify' do
    let(:headers) { { 'Localtime' => local_time } }
    context 'with an invalid signature' do
      before { headers['Signature'] = 'foobar' }
      it 'fails' do
        expect(subject.verify(fake_request)).to be_falsey
      end
    end

    context 'with a valid signature' do
      before { headers['Signature'] = correct_signature }
      it 'succeeds' do
        expect(subject.verify(fake_request)).to be_truthy
      end
    end
  end
end
