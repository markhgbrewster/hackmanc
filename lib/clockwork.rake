require 'clockwork'
api = Clockwork::API.new( 'API_KEY_GOES_HERE' )
message = api.messages.build( :to => '441234123456', :content => "The Time is #{Time.now}" )
response = message.deliver

if response.success
    puts response.message_id
else
    puts response.error_code
    puts response.error_description
end