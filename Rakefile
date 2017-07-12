require 'csv'
require 'mail'
require_relative 'data'

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
      :user_name => ENV['SENDGRID_USERNAME'], 
      :password => ENV['SENDGRID_KEY'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  end

  mail = Mail.new do
    body File.read('mailer_template.txt')
  end

  Address.each do |address|
    mail['from'] = 'mandeep@eroslabs.co'
    mail[:to]    = address.email
    mail.subject = 'This is a test email'
    mail.deliver!
    address.update(:sent_count => (address.sent_count + 1), :sent_at => Time.now)
  end
end