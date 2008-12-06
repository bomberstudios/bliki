class Post
  include Stone::Resource
  include BlikiContent

  field :title, String
  field :nicetitle, String, :unique => true
  field :body, String
  field :tags, String
  field :created_at, DateTime
  field :updated_at, DateTime

  has_many :attachment
  before_save :update_slug
end