module BlikiContent
  def plugin_wikiwords content
    # take care of code blocks...
    code_blocks = []
    content.gsub!(/^    .+\n/) do |c|
      code_blocks << c
      "WONDERFUL_CODE_BLOCK"
    end
    content.gsub!(/\b([A-Z]+)([a-z]+)([A-Z]+)\w+\b/) do |m|
      "<a href=\"#{Sinatra::Application.base_url}/#{m.strip.downcase}\">#{m.strip}</a>"
    end
    content.gsub(/WONDERFUL_CODE_BLOCK/) do |code|
      code_blocks.shift
    end
  end
end