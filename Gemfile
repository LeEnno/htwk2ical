source 'https://rubygems.org'

ruby '2.2.4'

gem 'rails', '~> 3.2.22'


group :development, :test do
  gem 'mysql2'

  # LiveReload 
  gem 'guard-livereload', :require => false
  gem 'rack-livereload'
  gem 'rb-fsevent',       :require => false
end


group :production do
  gem 'pg'
  gem 'thin'
end


group :assets do
  gem 'sass-rails',   '>= 3.2.3'
  gem 'coffee-rails', '>= 3.2.1'

  gem 'uglifier', '>= 1.0.3'

  gem 'therubyracer', '>= 0.12.0'
  gem 'less-rails'
end


gem 'jquery-rails'
gem 'jquery-ui-rails', '4.0.1'

gem 'exception_notification'


# seems to be necessary for rails 3.2 to work with ruby 2.2.4
gem 'test-unit', '~> 3.0'
