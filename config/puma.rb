workers Integer(ENV['WEB_CONCURRENCY'] || 4)
threads_count = Integer(ENV['MAX_THREADS'] || 1) # Not sure for thread safe
threads threads_count, threads_count

stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true

prune_bundler

# directory "/home/deploy/apps/duoduo/current"
