source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '>= 3.2.6'


group :development, :test do
  gem 'mysql2'

  # LiveReload 
  gem 'guard-livereload', :require => false
  gem 'rack-livereload'
  gem 'rb-fsevent',       :require => false
end


group :test do
  gem 'sqlite3'
end


group :production do
  gem 'pg'
  gem 'thin'
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '>= 3.2.3'
  gem 'coffee-rails', '>= 3.2.1'

  gem 'uglifier', '>= 1.0.3'

  gem 'therubyracer', '>= 0.12.0'
  gem 'less-rails'
  # gem 'twitter-bootstrap-rails'
end


gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'exception_notification'