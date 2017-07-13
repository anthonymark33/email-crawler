require 'uri'
require_relative 'data'

ARGV.each do |site|
  site = Site.create(:host => site, :created_at => Time.now)
  $stderr.puts "inserted #{site} into sites" if site.saved?
end