# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

gem 'rails', '~> 7.1.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails', '~> 3.4.2'

gem 'sqlite3', '~> 2.9.0'

# Use JavaScript bundling for rails [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails', '~> 1.0.3'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails', '~> 1.3.3'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails', '~> 1.1.0'

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails', '~> 1.1.1'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder', '~> 2.11.5'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0.6'

# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.18'
gem 'devise', '~> 4.9.4'

# Makes SCSS possible
gem 'sassc-rails', '~> 2.1.2'

gem 'matrix', '~> 0.4.2'

gem 'builder', '~> 3.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.12.0', require: false

# Use Puma as the web server
gem 'puma', '~> 6.4.0'
# Restore demonization option to Puma
# https://github.com/puma/puma#deployment
gem 'puma-daemon', '~> 0.5.0', require: false

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console', '~> 4.2.0'

  gem 'benchmark-ips', '2.12.0', require: false

  gem 'ruby-lsp', '0.26.5', require: false
end

group :development, :rubocop do
  gem 'rubocop-rubomatic-rails', '~> 1.6.1', require: false
  gem 'rubomatic-html', '~> 1.1.0', require: false
end

group :test, :development do
  gem 'debug', '~> 1.11.0'

  gem 'rspec-rails', '~> 6.1.5'

  gem 'factory_bot_rails', '~> 6.4.4'
  gem 'faker', '3.1.0', require: false
  gem 'shoulda-matchers', '~> 5.0'
end

gem 'ruby-rails-extensions', '~> 2.0.1'

# Does not follow SemVer
gem 'mail', '2.7.1'
gem 'ostruct', '~> 0.6.3'
