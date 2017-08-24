# frozen_string_literal: true

require 'activerecord/enum_translations'
require 'models/concerns/excluding_scope'

module ICA
  # Base class for all persisted models of the engine
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    include ExcludingScope
    include EnumTranslations
  end
end
