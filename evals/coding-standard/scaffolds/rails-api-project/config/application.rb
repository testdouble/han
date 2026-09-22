require_relative "boot"
require "rails"
require "action_controller/railtie"

module PiAndFibonacci
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true

    config.eager_load = false
  end
end
