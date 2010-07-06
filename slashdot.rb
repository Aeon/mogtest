#!/usr/bin/env ruby
# require 'rubygems'
# require 'ruby-debug'
# let's just grab the items info, assume we don't care about the rest of the feed metadata.

grammar = {
  :document => ':xml_head :tree',
  :xml_head => /^<?xml .*>$/,
  :tree => ':tag :branch :close_tag | :self_tag',
  :branch => ':tree | :value',
  :self_tag => '<:word( :word=":value")* />',
  :tag => '<:word( :word=":value")*>',
  :close_tag => '</:word>',
  :word => /[^\s<>]*/,
  :value => /[^<>]*/
}
# 
# def parse(buffer) do
#   until buffer.empty? do
#     grammar.each do |name, pattern|
#       pattern.match()
#     end
#   end
# end

def get_items(filename)
  reading_item = false
  item = 0
  feed_items = []

  # pull out the items
  File.open(filename, 'r') do |feed|
    while line = feed.gets
      unless (line =~ /<item /).nil?
        reading_item = true
        feed_items[item] = line
        next
      end
      if reading_item
        feed_items[item] += line
        unless (line =~ /<\/item>/).nil?
          reading_item = false
          item += 1
        end
      end
    end
  end
  feed_items
end

tree = {}
$open_tag_rx = Regexp.new("<([^\s>]*)([^>]*)?>")

def parse_tree(buffer, tree)
  until buffer.empty? do
    match = $open_tag_rx.match(buffer)
    tag = {}
    if match
      tag[:tag] = match[1]
      buffer = match.post_match
      close_match = Regexp.new("</#{tag[:tag]}>").match(buffer)
      tag[:text] = close_match.pre_match
      buffer = match.post_match
      return tag
    else
    end
  end
end

def build_tree(buffer)
  tree = []
  until buffer.empty?
    next_tag = get_next_tag(buffer)
    if next_tag.nil?
      tree[] << buffer
    else
      tree[] << next_tag
    end
  end
end

def get_next_tag(buffer)
  match = $open_tag_rx.match(buffer)
  tag = {
    :tag => nil,
    :text => nil,
    :attributes => nil,
    :children => nil
  }
  if match
    tag[:tag] = match[1]
    unless match[2].nil?
      tag[:attributes] = parse_attributes(match[2])
    end
    buffer = match.post_match
    close_match = Regexp.new("</#{tag[:tag]}>").match(buffer)
    content = close_match.pre_match
    tag[:text] = content
    buffer = match.post_match
    return tag
  else
    return buffer
  end
end

def parse_attributes(string)
  attributes = {}
  until string.empty?
    match = /\s*([^=]*)="([^"]*)"\s*/.match(string)
    if match
      attributes[match[1].intern] = match[2]
    end
    string = match.post_match
  end
  attributes
end

def build_tree(buffer, tree)
  # find opening tag in buffer
  tag = buffer.match($open_tag_rx)
  unless tag.nil?
    return {:tag => tag, :children => build_tree(content, tree)}
  else
    return {:content => buffer}
  end
  # if tag has been found
    # parse tag attributes
    # return tag
  # else
    # return the buffer
  # stick everything after it into buffer
  # find closing tag
  # run build_triee on buffer
end

# tree = build_tree(buffer, tree)

# puts get_items('slashdot.rss')[2].inspect