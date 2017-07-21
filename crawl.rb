require 'uri'
require "byebug"
require "typhoeus"
require_relative 'data'

class Crawl
  def initialize (url)
  end

  def scrape(pages=[])
    pages  = Page.all(:visited => false, limit: 200) unless pages[0]
    return unless pages[0]
    hydra = Typhoeus::Hydra.new(max_concurrency: 20)
    pages.each do |page|
      request = Typhoeus::Request.new(page.url, followlocation: true)
      request.on_complete do |response|
        page.update(:visited => true, :last_scraped_at => Time.now)
        create_new_links(response.body, page)
        create_new_addresses(response.body)
        #do_something_with response
      end
      hydra.queue(request)
    end
    puts "============ running hydra ============="
    hydra.run

    puts "============ run recursive ============="
    scrape(Page.all(:visited => false, limit: 200))

    # Spidr.site(@url) do |spider|
    #   spider.every_html_page do |page|
    #     page.body.scan(/[\w\d.]+[\w\d]+[\w\d.-]@[\w\d.-]+\.\w{2,6}/).each do |address|
    #       if Address.first(:email => address).nil?
    #         page_db = Page.first_or_create(
    #           { :url => page.url.to_s },
    #           {
    #             :created_at => Time.now
    #           }
    #         )

    #         Address.create(
    #           :email => address,
    #           :page => page_db,
    #           :created_at => Time.now
    #         )
    #       end
    #     end
    #   end
    # end
  end

  def create_new_addresses(body)
    body.scan(/[\w\d.]+[\w\d]+[\w\d.-]@[\w\d.-]+\.\w{2,6}/).each do |address|
      if Address.first(:email => address).nil?
        add = Address.create(
          :email => address,
          :created_at => Time.now
        )
        puts "address ========= #{address}" if add.saved?
      end
    end
  end

  def create_new_links(body, page_db)
    doc = Nokogiri::HTML.parse(body)
    page = URI.parse(page_db.url)
    urls = doc.search('a[href]').select{ |n| n['href'][/http|https|\//] }.map{ |n| n['href']}
    urls.each do |url|
      begin
        url = url.split('?')[0]
        if url[0] == "/"
          href = URI.join("#{page.scheme}://#{page.host}", url)
        else
          href = URI.parse(url)
        end
        if page.hostname == href.hostname
          pag = Page.first_or_create({:url => href.to_s}, {created_at: Time.now, visited: false, site: page_db.site})
          puts "page ================ #{href.to_s}" if pag.saved?
        end
      rescue URI::InvalidURIError => e
        puts "bad url skipping url ================ #{url}"
      rescue URI::InvalidComponentError => e
        puts "bad url 'missing opaque part' skipping url ================ #{url}"
      end
    end
  end
end
