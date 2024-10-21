# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.1", ">= 7.2.1.1"

# Use postgresql as the database for Active Record
gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 6.4.3"

# Use the popular Faraday HTTP library
gem "faraday"

# Use the JWT gem for JSON Web Tokens
gem "jwt"

# Use simple asset pipeline
gem "propshaft", "~> 1.1.0"
gem "cssbundling-rails", "~> 1.4"
gem "jsbundling-rails", "~> 1.3"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]

  gem "rspec-rails"

  gem 'pry'

  # rubocop and specific extensions used by VS Code
  gem "rubocop", ">= 1.66.0"
  gem "rubocop-performance", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rails", ">= 2.26.0", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-capybara", require: false

  gem "codeclimate-test-reporter"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "annotate"
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "foreman"
end

group :test do
  gem "webmock"
  gem "rspec_junit_formatter"
  gem 'simplecov', '~> 0.17.0', require: false
  gem "rails-controller-testing"
end

# Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
group :system_tests, :test do
  gem "axe-core-rspec"
  gem "capybara"
  gem "selenium-webdriver", ">= 4.24.0"
end

gem "factory_bot", "~> 6.5"

gem "faker", "~> 3.4"
