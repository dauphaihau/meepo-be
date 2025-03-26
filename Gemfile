source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.6'

gem 'devise', '~> 4.9'
gem 'devise-jwt', '~> 0.9.0'
gem 'jwt'
gem 'kaminari'
gem 'rack-cors'
gem 'rubocop', require: false
gem 'spring', group: :development
gem 'sprockets-rails'
gem 'warden-jwt_auth', '~> 0.6.0'
gem 'hiredis'
gem 'importmap-rails'
gem 'jbuilder'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'redis', '~> 5.0'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

gem 'bootsnap', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'faker'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
