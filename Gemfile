source 'https://rubygems.org'

ruby '2.5.6'

gem 'rails', '~> 3.2.22'


group :development, :test do
  gem 'mysql2'
  gem 'byebug'
end


group :assets do
  gem 'sass-rails',   '>= 3.2.3'
  gem 'json', '>= 1.8.5' # uglifier needs it and older versions don't work with newer ruby versions
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer', '>= 0.12.0' # necessary for less-rails
  gem 'less-rails'
  gem 'sqlite3'
end


group :production do
  gem 'pg'
  gem 'thin'
end


gem 'jquery-rails'
gem 'jquery-ui-rails', '4.0.1'

gem 'exception_notification'

gem 'test-unit', '~> 3.0' # rails console needs it on heroku, https://stackoverflow.com/a/27802967/1531580
