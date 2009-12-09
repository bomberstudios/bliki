module BlikiContent
  def plugin_wikilinks content
    content.gsub(/\[\[(\w+)\]\]/) do |m|
      "<a href=\"#{Sinatra::Application.base_url}/#{$1.slugalize}\">#{$1}</a>"
    end
  end
end