# Import tools
require 'rubygems'
require 'rexml/document'
require 'time'
require 'stone'
require 'pp'

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
  posts = find_posts_in doc
  posts.each do |post|
    current_post = Post.new(:title => post[:title], :body => post[:content], :tags => post[:tags], :created_at => post[:time], :updated_at => post[:time])
    current_post.save
    current_post.update_attributes(
      :created_at => post[:time],
      :updated_at => post[:time]
    )
    puts current_post.nicetitle
  end
end

def import_wordpress_comments
  Stone.start(File.join(Dir.pwd, "db/import"), Dir["#{Dir.pwd}/lib/tools/models/*"])
  doc = parse_wordpress_xml("db/wordpress.xml")
  comments = find_comments_in doc
  comments.each do |comment|
    current_comment = Comment.new
    comment.each do |k,v|
      current_comment.send(k.to_s+"=",v)
    end
    current_comment.save
  end
  # Now, import comments
  all_comments = Comment.all
  all_comments.each do |c|
    puts c.comment_author
  end
end

def find_posts_in doc
  posts = []
  doc.get_elements("//item").each do |item| 
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
      posts << {
        :post_id => post_id,
        :title => title,
        :content => content,
        :time => time,
        :tags => tags
      }
    end
  end
  return posts
end

def find_comments_in doc
  comments = []
  doc.get_elements("//wp:comment").each do |comment|
    if comment.elements["wp:comment_approved"].text == "1"
      current_comment = {}
      comment.elements.each do |e|
        current_comment[e.name.to_sym] = e.text
      end
      # TODO: Find which post the comment belongs to...
      comments << current_comment
    end
  end
  comments
end

def wordpress_xml_to_database file
  #file = File.read(from_filename)
  Stone.start(File.join(Dir.pwd, "db/import"), Dir.glob(File.join(Dir.pwd,"lib/tools/models/*")))
  # Find pages
  doc = parse_wordpress_xml(file)
end

# def update_model_files
#   file_contents = <<-RUBY
# class Comment
#   include Stone::Resource
# RUBY
#   doc = parse_wordpress_xml("db/wordpress.xml")
#   doc.get_elements("//wp:comment").first do |comment|
#     fields = ""
#     comment.elements.each do |e|
#       fields += "field #{e.name.to_sym}"
#     end
#   end
#   file_contents = file_contents + fields.join("\n") + "end"
#   File.open("lib/tools/models/comments.rb","w") do |f|
#     f << file_contents
#   end
# end