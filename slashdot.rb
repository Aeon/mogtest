#!/usr/bin/env ruby

# let's just grab the items info, assume we don't care about the rest of the feed metadata.

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

# only gets the first tag anyway.
def get_tag_content(input, tagname)
  rx = Regexp.new("<#{tagname}[^>]*>([^<>]*)</#{tagname}>")
  content = input.match(rx)
end

# puts get_items('slashdot.rss')[2].inspect