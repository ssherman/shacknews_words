require 'strscan'
require 'httpclient'
require 'sqlite3'

user_names = ['my+documents','soggybagel','laurgasms','perstephanie','sesmaster','korban']
shacknews_login_username = '<valid_shacknews_username>' # needed because shack requires cookies.. and to get the right filters
shacknews_password = '<password>'
number_of_pages_to_parse = 200


def get_links(content)
  content.scan(/<a href="\/laryn\.x\?id=([0-9]+)">/).map{|link_array|link_array.first}
end

def get_post_content(http_client, post_id, user_name=nil)
  url = "http://www.shacknews.com/laryn.x?id=#{post_id}"
  post_content = http_client.get_content(url)
  post_content.gsub!("\n","")
  post_content = post_content.gsub("\r","")
  post_content = post_content.gsub("\t","")
  matches = post_content.scan(/<li id="item_#{post_id}" class="sel[^"]*?">.*?<div class="postbody">(.*?)<\/div>/)
  if matches.length == 0
    puts "(#{user_name}) didn't find a post from URL: #{url}"
  else
    puts "(#{user_name}) found a post from URL: #{url}"
    return matches.first
  end
  return nil
end


for user_name in user_names

  url = "http://www.shacknews.com/search.x?type=comments&terms=&cs_user=#{user_name}"

  # Set User-Agent and From in HTTP request header.(nil means "No proxy")
  http_client = HTTPClient.new(nil, 'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-GB; rv:1.8.1.4) Gecko/20070515 Firefox/2.0.0.4', "asdf@microsoftt.com")
  main_page = http_client.get_content("http://www.shacknews.com")
  login = http_client.post("http://www.shacknews.com/login.x", {'username' => shacknews_login_username, 'password' => shacknews_password})
  puts login.inspect
  profile_page = http_client.get_content(url)


  number_of_posts_regex = /([0-9]+) results for all items/
  match = number_of_posts_regex.match(profile_page)
  number_of_posts = $1
  puts number_of_posts
    
  post_ids = get_links(profile_page)

  pages = (number_of_posts.to_i / 50)+1

  (2..number_of_pages_to_parse).to_a.to_a.each do |page|
    url = "http://www.shacknews.com/search.x?type=comments&terms=&cs_user=#{user_name}&page=#{page}"
    search_results = http_client.get_content(url)
    post_ids += get_links(search_results)
  end

  puts "about to process #{post_ids.length} posts"

  posts = []
  words = []
  db = SQLite3::Database.new( "shackers.db" )
  post_ids.each do |post_id|
    if db.execute( "select * from posts WHERE post_id=?", post_id.to_i ).length == 0
      content = get_post_content(http_client, post_id, user_name)
      unless content.nil?
        content = content.first
        db.execute( "insert into posts values ( ?, ?, ? )", post_id.to_i, user_name, content )
      end
    else
      puts "post(#{user_name}): #{post_id} is already in the database, ignoring"
    end
  end
end
