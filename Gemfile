source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'rails', '~> 6.1', '>= 6.1.1'
gem 'puma', '~> 4.1'
gem 'jbuilder', '~> 2.7'
gem 'redis', '~> 4.0'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'rack-cors'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

gem 'pg'
gem 'pry-rails'
gem 'mechanize'
gem 'nokogiri'
gem 'aws-sdk-s3' # to use digital ocean spaces... terrible......
gem 'sidekiq'
gem 'html2text'
gem 'connection_pool' # use to manually share sidekiq connection with sidekiq additions (eg, JobBatch)
gem 'active_interaction', '~> 4.0'
gem 'dry-initializer-rails'

# gem "barnes" # For Heroku stats. Pretty expensive.
gem 'newrelic_rpm'
gem "bugsnag", "~> 6.18"
gem 'dotenv-rails'


group :development, :test do
  gem 'sqlite3', '~> 1.4'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'standard'
  gem 'rubocop'
  gem 'debase' # for debugging
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'mock_redis'
  gem 'simplecov'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
