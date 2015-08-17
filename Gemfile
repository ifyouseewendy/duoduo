source 'https://rubygems.org'

gem 'rails', '4.2.2'

# I18n
gem 'rails-i18n', github: 'svenfuchs/rails-i18n', branch: 'master'

# Database
gem 'pg'

# Active Admin
gem 'activeadmin',          path: 'vendor/bundle/ruby/2.2.0/bundler/gems/activeadmin-3254f53b4b35'
gem "active_admin_import" , path: 'vendor/bundle/ruby/2.2.0/bundler/gems/active_admin_import-ca7d286d0f07'

# Plus integrations with:
gem 'devise'
gem 'devise-i18n'
gem 'cancan' # or cancancan
gem 'draper'
gem 'pundit'

# Front End
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Server
gem 'thin'

# Env
gem 'dotenv-rails'

# Deployment
gem 'mina'

# Console
gem 'pry-rails'
gem "pry-doc"
gem "awesome_print"

# Cron
gem 'whenever', :require => false

group :development do
  gem 'quiet_assets'

  # UML Diagram
  gem 'railroady'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem "pry-byebug"
end

