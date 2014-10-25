# require 'clockwork'

task :clockwork => :environment do
 responce = HTTParty.post("https://api.clockworksms.com/http/send.aspx", {query: {
     :key => "3cf1f7012e1ad38c8b0d36a32f18fc40673f7199", 
     :to => '447739141474',
     :from => '447739141474', 
     :content => "The Time is #{Time.now}"}})
  if responce.code
    puts responce.body
  else
    puts"shit happens"
  end
  # api = Clockwork::API.new( '3cf1f7012e1ad38c8b0d36a32f18fc40673f7199' )
  # message = api.messages.build( :to => '447739141474', :content => "The Time is #{Time.now}" )
  # response = message.deliver
  #
  # if response.success
  #     puts response.message_id
  # else
  #     puts response.error_code
  #     puts response.error_description
  # end
end