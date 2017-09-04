# frozen_string_literal: true

module ICA
  # Common class for all requests. Not supposed to be re-used, so it will hold a single request and its response.
  class BaseRequest
    attr_reader :response

    def initialize(garage_system)
      @garage_system = garage_system
    end

    private

    def protocol
      return 'https' if @garage_system.use_ssl?
      'http'
    end

    def request(method, path, body)
      base_url = "#{protocol}://#{@garage_system.hostname}"
      base_url += @garage_system.path_prefix if @garage_system.path_prefix.present?
      @response = http.request(method, "#{base_url}/api#{path}", body: body, headers: auth_headers)
    end

    def response_ok?
      (200..299).cover?(@response.code)
    end

    def auth_headers
      time, signature = authentication.time_and_signature
      {
        'LocalTime' => time,
        'Signature' => signature
      }
    end

    def http
      base = if Settings.snb_proxy.present?
               parsed = URI.parse(Settings.snb_proxy)
               HTTP.via(parsed.host, parsed.port, parsed.user, parsed.password)
             else
               HTTP
             end
      base.headers(HTTP::Headers::CONTENT_TYPE => 'application/json',
                   HTTP::Headers::ACCEPT => 'application/json')
    end

    def authentication
      @authentication ||= ICA::Authentication.new(@garage_system.client_id,
                                                  @garage_system.sig_key,
                                                  @garage_system.auth_key)
    end

    def log(level, message, options = {})
      GraylogHelper.log(level, message, options.merge(ica_garage_system_id: @garage_system.id))
    end
  end
end
