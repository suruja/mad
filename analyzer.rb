# coding: utf-8

# Exit if no argument
unless ARGV.length == 3
  puts "Usage : ruby analyzer.rb SRC DEST WORD_COUNT"
  exit 1
end

require 'pry'

puts "Création du jeu de données..."

@dest = File.new(ARGV[1], 'w+')
@src = File.open(ARGV[0], 'r') { |f| @src = f.read }.scan(/(.+)\t(.+)\t(.+)\n/)
@documents = Hash.new
@src.each do |url, word, freq|
  # binding.pry
  if @documents[url].nil?
    @documents[url] = Hash.new
  else
    @documents[url].merge!({word => freq})
  end
end

# binding.pry

@urls = @documents.keys
@words = @documents.values.
  inject({}){ |h1,h2| h1.merge(h2){ |_,v1,v2| v1+v2 } }.
  to_a.
  sort{ |a,b| a.last <=> b.last}.
  last(ARGV[2].to_i).
  collect{ |k,v| k}.
  sort

# Open and erase the 2nd-argument-named file (or create it if it does not exist)

@words.each do |word|
  @dest.write("\t#{word}")
end

@urls.each do |url|
  @dest.write("\n#{url}")
  @words.each do |word|
    @dest.write("\t#{@documents[url][word]}")
  end
end

puts "Jeu de données créé et enregistré dans le fichier #{ARGV[1]}."
