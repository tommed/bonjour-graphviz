#!/usr/bin/env ruby

require 'socket'
require 'cgi'
require 'hpricot'
require 'dnssd'

JABBER_SENDER = "tom@asfur.local."
JABBER_RECIPIENT = "tom@MusicDesk.local"
JABBER_REMOTE_ADDR = "MusicDesk.local."
JABBER_REMOTE_PORT = 5298
JABBER_LOCAL_PORT = 0

JABBER_HEADER = <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<stream:stream xmlns="jabber:client"
xmlns:stream="http://etherx.jabber.org/streams">
EOF

def format_jabber_mesg(mesg)
	result = <<EOF
	<message to="#{JABBER_RECIPIENT}" from="#{JABBER_SENDER}" type="chat">
		<body>#{CGI.escapeHTML(mesg)}</body>
	</message>
EOF
end

def handle_response(response)
	begin
		doc = Hpricot(response)
		body = (doc/:message/:body).first
		mesg = body ||= "(empty response)"
		puts "\n\n=====RESPONSE=====\n" + CGI.unescapeHTML(mesg) + "\n=====EO RESPONSE=====\n\n"
	rescue => ex
		puts "error-handle_response:#{ex.inspect}"
	end
end

def format_jabber_status(status)
	result = <<EOF
	<presence to="#{JABBER_RECIPIENT}" from="#{JABBER_SENDER}">
		<show>#{status}</show>
		<priority>5</priority>
	</presence>
EOF
end


begin

	#
	# advertise ichat
	#	
	Thread.start do
		DNSSD.register("iChat", "_presence._tcp", "local", 0, {"status"=>"avail", "txtvers"=>"1", "1st"=>"test", "last"=>"(via GNB-Network-Browser)"}) {|reply| }
	end
	sleep(5)

	#
	# create a connection
	#
	socket = TCPSocket.open(JABBER_REMOTE_ADDR, JABBER_REMOTE_PORT, "", JABBER_LOCAL_PORT)
	puts "socket retrieved"

	#
	# swap header data
	#
	socket.write(JABBER_HEADER)
	puts "header sent"
	
	puts "waiting for header confirmation.."
	puts socket.recv(200)
	puts "header confirmation retrieved."
	
	#
	# handle responses on a separate thread, so it doesn't stop us nattering!!
	#
	recv_thread = Thread.start(socket) {|socket| while(true); handle_response(socket.recv(2000)) end }

	#
	# write loop
	#
	while (true)
		STDOUT.print "Type your message: "
		STDOUT.flush
		mesg = STDIN.readline.strip
		break if mesg == "exit" # exit is requested
		if mesg.index("status:") == 0
			puts "=>setting status"
			socket.write format_jabber_status(mesg[0..7]) 
		else
			puts "=>writing message"
			socket.write format_jabber_mesg(mesg)
		end
	end
	
	#
	# closing jabber-xml
	#
	socket.write("</stream:stream>")

rescue => ex
	puts "Error: #{ex.inspect}"
end

#
# shutdown service
#
recv_thread.exit! if recv_thread # stop listening
socket.close if socket # close socket
