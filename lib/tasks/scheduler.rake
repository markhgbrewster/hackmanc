desc "This task if for Heroku Scheduler add-on"
task :process_texts => :environment do
  puts "processing text queue"
  puts "done processing text queue"
end
