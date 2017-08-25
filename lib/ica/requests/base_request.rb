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
      full_url = "#{protocol}://#{@garage_system.hostname}/#{path}"
      @response = http.request(method, full_url, body: body)
    end

    def response_ok?
      (200..299).cover?(@response.code)
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

    def log(level, message, options = {})
      GraylogHelper.log(level, message, options.merge(ica_garage_system_id: @garage_system.id))
    end
  end
end
