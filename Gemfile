source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '>= 3.2.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development, :test do
  gem 'sqlite3'
  gem 'mysql2'
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

  gem 'therubyracer'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'exception_notification'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'