source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'redis', '~> 4.0'
gem 'mini_magick'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'rack-cors'
gem 'active_model_serializers'
gem 'kaminari'
gem 'api-pagination'
gem 'http_accept_language'
gem 'sidekiq'
gem 'redis-namespace'
gem 'whenever', require: false
gem 'decent_exposure'
gem 'paper_trail'
gem 'geocoder'
gem 'faraday_middleware'
gem 'faraday-cookie_jar'
gem 'jwt'
gem 'fcm'
gem 'devise'
gem 'doorkeeper', '~> 5.0.0.rc2'
gem 'carrierwave'
gem 'carrierwave-i18n'
gem 'fog'
gem 'spreadsheet'
gem 'rubyXL'
gem 'deep_cloneable'
gem 'pdfkit'
gem 'wkhtmltopdf-binary'
gem 'combine_pdf'
gem 'cancancan'
gem 'newrelic_rpm'
gem 'tty-spinner'
gem 'extensobr', git: 'https://github.com/dpedoneze/extensobr.git'

group :development, :test do
  gem 'rb-readline'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'master'
  gem 'jsonapi-rspec', require: false
  gem 'webmock'
  gem 'timecop'
  gem 'oauth2'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'guard-rspec', require: false
  gem 'letter_opener'
  gem 'foreman', git: 'https://github.com/ppdeassis/foreman.git', branch: 'thor-updated'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
end

group :test do
  gem 'rspec-sidekiq'
  gem 'codeclimate-test-reporter'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'database_cleaner'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
