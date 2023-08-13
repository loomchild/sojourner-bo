namespace :fly do
  task build: 'assets:precompile'

  task release: 'db:migrate'

  task :deploy do
    sh 'fly deploy'
  end

  task :ssh do
    sh 'fly ssh console --pty -C "sudo -iu rails"'
  end

  task :console do
    sh 'fly ssh console --pty -C "/rails/bin/rails console"'
  end

  task :dbconsole do
    sh 'fly ssh console --pty -C "/rails/bin/rails dbconsole"'
  end

  task :conference_reset, [:id, :name, :start, :end] => [:environment] do |_task, args|
    sh "fly ssh console -C \"/rails/bin/rails conference:reset['#{args.id}','#{args.name}','#{args.start}','#{args.end}']\""
  end

  task :conference_reset_all do
    sh 'fly ssh console -C "/rails/bin/rails conference:reset_all"'
  end
end
