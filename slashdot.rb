$open_tag_rx = Regexp.new("^\s*<([^\s/\?>]+)([^>]*[^\/])?>\s*")
$self_tag_rx = Regexp.new("^\s*<([^\s/\?>]+)([^>]*)?/>\s*")
$head_tag_rx = Regexp.new("^\s*<\?([^\s/>]+)([^>]*)?\?>\s*")

class Feed
  @@tree = []

  def initialize(filename)
    buffer = ''
    begin
      File.open(filename, 'r') do |feed|
        buffer = feed.read
      end
      @@tree = Feed.build_tree(buffer)
      buffer = ''
    rescue Exception => e
      puts "Could not open #{filename} for parsing; check that the file exists and is readable"
      puts "Error: #{e.message}"
    end
  end
  
  def find(path)
    pieces = path.split('/')
    return self.walk(@@tree[0][:content], pieces)
  end
  
  def walk(branches, pieces)
    results = []
    current_path = pieces[0]
    branches.each do |branch|
      if branch[:tag] == current_path
        if pieces.size == 1
          results << branch
        else
          results << walk(branch[:content], pieces[1..-1])
        end
      end
    end
    return results
  end

  def tree
    @@tree
  end

  def self.build_tree(buffer)
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
          tag[:content] = Feed.build_tree(close_match.pre_match)
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

  def self.parse_attributes(string)
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
end