module BlikiContent
  def plugin_wikiwords content
    content.gsub(/([A-Z]+)([a-z]+)([A-Z]+)\w+/) do |m|
      " <a href=\"#{Sinatra.options.base_url}/#{m.strip.downcase}\">#{m.strip}</a> "
    end
  end
end