# frozen_string_literal: true

gem_settings = File.expand_path('../../settings.yml', __FILE__)
# Prepend settings so they can be overriden by the host application
Settings.prepend_source!(gem_settings)
Settings.reload!
