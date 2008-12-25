load 'deploy' if respond_to?(:namespace) # cap2 differentiator

options = YAML.load(File.read("config.yml"))

default_run_options[:pty] = true

set :user, options['deploy']['username']
set :domain, options['deploy']['hostname']
set :application, 'bliki'

set :repository,  "git://github.com/bomberstudios/bliki.git"
set :deploy_to, options['deploy']['folder']
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :scm_verbose, true
set :use_sudo, false

server domain, :app, :web

namespace :deploy do
  task :after_symlink do
    run_locally("scp config.yml #{options['deploy']['username']}@#{options['deploy']['hostname']}:#{shared_path}/config.yml")
    run_locally("scp -r themes/#{options['theme']} #{options['deploy']['username']}@#{options['deploy']['hostname']}:#{shared_path}/themes/#{options['theme']}")
    ["db", "themes/#{options['theme']}", "config.yml"].each do |link|
      run "ln -nfs #{shared_path}/#{link} #{current_path}/#{link}"
    end
  end
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
end