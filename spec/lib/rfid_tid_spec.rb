# frozen_string_literal: true
require 'rfid_tid'

RSpec.describe RfidTid do

  it 'ensures big endianness' do
    expect(RfidTid.new('80E2051100208A267E868E08').to_s).to eq('E28011052000268A867E088E')
    expect(RfidTid.new('E28011052000268A867E088E').to_s).to eq('E28011052000268A867E088E')
  end
end
