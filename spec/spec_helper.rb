# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

# Configure Rails Environment
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment.rb', __FILE__)

require 'sidekiq/testing'
Sidekiq::Testing.fake!

require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'factory_girl_rails'
require 'webmock/rspec'
require 'paper_trail/frameworks/rspec'

WebMock.disable_net_connect!(allow_localhost: false)

Dir["#{File.dirname(__FILE__)}/helpers/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

Dir["#{File.dirname(__FILE__)}/factories/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # The different available types are documented
  # in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'

  # Note regarding database cleaning:
  # Since transactional cleaning is *much* faster, I tried to go with that but it produces PostgreSQL foreign key
  # constraint errors.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # Rails.application.config.cache_store = :redis_store, 'redis://localhost:6379/0/cache', { expires_in: 90.minutes }
  end

  config.before(:each) do
    header('Authorization', 'Basic dummy') if respond_to?(:header)
  end

  config.prepend_before(:each) do |_example|
    begin
      Rails.cache.clear
    rescue
      Errno::ENOENT
    end
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  config.include Rack::Test::Methods, type: :request
  config.include ICAHelper, type: :request
  config.include ICA::Admin::Engine.instance.routes.url_helpers, type: :feature

  ICA.garage_system_facade = ICA::FakeSystemFacade

  WebMock.disable_net_connect!(allow_localhost: false)
end
