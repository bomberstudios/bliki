task :clean do
  %x(rm -Rf datastore)
end

task :update do
  %x(git pull)
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
  sh("sudo gem install rack rdiscount haml builder feedvalidator validatable english facets")
  sh("git submodule init")
  sh("git submodule update")
end

desc "Create initial configuration"
task :configure do
  require "lib/tools/configuration"
  Bliki::Configuration::configure "config.sample.yml", "config.yml"
end

namespace :import do
  desc "Clean imported data. Run with DB=environment (default: development)"
  task :clean do
    %x(rm -Rf db/#{ENV['DB'] || 'development'}/*)
  end
  desc "Import contents from WordPress XML. Run with DB=environment (default: development)"
  task :wordpress => :clean do
    require 'lib/tools/import'
    import_wordpress_content(ENV['FILE'] || "db/wordpress.xml", ENV['DB'] || 'development')
  end
end

task :deploy do
  require "yaml"
  options = YAML.load(File.read("config.yml"))["deploy"]
  sh("git push")
  sh("scp config.yml #{options['hostname']}:#{options['folder']}/config.yml")
  sh("rsync -azc themes/ #{options['hostname']}:#{options['folder']}/themes/")
  sh("ssh #{options['username']}@#{options['hostname']} 'cd #{options['folder']}; rake update'")
end
task :default => :test
