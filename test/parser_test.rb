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
end