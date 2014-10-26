task :clockwork2 => :environment do
 sleep rand(300)
 @time = (Time.now - (600)).strftime("%H:%M")
 User.all.each do |user|
   responce = HTTParty.post("https://api.clockworksms.com/http/send.aspx", {query: {
       :key => "3cf1f7012e1ad38c8b0d36a32f18fc40673f7199", 
       :to => user.phone.to_s,
       :from => 'Rasputin', 
       :content => "The time ten minutes ago was #{@time}"}})
    if responce.code
      puts responce.body
    else
      puts"shit happens"
    end
  end
end