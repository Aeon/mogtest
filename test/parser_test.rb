require 'test/unit'
require 'slashdot.rb'

class ParserTest < Test::Unit::TestCase
  # def setup
  # end

  # def teardown
  # end

  def test_parse_attributes
    str = ' link="http://foobar.com" bar="baz"'
    attributes = parse_attributes(str)
    assert(!attributes.empty?, "no attributes found")
    assert(attributes[:link] == 'http://foobar.com', "link attribute is #{attributes[:link]}")
    assert(attributes[:bar] == 'baz', "bar attribute is #{attributes[:bar]}")
  end

  def test_parse_multiple_items
    str = '<item>Description</item><item value="foo" link="bar://">Second</item>'
    branch = build_tree(str)
    # puts branch.inspect
    assert(branch.size == 2, "didn't get two items in branch")
    assert(branch[0][:content] == 'Description', "tag text is incorrect #{branch[0][:content]}")
    assert(branch[1][:content] == 'Second', "tag text is incorrect #{branch[1][:content]}")
    assert(branch[0][:attributes].nil?, "tag attributes present #{branch[0][:attributes].inspect}")
    assert(branch[1][:attributes] == {:value => 'foo', :link => 'bar://'}, "tag attributes incorrect")
  end

  def test_parse_self_closing_tag
    str = '<item value="foo"/>'
    branch = build_tree(str)
    assert(branch[0][:tag] == 'item', "tag name is #{branch[0][:tag]}")
    assert(branch[0][:attributes][:value] == 'foo', "tag attribute is incorrect #{branch[0][:attributes][:value]}")
  end

  def test_get_branch_with_self_closing_tag
    str = '<item>Description</item><item value="foo" link="bar://"/><item>Description</item>'
    branch = build_tree(str)
    assert(branch.size == 3, "didn't get 3 items in branch")
    assert(branch[0][:content] == 'Description', "tag text is incorrect #{branch[0][:content]}")
    assert(branch[1][:content].nil?, "tag text is incorrect #{branch[1][:content]}")
    assert(branch[0][:attributes].nil?, "tag attributes present #{branch[0][:attributes].inspect}")
    assert(branch[1][:attributes] == {:value => 'foo', :link => 'bar://'}, "tag attributes incorrect")
  end
  
  def test_parse_nested_branch
    str = '<bar><item>Description</item><item value="foo" link="bar://"/><item>Description</item></bar>'
    branch = build_tree(str)
    assert(branch.size == 1, "didn't get 1 items in branch")
    assert(branch[0][:tag] == 'bar', "didn't get bar items as parent")
    assert(branch[0][:content][0][:content] == 'Description', "tag text is incorrect #{branch[0][:content][0][:content]}")
    assert(branch[0][:content][1][:content].nil?, "tag text is incorrect #{branch[0][:content][1][:content]}")
    assert(branch[0][:content][0][:attributes].nil?, "tag attributes present #{branch[0][:content][0][:attributes].inspect}")
    assert(branch[0][:content][1][:attributes] == {:value => 'foo', :link => 'bar://'}, "tag attributes incorrect")
  end
  
  
  def test_parse_missing_closing_tag
    str = '<bar><item>Description<item value="foo" link="bar://"/><item>Description</item></bar>'
    assert_raise Exception do
      branch = build_tree(str)
    end
  end
end