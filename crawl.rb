require 'uri'
require 'anemone'
require_relative 'data'

class Crawl
  def initialize urls
    @urls = urls
  end

  def scrape
    @urls.each do |target|
      uri = URI(target)
      site = Site.first_or_create({ :host => uri.host }, { :created_at => Time.now })
      $stderr.puts "Scanning #{uri.host}"
      
      Anemone.crawl(target) do |anemone|
        anemone.storage = Anemone::Storage.PStore('pages.pstore')
        anemone.on_every_page do |crawled_page|
          $stderr.puts crawled_page.url
          unless crawled_page.body.nil? && crawled_page.body == ''
            crawled_page.body.scan(/[\w\d.]+[\w\d]+[\w\d.-]@[\w\d.-]+\.\w{2,6}/).each do |address|

              if Address.first(:email => address).nil?
                page = Page.first_or_create(
                  { :url => crawled_page.url.to_s },
                  {
                    :site => site,
                    :created_at => Time.now
                  }
                )

                Address.create(
                  :email => address,
                  :site => site,
                  :page => page,
                  :created_at => Time.now
                )

                puts address
              end

            end
          end
        end
      end
    end
  end
end