# frozen_string_literal: true

require 'activerecord/enum_translations'

module ICA
  # Base class for all persisted models of the engine
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
