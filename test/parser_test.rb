require 'test/unit'
require 'slashdot.rb'

class ParserTest < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_get_items
    item_count = get_items('slashdot.rss').size
    assert(item_count == 15, "Got #{item_count} items instead of 15")
  end
  
  def test_get_tag
    str = '<item>Description</item>'
    tag = get_next_tag(str)
    assert(tag[:tag] == 'item', "tag name is #{tag[:tag]}")
    assert(tag[:text] == 'Description', "tag text is incorrect #{tag[:text]}")
  end

  def test_parse_attributes
    str = ' link="http://foobar.com" bar="baz"'
    attributes = parse_attributes(str)
    assert(!attributes.empty?, "no attributes found")
    assert(attributes[:link] == 'http://foobar.com', "link attribute is #{attributes[:link]}")
    assert(attributes[:bar] == 'baz', "bar attribute is #{attributes[:bar]}")
  end

  def test_get_tag_with_attributes
    str = '<item link="http://foobar.com">Description</item>'
    tag = get_next_tag(str)
    assert(tag[:tag] == 'item', "tag name is #{tag[:tag]}")
    assert(!tag[:attributes].nil?, "tag attributes are missing")
    assert(tag[:attributes][:link] == 'http://foobar.com', "tag link attribute is incorrect #{tag[:attributes][:link]}")
  end

  def test_get_branch
    str = '<item>Description</item><item value="foo" link="bar://">Second</item>'
    branch = get_branch(str)
    assert(branch.size == 2, "didn't get two items in branch")
    assert(branch[0][:content] == 'Description', "tag text is incorrect #{branch[0][:content]}")
    assert(branch[1][:content] == 'Second', "tag text is incorrect #{branch[1][:content]}")
    assert(branch[0][:attributes].empty?, "tag attributes present #{branch[0][:attributes].inspect}")
    assert(branch[1][:attributes] == {:value => 'foo', :link => 'bar://'}, "tag attributes incorrect")
  end

  def test_parse_self_closing_tag
    str = '<item value="foo"/>'
    branch = get_branch(str)
    assert(branch[0][:tag] == 'item', "tag name is #{branch[0][:tag]}")
    assert(branch[0][:attributes][:value] == 'foo', "tag attribute is incorrect #{branch[0][:attributes][:value]}")
  end

  def test_get_branch_with_self_closing_tag
    str = '<item>Description</item><item value="foo" link="bar://"/><item>Description</item>'
    branch = get_branch(str)
    assert(branch.size == 3, "didn't get 3 items in branch")
    assert(branch[0][:content] == 'Description', "tag text is incorrect #{branch[0][:content]}")
    assert(branch[1][:content].nil?, "tag text is incorrect #{branch[1][:content]}")
    assert(branch[0][:attributes].empty?, "tag attributes present #{branch[0][:attributes].inspect}")
    assert(branch[1][:attributes] == {:value => 'foo', :link => 'bar://'}, "tag attributes incorrect")
  end
  
  def test_parse_nested_branch
    str = '<bar><item>Description</item><item value="foo" link="bar://"/><item>Description</item></bar>'
    branch = get_branch(str)
    puts branch.inspect
    assert(branch.size == 1, "didn't get 1 items in branch")
    assert(branch[0][:tag] == 'bar', "didn't get bar items as parent")
    assert(branch[0][:content][0][:content] == 'Description', "tag text is incorrect #{branch[0][:content][0][:content]}")
    assert(branch[0][:content][1][:content].nil?, "tag text is incorrect #{branch[0][:content][1][:content]}")
    assert(branch[0][:content][0][:attributes].empty?, "tag attributes present #{branch[0][:content][0][:attributes].inspect}")
    assert(branch[0][:content][1][:attributes] == {:value => 'foo', :link => 'bar://'}, "tag attributes incorrect")
  end

  # def test_parse_simple_tree
  #   str = '<item>Description</item>'
  #   tree = parse_tree(str, {})
  #   assert(tree[:tag] == 'item', 'tag name is incorrect')
  #   assert(tree[:text] == 'Description', 'tag text is incorrect')
  #   assert(tree[:children].empty?, 'tag children are not empty')
  #   assert(tree[:attributes].empty?, 'tag attributes are not empty')
  # end
end