namespace :pg do
  desc "Dumps the database to backups"
  task :dump => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_dump -h #{host} -d #{db} -U #{user} -Ft -v -c -f #{Rails.root}/public/resources/duoduo/db_backup/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{db}.tar"
    end
    puts cmd
    exec cmd
  end

  desc "Restores the database from backups"
  task :restore, [:timestamp] => :environment do |task,args|
    if args.timestamp.present?
      cmd = nil
      with_config do |app, host, db, user|
        cmd = "pg_restore -h #{host} -d #{db} -U #{user}  -Ft -v -c #{Rails.root}/public/resources/duoduo/db_backup/#{args.timestamp}_#{db}.tar"
      end
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      puts cmd
      exec cmd
    else
      puts 'Please pass a date to the task'
    end
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host] || 'localhost',
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end
end
