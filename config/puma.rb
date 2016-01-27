workers Integer(ENV['WEB_CONCURRENCY'] || 4)
threads_count = Integer(ENV['MAX_THREADS'] || 1) # Not sure for thread safe
threads threads_count, threads_count

# preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

prune_bundler

# on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  #
  # https://devcenter.heroku.com/articles/concurrency-and-database-connections#threaded-servers
  # https://github.com/puma/puma/issues/598
  # ActiveRecord::Base.establish_connection
# end

stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true
