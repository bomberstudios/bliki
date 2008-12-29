require "lib/slugalizer"

module BlikiContent
  def update_slug
    self.nicetitle = self.title.slugalize
  end
  def date
    self.created_at.strftime("%d %b %Y")
  end
  def day
    self.created_at.strftime("%d")
  end
  def month
    self.created_at.strftime("%m")
  end
  def year
    self.created_at.strftime("%Y")
  end
  def content
    content_plugins = body
    self.methods.sort.each do |m|
      content_plugins = self.send(m, content_plugins) if m =~ /^plugin_/
    end
    RDiscount.new(content_plugins).to_html.chomp
  end
  def link
    "/#{self.year}/#{self.month}/#{self.day}/#{self.nicetitle}/"
  end
  def edit_link
    "/#{self.class.to_s.downcase}/#{self.id.to_s}/edit"
  end
end