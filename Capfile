load 'deploy' if respond_to?(:namespace) # cap2 differentiator

options = YAML.load(File.read("config.yml"))["deploy"]

default_run_options[:pty] = true

set :user, options['username']
set :domain, options['hostname']
set :application, 'bliki'

set :repository,  "git://github.com/bomberstudios/bliki.git"
set :deploy_to, options['folder']
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :scm_verbose, false
set :use_sudo, false

server domain, :app, :web

namespace :deploy do
  task :after_symlink do
    %w(public db themes config.yml).each do |link|
      run "ln -nfs #{shared_path}/#{link} #{current_path}/#{link}"
    end
  end
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
end