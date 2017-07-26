require 'uri'
require "byebug"
require "typhoeus"
require_relative 'data'
require 'mail'
require 'mailgun'

class Crawl
  def initialize
    system("rm tmp/crawl.pid")
    system("echo #{Process.pid} >tmp/crawl.pid")
  end

  def self.send_emails
    # API Base URL
    # https://api.mailgun.net/v3/mg.doublegeek.co
    # API Key
    # key-1c997ce3dbe2d26d5a3ec6601f28960f
    mg_client = Mailgun::Client.new 'key-1c997ce3dbe2d26d5a3ec6601f28960f'
    message_params =  { from: 'Vipin Nagpal <vipin@doublegeek.co>',
                        to:   'vipin.itm@gmail.com',
                        subject: 'Looking forward to work with you',
                        text:    "Hi there,

I hope you're having a great day!

My name is Vipin Nagpal, I am the founder of DoubleGeek. DoubleGeek is a community of developers dedicated to learning and sharing latest design and development tips through the public platform. We also specialize in building scalable web and mobile applications of all kind. We have been helping some really cool startups with all their engineering efforts for last 5 years.

We have worked with companies like MyTime, WeWork, Disney, Best Buy, Chipotle and more. Although our portfolio consists of some great names, we do not charge premium rates.

Whether you have a startup idea or already have a product you want to build on, we can help to a great extent. Spend a few more minutes going through our portfolio at http://hire.doublegeek.co/ and take a look at what we are up to at http://www.doublegeek.co/.

In case you don't have any work for us right now, please refer us to anyone you know of, who could use our services.

PS: We are running some great offers on our services for next two months. Ask us anything by replying to this email.

Cheers!
--
Vipin Nagpal
doublegeek.co | +91 9990222687"
                      }

    addrs  = Address.all(:sent_count.lt => 1 )
    addrs.each do |addr|
      message_params[:to] = addr.email

      begin
        res = mg_client.send_message 'mg.doublegeek.co', message_params
        puts "Sent: #{addr.email} #{res.code}"
        addr.update(sent_count: addr.sent_count + 1, sent_at: Time.now)
      rescue Exception => e
        puts e.message
        raise e
      end
      sleep(37)
    end
  end

  def scrape(pages=[])
    pages  = Page.all(:visited => false, limit: 200) unless pages[0]
    return unless pages[0]
    hydra = Typhoeus::Hydra.new(max_concurrency: 20)
    pages.each do |page|
      request = Typhoeus::Request.new(page.url, cookiefile: "~/tcookie", cookiejar: "~/tcookiezar", followlocation: true, headers: {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17""Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17"})
      request.on_complete do |response|
        puts "."
        puts "Ghanta Ghanta Ghanta Ghanta Ghanta" if response.body == "" or response.body == " "
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
          if Page.first(:url => href.to_s).nil?
            pag = Page.create({:url => href.to_s, created_at: Time.now, visited: false, site: page_db.site})
          end
        end
      rescue URI::InvalidURIError => e
        puts "bad url skipping url ================ #{url}"
      rescue URI::InvalidComponentError => e
        puts "bad url 'missing opaque part' skipping url ================ #{url}"
      end
    end
  end

  def self.create_email
    emails = %W(contact@eslam.me nodeskco@gmail.com help@alist.co hello@remotefriendly.work name@example.com hello@jobscri.be support@talentboard.me support@talantboard.com hello@remotebase.io username@example.com hello@sideprojectors.com hey@goremote.io kevin@refer-me-please.com contact@refer-me-please.com you@company.com abuse@angel.co jobs@example.com mail@example.com corey@ginja.co.th Recruiting@konsus.com jobs@aha.io jobs@crunch.io hello@count.ly nicole@mediavine.com jobs@teaching.com hello@cloudpeeps.com smacartney@seek.com.au jane@company.com support@weworkremotely.com info@wildbit.com Dreamjob@virtualQ.io syst0458@applications.recruiterbox.com jobs@podomatic.com careers@paylinedata.com support@textmaster.com lance@pandastrike.com ankur@hostmaker.co jobs@fogcreek.com jobs@nationbuilder.com josh@procentive.com eric@kaleosoftware.com applications@adbutler.com jobs@careerfoundry.com careers@whitecapseo.com jobs@cprcallblocker.com jobs@quickmail.io dapulse.usa@applynow.io rachel@customer.io matthew.gossage@crometrics.com chris@crometrics.com tom@crometrics.com jobs@revenviews.com jobs@cvedia.com jobs@bookingsync.com jobs@partsmarket.com alison@learninginaction.com recruiting@howtogettheguy.com jobs@teamgantt.com jobs@kinsta.com jobs@gothamclubmedia.com job.trd2s@hammer.recruitee.com technicalwriting@alliancesmanagement.com jobs@paperlesspipeline.com jobs@simpletexting.net jamie@vebolife.com apply@secretbenefits.com pmjobs@ifsight.com slice@silverorange.com brad@bettermarketingllc.com jobs@expensify.com jobs@hazelcast.com marnierobbins@hrcreativedesign.com sergio.pereira@tr.com contact@singaporedatacompany.com careers@decisiv.com media@remoteyear.com welcome@remoteyear.com privacy@remoteyear.com steve@example.com martymcfly@email.com martymcfly@mail.com logo@2x-68x69.png March-@-2017-07-05-121626.png Icon@2x.png james@zapier.com jobs@bevylabs.com Jobs@xapo.com jobs@cyza.com hllazo@geisinger.edu jobs@cloudpeeps.com beecommhr@gmail.com jobs@pandastrike.com jonathan@switchup.org ateams@fightforthefuture.org frontend2017@realaudience.se careers@glassbreakers.co jobs@beargroup.com jessica@xmodesocial.com jobs@weaveup.com gld@fastmail.com software@stasislabs.com careers@simple.com management@forwardfinancing.com jobs@loco2.com ofir@languagezen.com birtwell@jovio.com jointheteam@overlaphealth.com hnjobs@udacity.com bert@benzinga.com jannes.stubbemann@kwiqjobs.com team@uphex.com jobs@politech.io julian@singleops.com devjob_q3_2017@buysellads.com jpollak@coinbase.com melissa@thinkful.com datascience@devexi.com careers@motel.is jobs@agflow.com hiring@onspecta.com adam@freeplay-app.com hire2@mobymax.com hareesh@towerviewhealth.com hello@tealmedia.com atzdurant@mednet.ucla.edu dcoshow@accolo.com jobsEMEA@bcdtravel.nl position@thinkful.com jobs@airesume.com rschultz@grio.com info@friendsaddict.com jobadmin@semanticbits.com careers@rechargeapps.com medwards@instructure.com harsha.nitj14@gmail.com hiring@iopipe.com TalentAcquisition@grubhub.com dsanderson@surgeforward.com jobs@codelathe.com jobs@browzzin.com Kayla.Davis@learncore.com audree@triceimaging.com devjobs@ifsight.com g.vrakking@efficiency-online.nl resume@careevolution.com jobs@nstack.com jobs@truqc.com careers@mixmax.com brett@donationspring.com chris@wrstudios.com connect@ahrefs.com technicaljobs@nytimes.com heather.khoury@nytimes.com jparker@gmail.com adam@gyroscope.cc austen.lein@nytimes.com hireme@inverseparadox.net jonas@monzo.com info@yourotherhalfsolutions.com Recruitment2@internationalservicecheck.com work@parsely.com jobs@mindfulchef.com awesomejob@4Dpipeline.com jodi.franco@crowdstrike.com mmcfarland@kcura.com recruit@human-computer.com career@proemion.com work@redvanworkshop.com technology@gallagherdesign.com billy@tixit.me brad.murphy@gearstream.com jobs@imerit.net azer@getkozmos.com andrei@divvit.com jannes.stubbemann@swarms.tech hello@trippin.world jobs@gravitational.com recruitmentspain@sequel.com careers@gruntwork.io jobs@privateinternetaccess.com aron@SimpleTix.com jobs@timocom.com info@51blocks.com jobs@mimacom.com rweichler@gmail.com careers@ahamediagroup.com jobs@conqa.nz info@medcrypt.co khang@picocandy.com roger@flip.lease mike@librato.com armen@streamable.com jobs@golightstream.com shlomo@platformwatch.com admin@9cloud.us keela@blackstormlabs.com jobs@cloudcraft.co careers@gramercy.io careers@sulvo.com careers@bluecoda.com behle@tableau.com rachel.svelan@cloudacademy.com apply@sparklit.com mike@bingdigital.co.uk askstaff@microsoft.com fschmidt@gmail.com luka@appmonsta.com jobs@20spokes.com jobs@fitfor90.com jobs@lesterland.net jobs@mapd.com productjobs@turnto.com jeroen.vandepol@devolksbank.nl devjobs@faithlife.com belden@retailnext.net jobs@nafundi.com jobs@w11k.de jobs@elmingtontech.com pamm@myameego.com jason.knight@intel.com mike@kolide.com productmanagerjob@schedugr.am Matt.Leva@MongoDB.com stealthblockchaincompany@gmail.com stephan.kemper@viasat.com bigjim@amazingribs.com recruiting@open-xchange.de jobs@studysync.com jobs@moduscreate.com careers@vikingcodeschool.com jobs@raisingthefloor.org jobs@rotamap.net work@parabol.co contact@jobs.rubynow.com logo@2x1.png zanferrari@gmail.com job@acme.com jobs@github.com jobs@bromium.com team@cashcowpro.com jobs@xo-energy.com hiring@ampermusic.com jessicasee@gopaktor.com laurag@zoosk.com recruiting@censhare.com jobs@uncommon.co nicole@clearaccessip.com marthe@vonq.com india.spencer@rht.com admin@jobs.rubynow.com accommodations@Conduent.com support@thrivethemes.com jawon.lane@vocovision.com CareersNA2@cognizant.com info@brazilbr.com gkern@teksystems.com hr.testing@virtualdatingassistants.com info@remote.co you@example.com info@rorjobs.com hire@relocateme.eu artem.soloviov@relocateme.eu anna.zrazhevska@relocateme.eu daria.tymokhina@gmail.com daria.tymokhina@relocateme.eu anna.kalniei@relocateme.eu daria@relocateme.eu jobmail@s.seek.com.au smacartney@seek.com.au privacy@seek.com.au Careers.NorthAmerica@sap.com Careers.LatinAmerica@sap.com Careers.APJ@sap.com Careers@sap.com lowell.santos@cybercoders.com keith.ellis@cybercoders.com fed.parrera@rht.com lauren.wolbarsht@rht.com)
    emails.each do |address|
      if Address.first(:email => address).nil?
        add = Address.create(
          :email => address,
          :created_at => Time.now
        )
        puts "address ========= #{address}" if add.saved?
      end
    end
  end
end

# Crawl.create_email

# crawl = Crawl.new
# crawl.scrape
