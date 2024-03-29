# source 'https://rubygems.org'
source 'https://ruby.taobao.org'

gem 'rails', '4.2.2'

# I18n
gem 'rails-i18n', github: 'svenfuchs/rails-i18n', branch: 'master'

# Database
gem 'pg'

# Active Admin
gem 'activeadmin',          github: 'ifyouseewendy/activeadmin', branch: 'master'
# gem "active_admin_import" , github: 'ifyouseewendy/active_admin_import'

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
# Font Awesome
gem 'font-awesome-rails'

# Commandd Line
gem 'thor'

# Uploader
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'

# Server
gem 'thin'
gem 'unicorn', '~> 4.8.0'
gem 'puma'

# Env
gem 'dotenv-rails'

# Deployment
gem 'mina'
gem 'mina-puma', :require => false

# Console
gem 'pry-rails'
gem "pry-doc"
gem "awesome_print"

# Cron
gem 'whenever', :require => false

# Pinyin
gem 'chinese_pinyin'

# Fake Chinese name
gem 'jia'

# Parse XLSx
gem 'roo', '2.0.0beta1' # Read xlsx
gem 'roo-xls'           # xls support
gem 'axlsx_rails'       # Write xlsx
gem 'zip-zip'           # Fix axlsx dependency

# Read .doc when importing
gem 'doc_ripper'

# Optimize
# gem 'goldiloader'

# RMB
gem 'rmb_chinese_yuan'

# Activity tracking for models
gem 'public_activity'

# Monitor
gem 'newrelic_rpm'

gem 'rollbar', '~> 2.7.1'
gem 'oj', '~> 2.12.14'
gem 'mina-rollbar', require: false

group :development do
  gem 'quiet_assets'

  # UML Diagram
  gem 'railroady'
  gem "rails-erd"

  # Web-view DB
  gem 'rails_db'

  # Targeting N+1
  gem "bullet"

  # Open Pry session when exception happens
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'

  gem "pry-byebug"

  gem 'minitest-focus'
end

group :production do
  gem 'rails_12factor'
end
