$open_tag_rx = Regexp.new("^\s*<([^\s/\?>]+)([^>]*[^\/])?>\s*")
$self_tag_rx = Regexp.new("^\s*<([^\s/\?>]+)([^>]*)?/>\s*")
$head_tag_rx = Regexp.new("^\s*<\?([^\s/>]+)([^>]*)?\?>\s*")

def build_tree(buffer)
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
      # puts 'parsing ' + match[1]
      tag[:tag] = match[1]
      unless match[2].nil?
        tag[:attributes] = parse_attributes(match[2])
      end
      # match.post_match.strip!
      buffer = match.post_match
      close_match = Regexp.new("</#{tag[:tag]}>").match(buffer)
      if close_match
        # close_match.pre_match.strip!
        tag[:content] = build_tree(close_match.pre_match)
        branch << tag
        # close_match.post_match.strip!
        buffer = close_match.post_match
      else
        # debugger
        raise Exception.new("Parse error: No closing tag for #{tag[:tag]} found!")
      end
    else
      # check for self-closing tags
      match = $self_tag_rx.match(buffer)
      if match
        # puts 'parsing ' + match[1]
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

def parse_file(filename)
  buffer = ''

  File.open(filename, 'r') do |feed|
    buffer = feed.read
  end
  
  return build_tree(buffer)
end