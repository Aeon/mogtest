# dirty and simple rss parser

run demo.rb to see output of 

* pretty printed rss feed content
* just the list of titles in the feed

# Caveats

* It's not a real parser. No validation.
* It loads the whole file into memory. No line-by-line parsing here. So, don't try to parse 500Mb rss feeds.