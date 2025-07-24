require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module WordleApi
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w(assets tasks))
    config.generators.system_tests = nil

    config.generators.assets = false
    config.generators.javascript_engine = nil
    config.api_only = false
  end
end