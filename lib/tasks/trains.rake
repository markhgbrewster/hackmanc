# require 'clockwork'
require 'stomp'
require 'json'

task :trains => :environment do
  client_headers = { "accept-version" => "1.1", "heart-beat" => "5000,10000", 
                     "client-id" => Socket.gethostname,
                     "host" => "datafeeds.networkrail.co.uk" }
  client_hash = { :hosts => [ { :login => "giedrius.kudelis@gmail.com",
                                :passcode => "q!N0jFtb=zhz", 
                                :host => "datafeeds.networkrail.co.uk", 
                                :port => 61618 } ], 
                  :connect_headers => client_headers,
                  :start_timeout => 0 }

  client = Stomp::Client.new(client_hash)

  # Check we have connected successfully
  raise "Connection failed" unless client.open?
  raise "Connect error: #{client.connection_frame().body}" if client.connection_frame().command == Stomp::CMD_ERROR
  raise "Unexpected protocol level #{client.protocol}" unless client.protocol == Stomp::SPL_11

  puts "Connected to #{client.connection_frame().headers['server']} server with STOMP #{client.connection_frame().headers['version']}"

  # Subscribe to the RTPPM topic and process messages
  client.subscribe("/topic/TRAIN_MVT_ALL_TOC", { 'id' => client.uuid(), 'ack' => 'client', 'activemq.subscriptionName' => Socket.gethostname + '-TRAIN_MVT' }) do |msg|
    msg_array = JSON.parse msg.body
    msg_array.each do |msg_single|
      if msg_single["header"]["msg_type"] != "0003" or
          msg_single["body"]["event_type"] != "DEPARTURE" or
          msg_single["body"]["loc_stanox"] != "54311" then
        next
      end

      response = HTTParty.post("https://api.clockworksms.com/http/send.aspx", {query: {
         :key => "3cf1f7012e1ad38c8b0d36a32f18fc40673f7199", 
         :to => '447715957404', 
         :content => "Some train left Kings Cross some time ago..."}})
      if response.code
        puts response.body
      else
        puts"shit happens"
      end

      client.acknowledge(msg, msg.headers)
    end
  end

  client.join
  # We will probably never end up here
  client.close
  puts "Client close complete"

  #responce = HTTParty.post("https://api.clockworksms.com/http/send.aspx", {query: {
  #   :key => "3cf1f7012e1ad38c8b0d36a32f18fc40673f7199", 
  #   :to => '447739141474', 
  #   :content => "The Time is #{Time.now}"}})
  #if responce.code
  #  puts responce.body
  #else
  #  puts"shit happens"
  #end
end