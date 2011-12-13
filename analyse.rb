# coding: utf-8

text = ''
File.open(ARGV[0]) { |f|  text = f.read }
@stopwords = text.scan(/(.+)\n/).flatten
# puts @stopwords.sort_by{|key, value| value}
puts @stopwords.max_by{|k,v| v}
