namespace :fly do
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
end
