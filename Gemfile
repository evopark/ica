source 'https://rubygems.org'

# Don't use gemspec as it adds test-gems to the development group which is somewhat annoying
# Also it trips up Bundler.require a lot
# Pro: things work
# Con: dependencies need to be managed in both Gemfile and gemspec

def private_github_uri(project, owner='evopark')
  # Need to hardcode it here because Heroku will otherwise complain about different URL in Gemfile.lock
  "https://f6d83ebbffc170afcde732bfb75acd7128fdf471:x-oauth-basic@github.com/#{owner}/#{project}.git"
end

gem 'rails', '~> 5.0.2'
gem 'config'
gem 'gelf', '~> 3.0', git: 'https://github.com/evopark/gelf-rb.git'
gem 'paper_trail', '~> 4.2'

gem 'ep_ruby_utils', git: private_github_uri('ruby-utils')

gem 'appsignal'

gem 'uuid'
gem 'semantic'

# A few gems for the admin interface
gem 'meta-tags'
gem 'slim-rails'
gem 'font-awesome-rails'
gem 'uglifier', '>= 2.5.3'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails', '~> 4.2.1'
gem 'jquery-turbolinks', '~> 2.1.0'
gem 'jquery-ui-rails'
gem 'bootstrap-sass'
gem 'autoprefixer-rails', '~> 6.4.0'
gem 'simple_form', '3.3.1'
gem 'enum_help'
gem 'kaminari'

gem 'grape', '~> 0.19.0'
# gem 'grape-rails-cache', git: private_github_uri('grape-rails-cache')
gem 'grape-entity'

group :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'rspec-json_expectations'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'simplecov'
  gem 'webmock'
  gem 'nokogiri'
  gem 'capybara'
  gem 'rspec_junit_formatter'
end

group :doc do
  # A Ruby Documentation Tool
  gem 'yard'
  # Analyzes documentation quality
  gem 'inch'
end

group :development, :test do
  # mirror expected host environment as good as possible
  gem 'schema_plus_core'
  gem 'schema_plus_indexes', '~> 0.2.4'
  gem 'schema_plus_columns', '~> 0.1.3'

  gem 'rubocop'

  gem 'pg'
  gem 'activerecord-postgis-adapter'
  gem 'rgeo'
  gem 'redis-rails', '~> 5.0.1'

  gem 'awesome_print'
  gem 'pry-rails'
  gem 'pry-byebug'

  gem 'guard'
  gem 'guard-rails'
  gem 'guard-bundler'
  gem 'guard-rubocop'
  gem 'guard-rspec'

  gem 'oj'
end
