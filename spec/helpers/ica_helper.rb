# frozen_string_literal: true

# helper for all API specs
module ICAHelper
  extend ActiveSupport::Concern

  def app
    ICA::API
  end
end
