# frozen_string_literal: true
require 'activerecord/enum_translations'

module ICA
  # Dummy comment because Rubocop is somewhat buggy
  module Admin
    # The engine provides the Rails-specific functionality like migrations and admin web-interface
    # It's currently not in a separate `Admin` namespace because that needlessly complicated things
    class Engine < ::Rails::Engine
      isolate_namespace ICA

      config.generators do |g|
        g.test_framework :rspec,
                         fixture: false,
                         view_specs: false,
                         helper_specs: false,
                         routing_specs: false,
                         controller_specs: false,
                         request_specs: false
        factory_path = File.expand_path('../../../spec/factories', __FILE__)
        g.fixture_replacement :factory_girl, dir: factory_path
      end

      config.eager_load_paths << root.join('lib')
      config.autoload_paths << root.join('app', 'services')

      # Grape API
      config.paths.add(File.join('app', 'api'), glob: File.join('**', '*.rb'))
      config.autoload_paths << root.join('app', 'api')

      initializer 'ica.assets.precompile' do |app|
        app.config.assets.precompile += %w[ica/application.css
                                           ica/application.js]
      end

      # Skips copying of migration and lets them run automagically from the host app
      initializer :append_migrations do |app|
        next if app.root.to_s.start_with?(root.to_s) # only run when called from other apps
        app.config.paths['db/migrate'].concat(config.paths['db/migrate'].expanded)
      end
    end
  end
end
