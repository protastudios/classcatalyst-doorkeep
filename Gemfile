source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'aasm'
gem 'active_model_serializers'
gem 'aws-sdk-rails'
gem 'aws-sdk-s3'
gem 'aws-sdk-ses'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'cancancan'
gem 'dalli'
gem 'foreman', require: false
gem 'i18n-active_record', require: 'i18n/active_record'
gem 'jbuilder'
gem 'jwt'
gem 'kaminari'
gem 'lograge'
gem 'memcachier'
gem 'olive_branch'
gem 'omniauth', '~> 1.9'
gem 'omniauth-facebook', '~> 5.0'
gem 'omniauth-google-oauth2', '~> 0.6.1'
gem 'omniauth-linkedin-oauth2', '~> 1.0'
gem 'omniauth-twitter', '~> 1.4'
gem 'pg'
gem 'puma'
gem 'rack-attack'
gem 'rack-cors'
gem 'rails', '~> 6.0.0'
gem 'rails_admin'
gem 'rails_admin_import'
gem 'rbnacl'
gem 'redis', '~> 4.0'
gem 'rollbar'
gem 'scout_apm'
gem 'sidekiq'
gem 'stripe'

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'i18n-tasks'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-junit-formatter', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'timecop'
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'letter_opener'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
