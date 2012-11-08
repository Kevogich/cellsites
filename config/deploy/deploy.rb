# Stages, see config/deploy/* 
set :stages, %w(staging development production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

#These are set in stage files
set(:domain){ "" }
set(:application){ "" }
set(:env){ "production" }

# Server and Login Details, overridden in stage files
set(:servers) { "" }
set(:user){ "" }
set(:password){ "" }
set(:runner){ user }
set(:use_sudo){ false }
set(:deploy_to){ "/home/#{user}/domains/#{application}" }

# Repository Details, overridden in stage files (esp branch)
set :repository, "git@scm.g33k.in:railscommon/baseapp.git"
set :scm, "git"
set :scm_passphrase, ""
set :branch, "master"
set :deploy_via, :remote_cache

# Other Settings
default_run_options[:pty] = true
set :chmod755, "app config db lib public vendor script script/* public/disp*"

# Servers. stage_servers set in stage files
role(:app){ "#{servers}" }
role(:web){ "#{servers}" }
role(:db, :primary => true){ "#{servers}" }

# Deploy Tasks
namespace :deploy do

  # Passenger Restart
  namespace :passenger do
    desc "Restart Application"
    task :restart, :roles => :app do
      run "cd #{current_path}; touch tmp/restart.txt"
    end
  end

  # Mongrel Restart
  namespace :mongrel do
    desc "Mongrel restart"
    task :restart, :roles => :app do
      deploy.mongrel.stop
      puts "Stoped mongrel service. Should hopefully respawn. Otherwise run deploy:mongrel:start"
      # Not starting. Mongrel server respawns
      #deploy.mongrel.start
    end

    desc "Mongrel start"
    task :start, :roles => :app do
      run "mongrel_rails start -c #{current_path} -p #{mongrel_pid} -d -e #{env} -a 127.0.0.1 -P log/mongrel-#{mongrel_pid}.pid"
    end

    desc "Mongrel stop"
    task :stop, :roles => :app do
      run "cd #{current_path}; /opt/local/bin/mongrel_rails stop -P log/mongrel-#{mongrel_pid}.pid"
    end
  end

  # Restart
  desc "Custom restart task"
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.passenger.restart
  end

  # Bundle install
  desc "Bundle install"
  task :bundle_install, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}; bundle install "
  end

  # Server Settings
  desc "Use custom (domain specific) files (eg database.yml and facebooker.yml)"
  task :copy_custom_files, :roles => :app do
    run "cd #{current_path}; if [ -d config/deploy/#{application} ] ; then cp -a config/deploy/#{application}/* ./; fi; "
  end

  # Static content path
  desc "Static content path"
  task :link_content_path, :roles => :app do
    run "cd #{current_path}; ln -s #{shared_path}/system/assets public/assets"
    run "cd #{current_path}; ln -s #{shared_path}/system/uploads public/uploads"
  end
end

# Gem Tasks
# Compile
desc "Compile gems on-demand" ## usage: build_gems=1 cap deploy
task :after_update_code, :roles => :app do
  if ENV['build_gems'] and ENV['build_gems'] == '1'
    run "rake -f #{release_path}/Rakefile gems:build"
  end
end

# Remote Console
desc "remote console" 
task :console, :roles => :app do
  input = ''
  run "cd #{current_path} && RAILS_ENV=#{env} rails console " do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  end
end

# Tests
namespace :env do
  desc "Echo environment vars" 
  task :echo do
    run "echo $PATH"
    run "env"
  end

  desc "Test Task, Print pervious release" 
  task :previous_release do
    run "echo #{previous_release}"
  end
end

# Callbacks
after "deploy:update", "deploy:copy_custom_files"
after "deploy:update", "deploy:link_content_path"
after "deploy:restart", "deploy:cleanup"
before "deploy:restart", "deploy:bundle_install"
before "deploy:restart", "deploy:migrate"


