source "https://rubygems.org"

ruby "3.1.0"

gem "rails", "~> 7.1.3", ">= 7.1.3.2"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", "4.3.0"
gem "bcrypt", "~> 3.1.7"
gem "bootsnap", require: false

gem "pg"
gem "pry-rails"
gem "mechanize"
gem "nokogiri"
gem "aws-sdk-s3" # to use digital ocean spaces... terrible......
gem "sidekiq", "~> 6.0"
gem "html2text"
gem "connection_pool" # use to manually share sidekiq connection with sidekiq additions (eg, JobBatch)

# gem "barnes" # For Heroku stats. Pretty expensive.
# gem "newrelic_rpm"
gem "bugsnag", "~> 6.18"
gem "dotenv-rails"
gem "rack-mini-profiler"
gem "stackprof"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
#

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem

# Reduces boot times through caching; required in config/boot.rb

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mswin mswin64 mingw x64_mingw]
  gem "rspec-rails"
  gem "standard"
  gem "sqlite3", "~> 1.4"
  # gem "rubocop"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem "spring"

  gem "annotate"

  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "mock_redis"
  gem "simplecov"
  gem "factory_bot_rails"
  # gem "database_cleaner-active_record"
end

gem "tzinfo-data", platforms: %i[mswin mswin64 mingw x64_mingw jruby]

gem "jsbundling-rails", "~> 1.3"
