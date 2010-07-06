#!/usr/bin/env ruby
require 'rubygems'
require 'ruby-debug'
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
$open_tag_rx = Regexp.new("^\s*<([^\s/\?>]+)([^>]*[^\/])?>\s*")
$self_tag_rx = Regexp.new("^\s*<([^\s/\?>]+)([^>]*)?/>\s*")
$head_tag_rx = Regexp.new("^\s*<\?([^\s/>]+)([^>]*)?\?>\s*")

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

def get_branch(buffer)
  branch = []
  until buffer.empty?
    tag = {
      :tag => nil,
      :content => nil,
      :attributes => nil
    }
    
    # get next tag, and its contents
    match = $open_tag_rx.match(buffer)
    if match
      puts 'parsing ' + match[1]
      tag[:tag] = match[1]
      unless match[2].nil?
        tag[:attributes] = parse_attributes(match[2])
      end
      # match.post_match.strip!
      buffer = match.post_match
      close_match = Regexp.new("</#{tag[:tag]}>").match(buffer)
      if close_match
        # close_match.pre_match.strip!
        tag[:content] = get_branch(close_match.pre_match)
        branch << tag
        # close_match.post_match.strip!
        buffer = close_match.post_match
      else
        debugger
        raise Exception.new("Parse error: No closing tag for #{tag[:tag]} found!")
      end
    else
      # check for self-closing tags
      match = $self_tag_rx.match(buffer)
      if match
        puts 'parsing ' + match[1]
        tag[:tag] = match[1]
        unless match[2].nil?
          tag[:attributes] = parse_attributes(match[2])
        end
        branch << tag
        # match.post_match.strip!
        buffer = match.post_match
      else
        # check for head tag
        match = $head_tag_rx.match(buffer)
        if match
          # match.post_match.strip!
          buffer = match.post_match
        else
          # return buffer as text for content
          buffer.strip!
          if branch.empty? && !buffer.empty?
            return buffer
          end
        end
      end
    end
  end
  return branch
end

def parse_attributes(string)
  attributes = {}
  until string.empty?
    match = /\s*([^=]*)="([^"]*)"\s*/.match(string)
    if match
      attributes[match[1].intern] = match[2]
      string = match.post_match
    else
      raise Exception.new("Parse error: invalid attribute #{string} found!")
    end
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

def parse_file(filename)
  buffer = ''

  File.open(filename, 'r') do |feed|
    buffer = feed.read
  end
  # puts buffer
  
  return get_branch(buffer)
end

foo = parse_file('slashdot.rss')
puts foo.inspect
# buffer = ''
# File.open('slashdot.rss', 'r') do |feed| buffer = feed.read end

# tree = build_tree(buffer, tree)

# puts get_items('slashdot.rss')[2].inspect