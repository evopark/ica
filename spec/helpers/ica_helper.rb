# frozen_string_literal: true

# helper for all API specs
module ICAHelper
  extend ActiveSupport::Concern

  def signed_request_headers(garage_system)
    time = Time.now.iso8601
    data = garage_system.client_id + time + garage_system.auth_key
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), garage_system.sig_key, data)
    {
      'ClientId' => garage_system.client_id,
      'AuthKey' => garage_system.auth_key,
      'LocalTime' => time,
      'Signature' => signature
    }
  end

  def api_request(garage_system, method, path, params = nil)
    header 'Accept', 'application/json'
    signed_request_headers(garage_system).each do |key, value|
      header key, value
    end
    public_send(method, "/ica#{path}", params)
  end

  def app
    ICA::API
  end
end
