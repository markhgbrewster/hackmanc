# require 'clockwork'
require 'stomp'
require 'json'
require 'open-uri'

task :trains => :environment do
  # load the static info re names of train stops
  corpus_db = JSON.parse(open("https://glacial-reef-2223.herokuapp.com/corpus.json") { |io| io.read })['TIPLOCDATA']

  client_headers = { "accept-version" => "1.1", "heart-beat" => "5000,10000", 
                     "client-id" => Socket.gethostname,
                     "host" => "datafeeds.networkrail.co.uk" }
  client_hash = { :hosts => [ { :login => "giedrius.kudelis@gmail.com",
                                :passcode => "^FDMe4BUk`t#", 
                                :host => "datafeeds.networkrail.co.uk", 
                                :port => 61618 } ], 
                  :connect_headers => client_headers,
                  :start_timeout => 0 }
  lasttime = Time.now

  loop do 
    begin
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
              msg_single["body"]["event_type"] != "DEPARTURE" then
            next
          end

          puts "queueing a text"

          nowtime = Time.now
          tdiff = nowtime - lasttime
          puts "time difference is " + tdiff.to_s
          if tdiff < 5 then
            next
          end

          # this only happens if we decide to send the message
          lasttime = nowtime

          dest_name = corpus_db.select{|dest| dest['STANOX'] == msg_single['body']['loc_stanox']}[0]['NLCDESC']
          TextQueue.create(send_after: (Time.now + 60), dest: '447715957404',
                           message: "Some train left " + dest_name + " a minute ago...")

          client.acknowledge(msg, msg.headers)
        end
      end

      client.join
      # We will probably never end up here
      client.close
      puts "Client close complete"
    rescue Stomp::Error::ProtocolException
      puts "protocol crashed"
      begin
        client.close
      rescue Stomp::Error::ProtocolException
        puts "closing crashed"
      end
    end
  end

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
