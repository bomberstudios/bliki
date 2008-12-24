require 'test/helper'

class BlikiPluginsTest < Test::Unit::TestCase
  test "WikiWords plugin works" do
    new_page = Page.new(:title => "wikiword test one", :body => "WikiWord", :tags => "wiki")
    get_it '/wikiword-test-one'
    assert_match /<a href=\"(.+)\">WikiWord<\/a>/, body
  end
  test "WikiWords plugin does not break code blocks" do
    new_page = Page.new(:title => "wikiword test two", :body => "WikiWord\n    f = FooBar.new", :tags => "wiki")
    get_it '/wikiword-test-two'
    assert_no_match(/<a href=\"(.+)\">FooBar<\/a>/, body)
  end
end