$LOAD_PATH.unshift "../lib"

require 'rubygems'
require 'sinatra'
require 'sinatra/test/unit'
require 'bliki'
require 'feed_validator'
require 'fileutils'
require 'feed_validator/assertions'

class BlikiTest < Test::Unit::TestCase
  def setup
    # reset cache
    ["public/*.html","public/*.css","public/post/*.html","public/wiki/*"].each do |dir|
      FileUtils.rm Dir[dir]
    end
    # clear mock content
    ["db/test/datastore/pages/*","db/test/datastore/posts/*"].each do |dir|
      FileUtils.rm Dir[dir]
    end
  end
  def teardown
    # clear mock content
    ["db/test/datastore/pages/*","db/test/datastore/posts/*"].each do |dir|
      FileUtils.rm Dir[dir]
    end
  end

  def test_for_truth
    # just because...
    assert true
  end

  # Test application runs at all
  def test_sinatra_is_loaded
    assert_instance_of Module, Sinatra
  end
  def test_views_folder
    assert_equal "themes/#{Sinatra.options.theme}", Sinatra.options.views
  end
  def test_application_is_running
    get_it "/"
    assert_equal 200, status
  end

  # Content
  def test_title_is_ok
    get_it "/"
    assert body.scan(/#{Sinatra.options.title}/).size > 0
  end

  # Mock content
  # Make sure authorization is disabled
  def test_auth_is_disabled
    assert_equal false, Sinatra.application.options.use_auth
  end
  # Mock content: Posts
  def test_post_creation_works_under_the_hood
    first_post = Post.new(:title => "First post", :body => "Wadus wadus", :tags => "foo, bar")
    first_post.save
    get_it "/post/first-post"
    assert_equal 200, status
    get_it "/tag/foo"
    assert_equal 200, status
    get_it "/tag/bar"
    assert_equal 200, status
  end
  def test_post_creation_works_over_the_hood
    post_it "/new", :title => "Second post", :body => "Wadus wadus", :tags => "wadus, badus"
    get_it "/post/second-post"
    assert_equal 200, status
    get_it "/tag/wadus"
    assert_equal 200, status
    get_it "/tag/badus"
    assert_equal 200, status
  end
  # Mock content: Pages
  def test_page_creation_works_under_the_hood
    first_page = Page.new(:title => "First page", :body => "Wadus wadus", :tags => "foo, bar")
    first_page.save
    get_it "/first-page"
    assert_equal 200, status
    get_it "/tag/foo"
    assert_equal 200, status
    get_it "/tag/bar"
    assert_equal 200, status
  end
  def test_page_creation_works_over_the_hood
    post_it "/2/new", :title => "Second page", :body => "Wadus wadus", :tags => "wadus, badus"
    get_it "/second-page"
    assert_equal 200, status
    get_it "/tag/wadus"
    assert_equal 200, status
    get_it "/tag/badus"
    assert_equal 200, status
  end

  # Stone, I hate you
  def test_stone_works_as_expected_and_not_as_a_fucking_weasel
    first_post = Post[1]
    assert_equal 1, first_post.id
    all_posts = Post.all
    assert_equal 2, all_posts.size
    new_post = Post.new(:title => "Third post", :body => "Third post", :tags => "third")
    new_post.save
    all_posts = Post.all
    assert_equal 3, all_posts.size
  end
  def test_stone_works_with_more_than_99_existing_posts
    (4..200).each do |i|
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
  def test_posts_have_a_creation_date
    first_post = Post[1]
    assert_not_nil first_post.created_at
  end
  def test_posts_have_an_update_date
    first_post = Post[1]
    assert_not_nil first_post.updated_at
  end
  def test_posts_updated_at_field_is_updated_on_save
    first_post = Post[1]
    original_updated_at = first_post.updated_at
    first_post.tags = "foo, bar, baz"
    first_post.save
    assert_not_equal original_updated_at, first_post.updated_at
  end
  # # AUTH
  # def test_auth_for_new_post
  #   post_it "/new"
  #   assert_equal 401, status
  # end
  # def test_auth_for_post_edit
  #   post_it "/post/test_post/edit"
  #   assert_equal 401, status
  # end
  # def test_auth_for_new_wiki_page
  #   post_it "/wiki/test_page/new"
  #   assert_equal 401, status
  # end
  # def test_auth_for_wiki_page_edit
  #   post_it "/wiki/test_page/edit"
  #   assert_equal 401, status
  # end
  # def test_auth_is_working
  #   # This will have to wait until I learn how to do it :)
  #   #post_it "/new", :Authorization => "Basic foo:bar"
  # end
  # 

  # Tags
  def test_tag_page_works
    get_it "/tag/tag1"
    assert_equal 200, status
  end

  # CSS: Base CSS
  def test_css_works
    get_it "/base.css"
    assert_equal 200, status
  end

  # Feed
  def test_the_damn_fucking_feed
    get_it "/feed/"
    assert_equal 200, status
    assert_valid_feed body
  end
end