#!/usr/bin/env ruby

require 'slashdot.rb'
tree = parse_file('slashdot.rss')
puts tree.inspect
