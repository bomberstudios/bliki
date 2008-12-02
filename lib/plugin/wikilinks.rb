class Post
  def plugin_wikilinks content
    content.gsub(/\[\[(\w+)\]\]/) do |m|
      "<a href=\"#{Sinatra.options.base_url}/#{$1}\">#{$1}</a>"
    end
  end
end