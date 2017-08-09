# frozen_string_literal: true

module ICA
  # Utility functions to deal with authentication of requests
  class Authentication
    def initialize(client_id, sig_key, auth_key)
      @client_id = client_id
      @sig_key = sig_key
      @auth_key = auth_key
    end

    # Adds a `Signature` header to a {HTTP::Request}
    # Duck-typing: anything that responds to `#headers`
    def sign(request)
      request.headers['LocalTime'] = Time.now.iso8601
      request.headers['Signature'] = expected_signature(request)
    end

    # Verifies the `Signature` in a {Grape::Request}
    # Duck-typing: anything that responds to `#headers`
    def verify(request)
      request.headers['Signature'] == expected_signature(request)
    end

    private

    def expected_signature(request)
      data = @client_id + request.headers['LocalTime'] + @auth_key
      OpenSSL::HMAC.hexdigest(digest, @sig_key, data)
    end

    def digest
      @digest ||= OpenSSL::Digest.new('sha256')
    end
  end
end
