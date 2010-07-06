#!/usr/bin/env ruby

require 'pp'
require 'slashdot.rb'
require 'rubygems'
require 'ruby-debug'

slashdot = Feed.new('slashdot.rss')

puts "\n\n\n"
puts "Feed contents:"
puts "==============\n\n"
pp slashdot.tree

puts "\n\n\n"
puts "Feed item titles:\n"
puts "=================\n\n"
items = slashdot.find('item/title')

pp items
# slashdot.pretty_print