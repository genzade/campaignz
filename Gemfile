# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "bootsnap", require: false
gem "importmap-rails", "~> 1.1", ">= 1.1.6"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"
gem "sprockets-rails", "~> 3.4", ">= 3.4.2"
gem "stimulus-rails", "~> 1.0", ">= 1.0.4"
gem "tailwindcss-rails", "~> 2.0", ">= 2.0.8"
gem "turbo-rails", "~> 1.1", ">= 1.1.1"
gem "tzinfo-data", "~> 1.2022", ">= 1.2022.1", platforms: %i[mingw mswin x64_mingw jruby]

group :development do
  gem "rubocop", "~> 1.44", ">= 1.44.1", require: false
  gem "rubocop-rails", "~> 2.17", ">= 2.17.4", require: false
  gem "rubocop-rspec", "~> 2.18", ">= 2.18.1", require: false
  gem "web-console"
end

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails", "~> 6.2"
  gem "pry-byebug", "~> 3.10", ">= 3.10.1"
  gem "rspec-rails", "~> 6.0", ">= 6.0.2"
end

group :test do
  gem "capybara", "~> 3.38"
  gem "shoulda-matchers", "~> 5.3"
end
