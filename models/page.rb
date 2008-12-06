class Page
  include Stone::Resource
  include BlikiContent

  field :title, String
  field :nicetitle, String, :unique => true
  field :body, String
  field :tags, String
  field :created_at, DateTime
  field :updated_at, DateTime

  before_save :update_slug

  def link
    "/"+self.nicetitle
  end
  def edit_link
    "/"+self.id.to_s+"/edit"
  end
end