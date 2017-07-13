require 'uri'
require_relative 'data'

ARGV.each do |site|
  uri = URI(site)
  site = Site.create(:host => uri.host, :created_at => Time.now)
  $stderr.puts "inserted #{uri.host} into sites" if site.saved?
end