# Purpose
This web spider continously crawl the web sites stored in the postgresql database, harvests any email addresses that it can find on the target web site and stores the harvested addresses in the database.

# Installation

Delete the Gemfile.lock file.

Then bundle the gems with: `bundle install`

# Usage

To Add web site urls in the database:

    ruby site.rb URL1 URL2 URL3

URL1, URL2, URL3 are list of urls, you can use any number of urls simultaneously to store in the database. 

To export the addresses from the database, use the "export" Rake task:

    rake export

You should see output like this:

    [~/projects/ruby_spider] rake export
    31 addresses exported to addresses.csv

Each row in the exported data contains the email address, the date/time that it was collected, the host
of the site where it was collected, and the URL for the specific page where it was found.


To send emails to users present in Addresses table, us the "send_email" Rake task:

    rake send_email

Sendgrid is being used to send emails, you can set appropriate enviornment variables to send an email. Emails body is being picked from the `mailer_template.txt` file. You can customize its content to change email body.

To crawl the web sites already present in Sites table, and check if new eamils are added use the "crawl_existing_pages" Rake task:

    rake crawl_existing_pages

You can schedule these rake tasks in cron to continously crawl web sites present in the Sites table and send emails to the users.