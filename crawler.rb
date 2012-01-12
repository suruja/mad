# coding: utf-8

# Exit if no argument
unless ARGV.length == 4
  puts "Usage : ruby crawler.rb URL FILE DEPTH THREAD_COUNT"
  exit 1
end

# Import external libraries (gems)
require 'anemone'
require 'nokogiri'
require 'pry'

# Gather all the French stopwords
text = ''
File.open('stopwords.txt') { |f|  text = f.read }
@stopwords = text.scan(/(.+)\n/).flatten


# Init processus variables
@page_counter = 0
# @refused_access = 0

@documents = Hash.new

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
        freqs[word.downcase] += 1 unless @stopwords.include? word.downcase
      end

      @documents[page.url] = freqs
    else

      # Increment the count of the pages the crawler can't analyse
      puts "Document inaccessible : #{page.url}"
    end
  end
end

puts "Fin du crawling"
puts "Création du jeu de données en cours..."

@urls = @documents.keys
@words = @documents.values.
  inject({}){ |h1,h2| h1.merge(h2){ |_,v1,v2| v1+v2 } }.
  to_a.
  sort{ |a,b| a.last <=> b.last}.
  last(30).
  collect{ |k,v| k}.
  sort

# Open and erase the 2nd-argument-named file (or create it if it does not exist)
@freqs_file = File.new(ARGV[0], 'w+')

@words.each do |word|
  @freqs_file.write("\t#{word}")
end

@urls.each do |url|
  @freqs_file.write("\n#{url}")
  @words.each do |word|
    @freqs_file.write("\t#{@documents[url][word]}")
  end
end

puts "Jeu de données créé et enregistré dans le fichier #{ARGV[1]}."

