require 'rubygems'
require 'sinatra'
require "lib/stone/lib/stone"
require 'sass'

require "rdiscount"
Dir["lib/*.rb"].each do |f|
  require f
end
Dir["lib/plugin/*.rb"].each do |f|
  require f
end


#####################################################################################
# Setup
def stone_start
  Stone.start(Dir.pwd + "/db/#{Sinatra::Application.environment.to_s}", Dir.glob(File.join(Dir.pwd,"models/*")))
end
def load_config
  YAML::load(File.exist?('config.yml') ? File.read('config.yml') : File.read('config.sample.yml')).to_hash.each do |k,v|
    set k, v
  end
  theme = Sinatra::Application.theme || "default"
  set :views, "themes/#{theme}"
end
def set_options_for env
  Sinatra::Application.send(env).each do |k,v|
    set k, v
  end
end
configure do
  stone_start
  load_config
end
configure :development do
  set :cache_enabled, false
  set :ping, false
  set_options_for :development
end
configure :production do
  disable :logging
  set_options_for :production
  not_found do
    redirect "/"
  end
  error do
    redirect "/"
  end
end
configure :test do
  set :cache_enabled, false
  set_options_for :test
end
if development?
  Dir["lib/*.rb"].each do |f|
    load f
  end
  Dir["lib/plugin/*.rb"].each do |f|
    load f
  end
  stone_start
  load_config
  set_options_for :development
end

before do
  content_type 'text/html', :charset => 'utf-8'
  @tags = ((Post.all.collect { |p| p.tags.split(",").collect { |t| t.strip } }.flatten) + (Page.all.collect { |p| p.tags.split(",").collect { |t| t.strip } }.flatten)).uniq.sort
end

#####################################################################################
# Atom Feed
get '/feed/' do
  content_type 'application/atom+xml', :charset => "utf-8"
  @posts = Post.all(:order => {:updated_at => :desc}).first(Sinatra::Application.limit)
  builder(:feed)
end


#####################################################################################
# CSS
get '/base.css' do
  sass(:base)
end

# Theme support
get '/:type/:filename.:ext' do
  send_file "themes/#{Sinatra::Application.theme}/#{params[:type]}/#{params[:filename]}.#{params[:ext]}", :disposition => "inline"
end


#####################################################################################
# Blog: Home
get '/' do
  all_posts = Post.all(:order => {:created_at => :desc})
  @posts = all_posts.first(Sinatra::Application.limit)
  if all_posts.size > Sinatra::Application.limit
    @archives = all_posts[(Sinatra::Application.limit)...Sinatra::Application.limit*2]
  end
  erb(:home)
end

# Blog: New Post
get '/new' do
  #auth
  erb(:edit)
end
post '/new' do
  auth
  post = Post.new(params)
  # expire_cache "/"
  # expire_cache "/feed/"
  # Ping
  pingomatic
  redirect "/"
end

# Blog: View Post
['/:year/:month/:day/:slug/','/post/:slug'].each do |route|
  get route do
    @post = Post.first :nicetitle => params[:slug]
    erb(:view)
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
  post.update_attributes(params)
  # expire_cache "/"
  # expire_cache "/feed/"
  # expire_cache post.link
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
      erb(:view)
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
  @page = Page.new(params)
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
  post.update_attributes(params)
  # expire_cache post.link
  redirect post.link
end


#####################################################################################
# Archive: View Tag
get '/tag/:name' do
  @tag = params[:name]
  all_posts = (Post.all :tags.includes => @tag,:order => {:created_at => :desc}) + (Page.all :tags.includes => @tag,:order => {:created_at => :desc})
  @posts = all_posts.first(Sinatra::Application.limit)
  if all_posts.size > Sinatra::Application.limit
    @archives = all_posts[(Sinatra::Application.limit)...all_posts.size]
  end
  erb(:archive)
end

