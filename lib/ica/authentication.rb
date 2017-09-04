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
    def time_and_signature
      time = Time.now.iso8601
      [time, expected_signature(time)]
    end

    # Verifies the `Signature` in a {Grape::Request}
    # Duck-typing: anything that responds to `#headers`
    def verify(request)
      localtime = request.headers['Localtime'] || request.headers['LocalTime']
      request.headers['Signature'] == expected_signature(localtime)
    end

    private

    def expected_signature(localtime)
      # Look for both spellings, uppercase often gets lost in incoming requests
      data = @client_id + localtime + @auth_key
      OpenSSL::HMAC.hexdigest(digest, @sig_key, data)
    end

    def digest
      @digest ||= OpenSSL::Digest.new('sha256')
    end
  end
end
