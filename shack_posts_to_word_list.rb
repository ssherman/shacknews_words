require 'strscan'
require 'httpclient'
require 'sqlite3'
require 'stemmer'

f = File.open('noise_words_clean.txt', 'r')  
noise_words = f.read  
f.close

noise_words = noise_words.split("\n")
noise_words.map!{|word| word.strip}

class String
  # Removes HTML tags from a string. Allows you to specify some tags to be kept.
  def strip_html( allowed = [] )    
    re = if allowed.any?
      Regexp.new(
        %(<(?!(\\s|\\/)*(#{
          allowed.map {|tag| Regexp.escape( tag )}.join( "|" )
        })( |>|\\/|'|"|<|\\s*\\z))[^>]*(>+|\\s*\\z)),
        Regexp::IGNORECASE | Regexp::MULTILINE, 'u'
      )
    else
      /<[^>]*(>+|\s*\z)/m
    end
    gsub(re,' ')
  end
end



user_name = ARGV.first

db = SQLite3::Database.new( "shackers.db" )

words = []
db.execute( "SELECT * from posts where username = ?", user_name).each do |row|
  post_content = row[2]
  post_content = post_content.strip_html
  post_content = post_content.gsub(/(http|www|ftp|https):[^\s]*/, '')
  post_content = post_content.gsub(/'s/,'')
  post_content = post_content.gsub(/\./,' ')
  post_content = post_content.gsub(/[\/\\]/,' ')
  post_content = post_content.gsub(/[^A-Za-z0-9\s]/, '')
  post_words = post_content.split(/\s/).map{|w|w.downcase.strip unless noise_words.include?(w.downcase.strip) || w.strip.length > 25 || w.strip =~ /^\d+$/ || w.strip.length == 2}.compact
  #post_words.map!{|pw| pw[-1,1] == "s" ? pw.stem : pw}
  words += post_words
end
puts words.length
File.open("#{user_name}-#{words.length}.txt", 'w') do |f2|  
  f2.puts words.join(" ")  
end  