set :application, "ezfeed"
set :repository, "https://github.com/prasofty/ezfeed.git"
set :domain, '173.255.195.108' #Your Accelerators public IP address

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/deployer/ezfeed/"
set :user, "root"
set :scm_passphrase, "startUP"

set :keep_releases, 5

role :web, domain # Your HTTP server, Apache/etc
role :app, domain # This may be the same as your `Web` server
role :db, domain, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

after "deploy:restart", "deploy:cleanup"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "#{try_sudo} chmod -R a+rw #{current_path}/public"
    run "#{try_sudo} chmod -R a+rw #{current_path}/"
    run "#{try_sudo} chmod -R a+rw #{current_path}/Gemfile.lock"
  end
end
