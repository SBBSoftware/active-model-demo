require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/config/'
end
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
Shoulda.autoload_macros(Rails.root)
# remove this
Minitest::Reporters.use! [Minitest::Reporters::RubyMineReporter.new]
# Minitest::Reporters.use! [ Minitest::Reporters::ProgressReporter.new]
class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

require 'capybara/rails'
require 'rack_session_access/capybara'
class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  def current_path
    URI.parse(current_url).request_uri
  end
end

