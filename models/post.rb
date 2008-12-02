require "lib/slugalizer"

class Post
  include Stone::Resource
  include BlikiContent

  field :title, String
  field :nicetitle, String, :unique => true
  field :body, String
  field :tags, String
  field :created_at, DateTime
  field :updated_at, DateTime
  
  before_save :update_slug
end