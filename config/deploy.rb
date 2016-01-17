require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/whenever'

set :domain, 'duoduo'
set :deploy_to, '/home/deploy/apps/duoduo'
set :repository, 'git@github.com:ifyouseewendy/duoduo.git'
set :branch, 'production'

# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml','config/newrelic.yml','config/unicorn.rb', 'backups', 'log', 'tmp', '.env.production']

# set :user, 'deploy'    # Username in the server to SSH to.
# set :port, '10080'     # SSH port number.
# set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  invoke :'rvm:use[ruby-2.2.2@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/backups"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/backups"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml'."]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/newrelic.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/newrelic.yml'."]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/unicorn.rb"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/unicorn.rb'."]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :'whenever:update'
      invoke :'deploy:link_files'
      invoke :'unicorn:restart'
    end
  end
end

namespace :deploy do
  task :link_files do
    queue! %{
      ln -svf ~/resources #{deploy_to}/#{current_path}/public
    }
  end
end

namespace :unicorn do
  set :unicorn_pid, "#{deploy_to}/#{current_path}/tmp/pids/unicorn.pid"
  set :unicorn_config, "#{deploy_to}/#{current_path}/config/unicorn.rb"

  set :start_unicorn, %{
    cd "#{deploy_to}/#{current_path}"
    bundle exec unicorn -c #{unicorn_config} -E #{rails_env} -D
  }

  desc "Start unicorn"
  task :start => :environment do
    queue 'echo "-----> Start Unicorn"'
    queue! start_unicorn
  end

  desc "Stop unicorn"
  task :stop do
    queue 'echo "-----> Stop Unicorn"'
    queue! %{
      test -s "#{unicorn_pid}" && kill -QUIT `cat "#{unicorn_pid}"` && echo "Stop Ok"
      echo >&2 "Not running"
    }
  end

  desc "Restart unicorn"
  task :restart => :environment do
    queue 'echo "-----> Restart Unicorn"'
    invoke :'unicorn:stop'
    invoke :'unicorn:start'
    # queue! %{
    #   test -s "#{unicorn_pid}" && kill -USR2 `cat "#{unicorn_pid}"` && echo "Restart Ok" && exit 0
    #   echo >&2 "Not running"
    # }
  end
end

