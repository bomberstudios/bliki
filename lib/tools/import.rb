# Import tools
require 'rubygems'
require 'rexml/document'
require 'lib/datetime'
require 'time'
require 'stone'

def parse_wordpress_xml from_filename
  file = File.read(from_filename)
  # Fix some nasty thingies
  file.gsub!("// <![CDATA[","")
  file.gsub!("// ]]>","")
  REXML::Document.new file
end

def import_wordpress_content from_filename, to_environment
  Stone.start(File.join(Dir.pwd, "db/#{to_environment}"), Dir.glob(File.join(Dir.pwd,"models/*")))

  doc = parse_wordpress_xml(from_filename)

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