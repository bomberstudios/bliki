require 'rubygems'
require 'lib/stone/lib/stone'
require 'lib/tools/import'
require "lib/tools/configuration"
require "yaml"
require 'rexml/document'
require 'time'
require 'pp'

task :clean do
  %x(rm -Rf datastore)
end

task :update do
  %x(git pull)
  %x(git submodule update)
  %x(touch tmp/restart.txt)
  %x(rm -Rf public/*)
end

task :restart do
  %x(touch tmp/restart.txt)
end

task :test do
  %x(mkdir db) unless File.exist?("db")
  %x(mkdir db/test) unless File.exist?("db/test")
  sh("ruby test/test_bliki.rb")
end

task :install do
  sh("sudo gem install rack rdiscount haml builder feedvalidator validatable english mongrel daemons")
  sh("git submodule init")
  sh("git submodule update")
end

desc "Create initial configuration"
task :configure do
  Bliki::Configuration::configure "config.sample.yml", "config.yml"
end

namespace :import do
  desc "Clean imported data in DB=environment (default: development)"
  task :clean do
    %x(rm -Rf db/#{ENV['DB'] || 'development'}/*)
  end
  desc "Import posts from WordPress in DB=environment (default: development)"
  task :wordpress => :clean do
    import_wordpress_content(ENV['FILE'] || "db/wordpress.xml", ENV['DB'] || 'development')
  end
  desc "Import comments from WordPress XML in DB=environment (default: development)"
  task :comments => :clean do
    import_wordpress_comments()
  end
  # task :models do
  #   update_model_files
  # end
end

task :deploy do
  options = YAML.load(File.read("config.yml"))["deploy"]
  sh("scp config.yml #{options['username']}@#{options['hostname']}:#{options['folder']}/config.yml")
  sh("rsync -arzc -e=ssh themes/ #{options['username']}@#{options['hostname']}:#{options['folder']}/themes/")
  sh("ssh #{options['username']}@#{options['hostname']} 'cd #{options['folder']}; rake update'")
end
task :default => :test
