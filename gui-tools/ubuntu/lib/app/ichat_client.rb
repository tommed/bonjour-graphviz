#!/usr/bin/env ruby

require 'socket'
require 'cgi'
require 'hpricot'
require 'dnssd'

JABBER_HEADER = <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<stream:stream xmlns="jabber:client" 
xmlns:stream="http://etherx.jabber.org/streams">
EOF

module GNB
	class IChatClient
		def initialize(nickname, recipient_name, recipient, status="avail", their_port=5298)
			@nickname = nickname
			@sender = nickname + "@" + %x{hostname}.strip
			@recip_full = recipient+"@"+recipient_name
			@recipient = recipient
			@recipient_name = recipient_name
			@status = status
			@their_port = their_port
		end

		def start(&block)
			advertise_ichat
			create_connection(block)
		end

		def stop
			@listener_thread.exit! if @listener_thread
			@dns_thread.exit! if @dns_thread
			@dns_service.stop if @dns_service
			@socket.close if @socket
		end

		def send_mesg(mesg)
			@socket.write(<<EOF
<message to="#{@sender}" from="#{@recip_full}" type="chat">
	<body>#{CGI.escapeHTML(mesg)}</body>
</message>
EOF
)
		end

		private
			def advertise_ichat
				@dns_thread = Thread.start do
					@dns_service = DNSSD.register(@sender, "_presence._tcp", "local", 0, {"status"=>"avail", "txtvers"=>"1", "1st"=>@nickname, "last"=>"(via GNB-Network-Browser)"}) {|reply| }
				end
				sleep(5)
			end

			def create_connection(start_block)
				puts "opening socket to #{@recipient}:#{@their_port}"
				@socket = TCPSocket.open(@recipient, @their_port, "", 0)
				puts "writing header.."
				@socket.write(JABBER_HEADER)
				puts "waiting for header swap.."
				@socket.recv(1000)
				puts "adding listener.."
				@listener_thread = Thread.start(@socket, start_block) do |socket,start_block|
					while (true)
						handle_response(socket.recv(2000), &start_block)
					end
				end
			end

			def handle_response(mesg, &block)
				# TODO: handle xml here with hpricot
				puts "response found"
				STDOUT.flush
				block.call(mesg)
			end
	end
end

# tests ichat functionality from this file
if __FILE__ == $0
	client = GNB::IChatClient.new("tom", "tom", "192.168.1.76")
	client.start {|response| puts "RESPONSE:"+response }
	client.send_mesg("hello world from gnb")
	client.stop
end
