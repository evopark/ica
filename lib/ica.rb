# frozen_string_literal: true

# Container module for the gem functionality
# Provides a few configuration methods
module ICA
  mattr_writer :parking_garage_class
  mattr_writer :user_class

  mattr_accessor :garage_system_facade
  mattr_accessor :user_data_facade
  mattr_accessor :redis

  mattr_writer :logger

  UUID_REGEX = /\A[0-9a-f]{8}-?[0-9a-f]{4}-?[1-5][0-9a-f]{3}-?[89ab][0-9a-f]{3}-?[0-9a-f]{12}\Z/i

  class << self
    def logger
      @logger ||= create_logger
    end

    def parking_garage_class
      classname = class_variable_get('@@parking_garage_class') ||
                  Settings.ica.parking_garage_class
      classname.constantize
    end

    def user_class
      classname = class_variable_get('@@user_class') || Settings.ica.user_class
      classname.constantize
    end

    protected

    def create_logger
      GELF::Logger.new(Settings.logging.server,
                       Settings.logging.port,
                       Settings.logging.max_size,
                       Hash[Settings.logging.default_options]).tap do |logger|
        logger.level_mapping = :direct
        logger.collect_file_and_line = false
      end
    end
  end
end

require 'ica/admin/engine'
require 'ica/version'
