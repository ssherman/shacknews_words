i wrote this a million years ago. i have no idea how it works. It seems like "noise_words.txt" is missing but that should be easy enough to find. this is how i think it works:

** run clean_up_noise_words.rb (if needed)
** replace username and password in shack_words.rb
** change names array to users you want to parse(or fork and make it an arg)
** run shack_posts_to_word_list.rb


FYI

** i doubt this still works. the regexs will probably fail
** you'll need to look in the sqlite db to figure out the table structure