class Comment
  include Stone::Resource

  field :comment_type, String
  field :comment_author_IP, String
  field :comment_parent, String
  field :comment_date, String
  field :comment_user_id, String
  field :comment_id, String
  field :comment_date_gmt, String
  field :comment_author, String
  field :comment_content, String
  field :comment_author_email, String
  field :comment_approved, String
  field :comment_author_url, String
  # field :comment_type, String
  # field :comment_author_IP, String
  # field :comment_parent, Fixnum
  # field :comment_date, DateTime
  # field :comment_user_id, Fixnum
  # field :comment_id, Fixnum
  # field :comment_date_gmt, DateTime
  # field :comment_author, String
  # field :comment_content, String
  # field :comment_author_email, String
  # field :comment_approved, Fixnum
  # field :comment_author_url, String
end