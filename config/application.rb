require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DexRailsApi
  class Application < Rails::Application
    # Let's get GC profiler stats!
    GC::Profiler.enable

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.eager_load_paths << Rails.root.join("app", "lib")
    config.autoload_paths << Rails.root.join("app", "lib")

    config.eager_load_paths << Rails.root.join("app", "services")
    config.autoload_paths << Rails.root.join("app", "services")
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
