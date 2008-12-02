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
  require "lib/configuration"
  Bliki::Configuration::configure "config.sample.yml", "config.yml"
end

namespace :import do
  desc "Clean imported data"
  task :clean do
    %x(rm -Rf db/#{ENV['DB']}/*)
  end
  desc "Import contents from WordPress XML"
  task :wordpress => :clean do
    # Some code taken from http://github.com/swenson/scanty_wordpress_import/raw/master/import.rb
    require 'rubygems'
    require 'rexml/document'
    require 'time'
    require 'stone'

    file = File.read("db/wordpress.xml")

    Stone.start(File.join(Dir.pwd, "db/#{ENV['DB']}"), Dir.glob(File.join(Dir.pwd,"models/*")))

    # Fix some nasty thingies
    file.gsub!("// <![CDATA[","")
    file.gsub!("// ]]>","")
    doc = REXML::Document.new file
    doc.root.elements["channel"].elements.each("item") do |item| 
      # if it's a published post, then we import it
      if item.elements["wp:post_type"].text == "post" and item.elements["wp:status"].text == "publish" then
        post_id = item.elements["wp:post_id"].text.to_i
        title = item.elements["title"].text
        content = item.elements["content:encoded"].text
        time = DateTime.parse(item.elements["wp:post_date"].text)
        tags = []
        item.elements.each("category") { |cat|
          tags << cat.text
        }
        tags = tags.map { |t| t.downcase }.sort.uniq.join(", ")
        post = Post.new(:title => title, :body => content, :tags => tags, :created_at => time, :updated_at => time)
        post.save
        post.update_attributes(
          :created_at => time,
          :updated_at => time
        )
        puts post.nicetitle
      end
    end
  end
end

task :deploy do
  require "yaml"
  options = YAML.load(File.read("config.yml"))["deploy"]
  sh("git push")
  sh("scp config.yml #{options['hostname']}:#{options['folder']}/config.yml")
  sh("rsync -azc themes/ #{options['hostname']}:#{options['folder']}/themes/")
  sh("ssh #{options['hostname']} 'cd #{options['folder']}; rake update'")
end
task :default => :test
