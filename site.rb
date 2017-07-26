require 'uri'
require_relative 'data'

ARGV.each do |url|
  site = Site.create(:host => url, :created_at => Time.now, :last_scraped_at => Time.now)
  page = Page.create(:url => url, :created_at => Time.now, visited: false, site: site)
  $stderr.puts "inserted #{site} into sites" if site.saved?
end

# UPDATE pages SET visited = false WHERE visited=true;
#
# https://weworkremotely.com
# https://remotefriendly.work/
# https://goremote.io
#
# INSERT INTO sites (host) VALUES ('https://goremote.io');
#INSERT INTO pages (url, visited, site_id) VALUES ('https://goremote.io', false, 4 );
