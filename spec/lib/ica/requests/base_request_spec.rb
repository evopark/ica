# frozen_string_literal: true

require 'ica/requests/base_request'

RSpec.describe ICA::Requests::BaseRequest do
  let(:garage_system) { build(:garage_system) }
  subject { described_class.new(garage_system) }

  describe '#http' do
    let(:http) { subject.send(:http) }

    it 'sets per-operation timeouts' do
      # unfortunately there's no public API to interrogate it about the timeouts
      timeout_class, configuration = http.instance_eval do
        [@default_options.timeout_class,
         @default_options.timeout_options]
      end
      expect(timeout_class).to eq(HTTP::Timeout::PerOperation)
      expect(configuration).to eq(read_timeout: 60,
                                  write_timeout: 30,
                                  connect_timeout: 5)
    end
  end
end
