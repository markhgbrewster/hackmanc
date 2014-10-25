desc "This task if for Heroku Scheduler add-on"
task :process_texts => :environment do
  loop do
    puts "processing text queue"
    TextQueue.where("send_after < ?", Time.now).each do |text|
      puts "sending text"

      response = HTTParty.post("https://api.clockworksms.com/http/send.aspx", {query: {
         :key => "3cf1f7012e1ad38c8b0d36a32f18fc40673f7199", 
         :to => text.dest, 
         :content => text.message}})
      if response.code
        text.destroy
        puts "text sent off"
      else
        puts "text failed to send"
      end

    end
    puts "done processing text queue"
  end
end
