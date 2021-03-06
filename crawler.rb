# coding: utf-8

# Exit if no argument
unless ARGV.length == 4
  puts "Usage : ruby crawler.rb URL FILE DEPTH THREAD_COUNT"
  exit 1
end

# Import external libraries (gems)
require 'anemone'
require 'nokogiri'

# Gather all the French stopwords
text = ''
File.open('stopwords.txt') { |f|  text = f.read }
@stopwords = text.scan(/(.+)\n/).flatten

@freq_file = File.new(ARGV[1], 'w+')

# Init processus variables
@page_counter = 0

# Execute the Anemone crawling
Anemone.crawl(ARGV[0], { :depth_limit => ARGV[2].to_i, :threads => ARGV[3].to_i }) do |anemone|

  puts "Début du crawling à partir de #{ARGV[0]}..."

  anemone.skip_links_like(/.+(\/.+:|index.php)/).on_every_page do |page|

    # If the document is accessible
    unless page.doc.nil?
      @page_counter += 1
      puts "(#{@page_counter}) #{page.url}"

      freqs = Hash.new(0)

      # Scan all the words of the current document content
      page.doc.css('#bodyContent').text.scan(/[a-zA-Zâêôûéàùèçœ]+/).each do |word|

        # Fill the word-frequency hash with the current word unless it is a stopword (such as "je" or "que")
        unless @stopwords.include? word.downcase
          freqs[word.downcase] += 1
          @freq_file.write("#{page.url}\t#{word.downcase}\t#{freqs[word.downcase]}\n")
        end
      end

    else
      # Increment the count of the pages the crawler can't analyse
      puts "Document inaccessible : #{page.url}"
    end
  end
end

puts "Fin du crawling"
