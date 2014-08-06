f = File.open('noise_words.txt', 'r')  
noise_words_data = f.read  
f.close

noise_words_data.gsub!(/noise_words/,'')
noise_words_data.gsub!(/\d/,'')
noise_words_data.gsub!(/[^\w\s]/,'')
noise_words = noise_words_data.split(/\s/)
noise_words.reject!{|w|w.strip == ''}
noise_words.uniq!
puts noise_words.inspect

File.open("noise_words_clean.txt", 'w') do |f2|  
  f2.puts noise_words.join("\n")  
end  