# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'ica/version'

Gem::Specification.new do |s|
  s.name        = 'ica'
  s.version     = ICA::VERSION
  s.authors     = ['Marcus Ilgner']
  s.email       = ['christian.rolle@evopark.de']
  s.homepage    = 'https://www.evopark.com'
  s.summary     = 'Implements the ICA API (client + server) & administration UI'
  s.description = ''
  s.license     = 'Proprietary'

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 5.0.2'
  # s.add_dependency 'redis', '~> 3.2'
  s.add_dependency 'config', '~> 1.2.0'
  s.add_dependency 'paper_trail', '>= 7.1.0'

  s.add_dependency 'grape'
  s.add_dependency 'grape-entity'
  s.add_dependency 'uuid', '>= 2.3.8'
  s.add_dependency 'semantic'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'shoulda-matchers'
end
