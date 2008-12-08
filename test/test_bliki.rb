$LOAD_PATH.unshift "../lib"

require 'rubygems'
require 'lib/sinatra/lib/sinatra'
require 'lib/sinatra/lib/sinatra/test/unit'
require 'bliki'
require 'feed_validator'
require 'fileutils'
require 'feed_validator/assertions'
require 'redgreen'

class Test::Unit::TestCase
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".downcase.to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for '#{name}'"
      end
    end
  end
end

class BlikiTest < Test::Unit::TestCase
  def setup
    # reset cache
    Dir["public/**/*"].each do |file|
      FileUtils.rm file
    end
    FileUtils.mkdir_p "test/public"
    Dir["test/public/**/*"].each do |file|
      FileUtils.rm file
    end
    # clear mock content
    Dir["db/test/datastore/**/*"].each do |file|
      FileUtils.rm file unless File.directory? file
    end
    Stone.start(Dir.pwd + "/db/#{Sinatra.env.to_s}", Dir.glob(File.join(Dir.pwd,"models/*")))
    # create one post
    p = Post.new(:title => "First post", :body => "This is a sample post", :tags => "test")
    p.save
  end
  def teardown
    # clear mock content
    Dir["db/test/datastore/**/*"].each do |file|
      FileUtils.rm file unless File.directory? file
    end
  end

  # Test application runs at all
  test "Sinatra is loaded" do
    assert_instance_of Module, Sinatra
  end
  test "Views folder is correctly setup" do
    assert_equal "themes/#{Sinatra.options.theme}", Sinatra.options.views
  end
  test "Application is running" do
    get_it "/"
    assert_equal 200, status
  end

  # Content
  test "Title is Ok" do
    get_it "/"
    assert body.scan(/#{Sinatra.options.title}/).size > 0
  end

  # Mock content
  # Make sure authorization is disabled
  test "Auth is disabled in testing environment" do
    assert_equal false, Sinatra.application.options.use_auth
  end
  # Mock content: Posts
  test "Post creation works under the hood" do
    first_post = Post.new(:title => "First post", :body => "Wadus wadus", :tags => "foo, bar")
    first_post.save
    get_it "/post/first-post"
    assert_equal 200, status
    get_it "/tag/foo"
    assert_equal 200, status
    get_it "/tag/bar"
    assert_equal 200, status
  end
  test "Post creation works over the hood" do
    post_it "/new", :title => "Second post", :body => "Wadus wadus", :tags => "wadus, badus"
    get_it "/post/second-post"
    assert_equal 200, status
    get_it "/tag/wadus"
    assert_equal 200, status
    get_it "/tag/badus"
    assert_equal 200, status
  end
  # Mock content: Pages
  test "Page creation works under the hood" do
    first_page = Page.new(:title => "First page", :body => "Wadus wadus", :tags => "foo, bar")
    first_page.save
    get_it "/first-page"
    assert_equal 200, status
    get_it "/tag/foo"
    assert_equal 200, status
    get_it "/tag/bar"
    assert_equal 200, status
  end
  test "Page creation works over the hood" do
    post_it "/2/new", :title => "Second page", :body => "Wadus wadus", :tags => "wadus, badus"
    get_it "/second-page"
    assert_equal 200, status
    get_it "/tag/wadus"
    assert_equal 200, status
    get_it "/tag/badus"
    assert_equal 200, status
  end

  # Stone
  test "Stone works as expected" do
    all_posts_start = Post.all.size
    first_post = Post[1]
    assert_equal 1, first_post.id
    new_post = Post.new(:title => "Third post", :body => "Third post", :tags => "third")
    new_post.save
    all_posts_end = Post.all.size
    assert_equal all_posts_end, all_posts_start + 1
  end
  test "Stone works with more than 99 existing posts" do
    post_count = Post.all.size
    (1..200-post_count).each do |i|
      tmp_post = Post.new(:title => "Post #{i}", :body => "Body #{i}", :tags => "tag#{i}" )
      tmp_post.save
    end
    all_posts = Post.all
    assert_equal(200, all_posts.size)
    assert_equal(200, all_posts.last.id)
    assert_equal(Post[200], all_posts.last)
    (1..100).each do |i|
      tmp_post = Post.new(:title => "Post #{i}", :body => "Body #{i}", :tags => "tag#{i}" )
      tmp_post.save
    end
    all_posts = Post.all
    assert_equal(300, all_posts.size)
    assert_equal(Post[300], all_posts.last)
  end
  test "Posts have a creation date" do
    first_post = Post[1]
    assert_not_nil first_post.created_at
  end
  test "Posts have an update date" do
    first_post = Post[1]
    assert_not_nil first_post.updated_at
    assert_kind_of DateTime, first_post.updated_at
  end
  test "Posts updated_at field is updated on save" do
    first_post = Post[1]
    original_updated_at = first_post.updated_at
    first_post.tags = "foo, bar, baz"
    first_post.save
    assert_not_equal original_updated_at, first_post.updated_at
    assert_kind_of DateTime, first_post.updated_at
  end
  test "Posts updated_at field is updated on put" do
    first_post = Post[1]
    original_updated_at = first_post.updated_at
    first_post.update_attributes(
      :tags => "foo, bar, baz"
    )
    assert_not_equal original_updated_at, first_post.updated_at
    assert_kind_of DateTime, first_post.updated_at
  end

  # Tags
  test "Tag page works" do
    get_it "/tag/tag1"
    assert_equal 200, status
  end

  # Content
  test "wikilinks are converted to links" do
    new_page = Page.new(:title => "test_page", :body => "[[wikilink1]] [[wikilink2]]", :tags => "wiki")
    new_page.save
    get_it "/test_page"
    assert body.scan("<a href=\"#{Sinatra.options.base_url}/wikilink1\">wikilink1</a>").size > 0
    assert body.scan("<a href=\"#{Sinatra.options.base_url}/wikilink2\">wikilink2</a>").size > 0
  end
  test "WikiWords are converted to links" do
    new_page = Page.new(:title => "test_wikiwords", :body => "WikiWord WikiWikiWord", :tags => "wiki")
    new_page.save
    get_it "/test_wikiwords"
    assert body.scan("<a href=\"#{Sinatra.options.base_url}/wikiword\">WikiWord</a>").size > 0
    assert body.scan("<a href=\"#{Sinatra.options.base_url}/wikiwikiword\">WikiWikiWord</a>").size > 0
  end

  # CSS: Base CSS
  test "CSS works" do
    get_it "/base.css"
    assert_equal 200, status
  end

  # Attachments
  test "attachment relationships work at model level" do
    post_with_attach = Post.new(:title => "Post with attach", :body => "this post has an attach", :tags => "attach")
    post_with_attach.save
    a = Attachment.new(:name => "foo", :path => Sinatra.options.public, :content => File.open("README.markdown").read, :post_id => post_with_attach.id)
    a.save
    b = Attachment.new(:name => "bar", :path => Sinatra.options.public, :content => File.open("README.markdown").read, :post_id => post_with_attach.id)
    b.save
    assert_equal 2, post_with_attach.attachment.size
  end
  test "Attachments are created with unique names" do
    a = Attachment.new(:name => "test_one", :path => Sinatra.options.public, :content => File.open("README.markdown").read)
    assert a.save == true
    b = Attachment.new(:name => "test_one", :path => Sinatra.options.public, :content => File.open("README.markdown").read)
    assert b.save == false
  end
  test "Files are created when saving attachments" do
    a = Attachment.new(:name => "attach", :path => Sinatra.options.public, :content => File.open("README.markdown").read)
    assert a.save == true, "File already exists"
    assert File.exist?(Sinatra.options.public / a.name ), "File not created"
  end
  test "Content for attachments is saved correctly" do
    a = Attachment.new(:name => "attach_content", :path => Sinatra.options.public, :content => File.open("README.markdown").read)
    a.save
    assert File.open(a.path / a.name,"r").read.scan("bliki").size > 1
  end

  # Feed
  test "Feed is valid" do
    get_it "/feed/"
    assert_equal 200, status
    assert_valid_feed body
  end
end