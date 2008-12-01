require "lib/slugalizer"

class Page
  include Stone::Resource

  field :title, String
  field :nicetitle, String, :unique => true
  field :body, String
  field :tags, String
  field :created_at, DateTime
  field :updated_at, DateTime

  before_save :update_slug

  def update_slug
    self.nicetitle = self.title.slugalize
  end
  def date
    updated_at.strftime("%d %b %Y")
  end
  def content
    html = RDiscount.new(body).to_html
    # WikiWords
    # html.gsub!(/([A-Z]+)([a-z]+)([A-Z]+)\w+/,'<a href="/\0">\0</a>')
    # wiki links in [[link]] format
    html.gsub!(/\[\[(\w+)\]\]/,'<a href="/\1">\1</a>')
    return html
  end
  def link
    "/"+self.nicetitle
  end
  def edit_link
    "/"+self.id.to_s+"/edit"
  end
end