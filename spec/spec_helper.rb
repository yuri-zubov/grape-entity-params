require "bundler/setup"
require 'rack/test'
require "grape/entity/params"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  # config.include Spec::Support::Helpers
  config.raise_errors_for_deprecations!
  config.filter_run_when_matching :focus

  config.before(:each) { Grape::Util::InheritableSetting.reset_global! }
end
