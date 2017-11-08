# frozen_string_literal: true

source 'https://rubygems.org'

# Don't use gemspec as it adds test-gems to the development group which is somewhat annoying
# Also it trips up Bundler.require a lot
# Pro: things work
# Con: dependencies need to be managed in both Gemfile and gemspec

def private_github_uri(project, owner = 'evopark')
  # Need to hardcode it here because Heroku will otherwise complain about different URL in Gemfile.lock
  "https://f6d83ebbffc170afcde732bfb75acd7128fdf471:x-oauth-basic@github.com/#{owner}/#{project}.git"
end

# Infrastructure
gem 'config'
gem 'gelf', '~> 3.0', git: 'https://github.com/evopark/gelf-rb.git'
gem 'paper_trail'
gem 'paranoia', '~> 2.3'
gem 'rails', '~> 5.0.2'

gem 'ep_ruby_utils', git: private_github_uri('ruby-utils')

gem 'appsignal'

# Data model
gem 'uuid'
gem 'workflow', '~> 1.2', git: 'https://github.com/geekq/workflow.git'

gem 'semantic'

# Let data migrations act like DB structure migrations
gem 'migration_data'

# Admin UI
gem 'autoprefixer-rails', '~> 6.4.0'
gem 'bootstrap-sass'
gem 'coffee-rails', '~> 4.1.0'
gem 'enum_help'
gem 'font-awesome-rails'
gem 'jquery-rails', '~> 4.2.1'
gem 'jquery-turbolinks', '~> 2.1.0'
gem 'jquery-ui-rails'
gem 'kaminari'
gem 'meta-tags'
gem 'simple_form', '3.3.1'
gem 'slim-rails'
gem 'uglifier', '>= 2.5.3'

# Also background processing
gem 'ice_cube', git: 'https://github.com/evopark/ice_cube.git', branch: 'fix/sidetiq_startup'
gem 'sidekiq', '~> 4.2.0'
gem 'sidetiq'

# The API for incoming requests
gem 'grape', '~> 0.19.0'
# gem 'grape-rails-cache', git: private_github_uri('grape-rails-cache')
gem 'grape-entity'

# API for outgoing requests :)
gem 'http'

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'nokogiri'
  gem 'rspec-json_expectations'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'timecop'
  gem 'webmock'
  # Makes testing delayed methods much nicer
  gem 'rspec-sidekiq', git: 'https://github.com/philostler/rspec-sidekiq.git', branch: 'develop'
end

group :doc do
  # A Ruby Documentation Tool
  gem 'yard'
  # Analyzes documentation quality
  gem 'inch'
end

group :development, :test do
  # mirror expected host environment as good as possible
  gem 'schema_plus_columns', '~> 0.1.3'
  gem 'schema_plus_core'
  gem 'schema_plus_indexes', '~> 0.2.4'

  gem 'rubocop'

  gem 'activerecord-postgis-adapter'
  gem 'pg'
  gem 'redis-rails', '~> 5.0.1'
  gem 'rgeo'

  gem 'awesome_print'
  gem 'pry-byebug'
  gem 'pry-rails'

  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  gem 'oj'
end
