base_url = Sinatra.options.base_url
feed_url = base_url + "/feed/"
title = Sinatra.options.name + " - " + Sinatra.options.title
limit = Sinatra.options.limit
author_name = Sinatra.options.author_name
author_uri = base_url
# Build feed
xml.instruct! :xml, :version => "1.0"
xml.feed(:xmlns => 'http://www.w3.org/2005/Atom') do
  # Add primary attributes
  xml.id      base_url + '/'
  xml.title   title
  # Add date
  xml.updated atom_time(@posts.first.updated_at)
  # Add links
  xml.link(:rel => 'alternate', :href => base_url)
  xml.link(:rel => 'self',      :href => feed_url)
  # Add author information
  xml.author do
    xml.name  author_name
    xml.uri   author_uri
  end
  # Add posts
  @posts.each do |post|
    xml.entry do
      post_path = base_url + post.link
      post_id = "tag:" + base_url.gsub("http://","") + "," + post.created_at.strftime("%Y-%m-%d") + ":" + atom_time(post.created_at)
      # Add primary attributes
      xml.id         post_id
      xml.title      post.title, :type => 'html'
      # Add dates
      xml.published  atom_time(post.created_at)
      xml.updated    atom_time(post.updated_at)
      # Add link
      xml.link(:rel => 'alternate', :href => post_path)
      # Add content
      summary =       post.content[0..100]
      xml.content    post.content, :type => 'html'
      xml.summary    summary, :type => 'html' unless summary.nil?
    end
  end
end