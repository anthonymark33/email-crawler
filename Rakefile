require 'csv'
require 'mail'
require_relative 'data'
require_relative 'crawl'
require_relative 'constants'
require "byebug"

task :export do

  CSV.open("addresses.csv", "wb") do |csv|
    csv << ["address", "time", "host", "page"]

    Address.each do |address|
      csv <<
        [
          address.email,
          address.created_at.strftime('%a %b %e %Y %I:%M:%S %p'),
          address.site.host,
          address.page.url
        ]
    end
  end

  puts "#{Address.count} addresses exported to addresses.csv"

end

task :send_email do
  Mail.defaults do
    delivery_method :smtp, {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => SENDGRID_USERNAME,
      :password => SENDGRID_KEY,
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  end

  mail = Mail.new do
    body File.read('mailer_template.txt')
  end
  Address.all(:sent_at.lte => (DateTime.now + 30)).each do |address|
    mail['from'] = 'mandeep@eroslabs.co'
    mail[:to]    =  address.email
    mail.subject = 'This is a test email'
    mail.deliver!
    address.update(:sent_count => (address.sent_count + 1), :sent_at => DateTime.now)
  end
end

task :crawl_existing_pages do

  Site.all(:last_scraped_at.lte => (DateTime.now + 15)).each do |site|
    crawl = Crawl.new site.host
    crawl.scrape
    site.update(:last_scraped_at => DateTime.now)
  end
end
