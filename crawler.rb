# coding: utf-8

# Import external libraries (gems)
require 'anemone'
require 'nokogiri'
require 'pry'

# Gather all the French stopwords
text = ''
File.open('stopwords.txt') { |f|  text = f.read }
@stopwords = text.scan(/(.+)\n/).flatten

# Open and erase the 2nd-argument-named file (or create it if it does not exist)
@freqs_file = File.new(ARGV[1], 'w+')
@freqs_file.write("url\tword\tfrequency\n")

# Init processus variables
@page_counter = 0
@refused_access = 0

# Execute the Anemone crawling with 15 simultaneous threads, collecting 1000 pages maximum
Anemone.crawl("http://fr.wikipedia.org/wiki/Analyse_de_donn%C3%A9es", { :threads => 15, :depth_limit => 5 }) do |anemone|
  anemone.skip_links_like(/.+(\/.+:|index.php)/).on_every_page do |page|

    # If the document is accessible
    unless page.doc.nil?
      @page_counter += 1
      puts "(#{@page_counter}) #{page.url}"

      freqs = Hash.new(0)

      # Scan all the words of the current document content
      page.doc.css('#bodyContent').text.scan(/[a-zA-Zâêôûéàùè]+/).each do |word|

        # Fill the word-frequency hash with the current word unless it is a stopword (such as "je" or "que")
        freqs[word.downcase] += 1 unless @stopwords.include? word.downcase
      end

      # Write in the 2nd-argument-named file in the format : url\tword\tfrequency\n
      freqs.each do |key, value|
        @freqs_file.write("#{page.url}\t#{key}\t#{value}\n")
      end

      freqs
    else

      # Increment the count of the pages the crawler can't analyse
      puts "Document inaccessible : #{page.url}"
      @refused_access += 1
    end

    # If the crawler reaches the website quotas or if the count of crawled pages is sufficient
    if @page_counter == ARGV[0].to_i or @refused_access == 20

      # Exit the crawler
      exit 0
    end
  end
end

