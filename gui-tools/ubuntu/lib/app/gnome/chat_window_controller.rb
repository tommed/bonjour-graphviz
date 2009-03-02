#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/../ichat_client'

module GNB
	class ChatWindowController
		def initialize(glade)
			@glade = glade
		end

		def connect(name, target, port, address)
			@name, @target, @port, @address = name, target, port, address
			@handleResponses = true
			# clear any old conversations
			puts 'you want to chat with ' + @address
			@conversation = @glade.get_widget('conversation')
			@conversation.buffer.text = '' 
			# setup chat window
			@window = @glade.get_widget('chatWindow')
			@window.show
			@window.signal_connect('delete_event') { stop }
			@conversation.buffer.insert(@conversation.buffer.start_iter, "establishing a connection, please wait...\n")
			@glade.get_widget('chatSendButton').signal_connect('clicked') { self.send_message }
			# start the client
			@clientThread = Thread.start do 
				@client = IChatClient.new("GNBUser", name, target, address, "avail", port)
				@client.on_ready { self.on_ready }
				@client.start do |resp|
					@conversation.buffer.insert(@conversation.buffer.start_iter, "\n#{@name} said: \"#{resp}\"\n") if @handleResponses
				end
			end
		end

		def on_ready
			@chatInput = @glade.get_widget('chatInput')
			@chatInput.visible=true
			@glade.get_widget('chatSendButton').visible=true
			@conversation.buffer.text = ''
		end

		def send_message
			message = @chatInput.text
			@client.send_mesg message
			@conversation.buffer.insert(@conversation.buffer.start_iter, "\nYou said: \"#{message}\"\n")
			@chatInput.text="" # clear old message out
		end

		def stop
			begin
				@handleResponses = false
				@client.stop if @client
			rescue
				@clientThread.exit! if @clientThread
			end
		end
	end
end
