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
    html = RDiscount.new(body).to_html
    # wiki links in [[link]] format
    html.gsub!(/\[\[(\w+)\]\]/,'<a href="'+Sinatra.options.base_url+'/\1">\1</a>')
    # WikiWords
    # html.gsub!(/([A-Z]+)([a-z]+)([A-Z]+)\w+/,'<a href="'+Sinatra.options.base_url+'/wiki/\0">\0</a>')
    return html
  end
  def link
    "/#{self.year}/#{self.month}/#{self.day}/#{self.nicetitle}/"
  end
  def edit_link
    "/#{self.class.to_s.downcase}/#{self.id.to_s}/edit"
  end
end