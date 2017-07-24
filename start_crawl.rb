# #!/usr/bin/ruby
# require 'fileutils'
# require 'byebug'
# if File.exists?(File.expand_path('tmp/crawl.pid'))
#   @pid = File.read(File.expand_path('tmp/crawl.pid')).chomp!.to_i
#   begin
#     raise "ouch" if Process.kill('QUIT', @pid) != 1
#   rescue
#     puts "Removing abandoned pid file"
#     FileUtils.rm(File.expand_path('tmp/crawl.pid'))
#     puts "Starting the crawl!"
#     Kernel.exec(File.expand_path('crawl.rb'))
#   else
#     puts "Bot up and running!"
#   end
# else
#   puts "Starting the bot!"
#   Kernel.exec(File.expand_path('crawl.rb'))
# end
