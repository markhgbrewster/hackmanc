desc "This task if for Heroku Scheduler add-on"
task :process_texts => :environment do
  puts "processing text queue"
  TextQueue.where("send_after < ?", Time.now).each do |text|
    puts text.dest
    puts text.message
    puts
  end
  puts "done processing text queue"
end
