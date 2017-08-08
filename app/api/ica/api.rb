# frozen_string_literal: true

require 'logging/graylog_helper'

module ICA
  # Implements the ICA 3rd party API
  class API < Grape::API
    content_type :json, 'application/json; charset=utf-8'
    default_format :json

    VERSION = Semantic::Version.new('2.2.0').freeze

    helpers do
      delegate :log, to: GraylogHelper

      def settings
        Settings.ica
      end
    end

    mount ApiV1
  end
end
