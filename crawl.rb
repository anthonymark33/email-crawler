require 'uri'
require "byebug"
require "typhoeus"
require 'oga'
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
        byebug
        page.update(:visited => true, :last_scraped_at => Time.now)
        create_new_links(response.body, page)
        create_new_addresses(response.body)
        #do_something_with response
      end
      hydra.queue(request)
    end
    hydra.run
    byebug
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
    byebug
    body.scan(/[\w\d.]+[\w\d]+[\w\d.-]@[\w\d.-]+\.\w{2,6}/).each do |address|
      if Address.first(:email => address).nil?
        Address.create(
          :email => address,
          :created_at => Time.now
        )
      end
    end
  end

  def create_new_links(body, page)
    byebug
    doc = Nokogiri::HTML.parse(body)
    page = URI.parse(page.url)
    urls = doc.search('a[href]').select{ |n| n['href'][/http/] }.map{ |n| n['href']}
    urls.each do |url|
      byebug
      url = url.split('?')[0]
      href = URI.parse(url)
      if page.hostname == href.hostname
        Page.first_or_create({:url => url}, {created_at: Time.now, visited: false,})
      end
    end
  end
end
