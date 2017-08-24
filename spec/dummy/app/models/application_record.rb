# frozen_string_literal: true

require 'activerecord/enum_translations'
require 'models/concerns/excluding_scope'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ExcludingScope
  include EnumTranslations
end
