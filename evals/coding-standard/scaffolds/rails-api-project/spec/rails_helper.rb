require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rspec/rails"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
