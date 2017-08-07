# frozen_string_literal: true

require 'bootstrap_view_helper'

module ICA::Admin
  # View helper methods used in the admin functionality
  module ApplicationHelper
    # Not very elegant but should hopefully be enough for now to render the template
    include ::Admin::BaseHelper
    include FontAwesome::Rails::IconHelper

    def enum_select_options(model, attribute)
      all = model.enum_translations(attribute)
      return nil if all.nil?
      all.delete_if { |k, _v| k == :nil }.invert
    end
  end
end
