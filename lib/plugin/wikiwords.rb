module BlikiContent
  def plugin_wikiwords content
    content.gsub(/\s([A-Z]+)([a-z]+)([A-Z]+)\w+\s/) do |m|
      " <a href=\"#{Sinatra.options.base_url}/#{m.strip.downcase}\">#{m.strip}</a> "
    end
  end
end