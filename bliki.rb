# bliki power
require "rubygems"
require "lib/sinatra/lib/sinatra"
require "lib/sinatra-cache/lib/cache"
require "lib/stone/lib/stone"
require "lib/helpers"
require "lib/slugalizer"
require "lib/auth"
require "rdiscount"

#####################################################################################
# Setup
configure do
  Stone.start(Dir.pwd + "/db/#{Sinatra.env.to_s}", Dir.glob(File.join(Dir.pwd,"models/*")))
  YAML::load(File.read('config.yml')).to_hash.each do |k,v|
    set k, v
  end
  theme = Sinatra.options.theme || "default"
  set :views, "themes/#{theme}"
end
configure :development do
  set :cache_enabled, false
  set :ping, false
  Sinatra.options.development.each do |k,v|
    set k, v
  end
end
configure :production do
  disable :logging
  Sinatra.options.production.each do |k,v|
    set k, v
  end
  not_found do
    redirect "/"
  end
  error do
    redirect "/"
  end
end
configure :test do
  set :cache_enabled, false
  Sinatra.options.test.each do |k,v|
    set k, v
  end
end


before do
  content_type 'text/html', :charset => 'utf-8'
  @tags = ((Post.all.collect { |p| p.tags.split(",").collect { |t| t.strip } }.flatten) + (Page.all.collect { |p| p.tags.split(",").collect { |t| t.strip } }.flatten)).uniq.sort
end

#####################################################################################
# Atom Feed
get '/feed/' do
  content_type 'application/atom+xml', :charset => "utf-8"
  @posts = Post.all(:order => {:updated_at => :desc}).first(Sinatra.options.limit)
  cache(builder(:feed))
end


#####################################################################################
# Blog: Home
get '/' do
  all_posts = Post.all(:order => {:created_at => :desc})
  @posts = all_posts.first(Sinatra.options.limit)
  if all_posts.size > Sinatra.options.limit
    @archives = all_posts[(Sinatra.options.limit)...Sinatra.options.limit*2]
  end
  cache(erb(:home))
end

# Blog: New Post
get '/new' do
  auth
  erb(:edit)
end
post '/new' do
  auth
  post = Post.new(
    :title => params[:title],
    :body => params[:body],
    :tags => params[:tags]
  )
  post.save
  expire_cache "/"
  expire_cache "/feed/"
  # Ping
  pingomatic
  redirect "/"
end

# Blog: View Post
['/:year/:month/:day/:slug/','/post/:slug'].each do |route|
  get route do
    @post = Post.first :nicetitle => params[:slug]
    cache(erb(:view))
  end
end

# Blog: Edit Post
get '/post/:id/edit' do
  auth
  @post = Post[params[:id]]
  erb(:edit)
end
post '/post/:id/edit' do
  auth
  post = Post[params[:id]]
  post.update_attributes(
    :title => params[:title],
    :body => params[:body],
    :tags => params[:tags]
  )
  expire_cache "/"
  expire_cache "/feed/"
  expire_cache post.link
  redirect post.link
end


#####################################################################################
#### Wiki: View Page
['/:slug', '/:slug/'].each do |route|
  get route do
    params[:slug].downcase!
    @post = Page.first(:nicetitle => params[:slug])
    if @post.nil?
      redirect "/#{params[:slug]}/new"
    else
      cache(erb(:view))
    end
  end
end

# Wiki: New Page
get '/:slug/new' do
  auth
  erb(:edit)
end
post '/:slug/new' do
  auth
  @page = Page.new(
    :title => params[:title],
    :body => params[:body],
    :tags => params[:tags]
  )
  @page.save
  redirect @page.link
end

# Wiki: Edit Page
get '/:id/edit' do
  auth
  @post = Page[params[:id]]
  erb(:edit)
end
post '/:id/edit' do
  auth
  post = Page[params[:id]]
  post.update_attributes(
    :title => params[:title],
    :body => params[:body],
    :tags => params[:tags]
  )
  expire_cache post.link
  redirect post.link
end


#####################################################################################
# Archive: View Tag
get '/tag/:name' do
  @tag = params[:name]
  all_posts = (Post.all :tags.includes => @tag,:order => {:created_at => :desc}) + (Page.all :tags.includes => @tag,:order => {:created_at => :desc})
  @posts = all_posts.first(Sinatra.options.limit)
  if all_posts.size > Sinatra.options.limit
    @archives = all_posts[(Sinatra.options.limit)...all_posts.size]
  end
  erb(:archive)
end


#####################################################################################
# CSS
get '/base.css' do
  cache(sass(:base))
end

# Theme $ sIFR support
get '/css/:filename.css' do
  send_file "themes/#{Sinatra.options.theme}/css/#{params[:filename]}.css", :disposition => "inline", :type => "text/css"
end
get '/js/:filename.js' do
  send_file "themes/#{Sinatra.options.theme}/js/#{params[:filename]}.js", :disposition => "inline", :type => "text/javascript"
end
get '/swf/:filename.swf' do
  send_file "themes/#{Sinatra.options.theme}/swf/#{params[:filename]}.swf", :disposition => "inline"
end
get '/img/:filename.png' do
  send_file "themes/#{Sinatra.options.theme}/img/#{params[:filename]}.png", :disposition => "inline"
end