require 'uri'
require 'spidr'
require "byebug"
require_relative 'data'

class Crawl
  def initialize (url)
    @url = "https://www.bluenation.co/"
  end

  def scrape
    Spidr.site(@url) do |spider|
      spider.every_html_page do |page|
        page.body.scan(/[\w\d.]+[\w\d]+[\w\d.-]@[\w\d.-]+\.\w{2,6}/).each do |address|
          if Address.first(:email => address).nil?
            page_db = Page.first_or_create(
              { :url => page.url.to_s },
              {
                :created_at => Time.now
              }
            )

            Address.create(
              :email => address,
              :page => page_db,
              :created_at => Time.now
            )
          end
        end
      end
    end
  end
end
