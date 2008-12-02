module BlikiContent
  def plugin_gist_link content
    content.gsub(/<gist:(\d+)>/) do |m|
      "<script src=\"http://gist.github.com/#{$1}.js\"></script>"
    end
  end
end