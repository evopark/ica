# frozen_string_literal: true

module ICA
  # Useful to find out more about the garage system
  class GarageSystemError < StandardError
    attr_reader :garage_system_id
    def initialize(garage_system_id, message)
      @garage_system_id = garage_system_id
      super(message)
    end
  end

  # Standardized error for failed API requests
  class ApiRequestError < GarageSystemError
    attr_reader :response_status
    attr_reader :response_body
    def initialize(garage_system_id, response_status, response_body, message)
      @response_status = response_status
      @response_body = response_body
      super(garage_system_id, message)
    end
  end
end
