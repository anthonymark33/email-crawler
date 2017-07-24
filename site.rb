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
