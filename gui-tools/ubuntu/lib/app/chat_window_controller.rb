#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/ichat_client'

module GNB
	class ChatWindowController
		def initialize(glade)
			@glade = glade
		end

		def connect(name, target, port, address)
			@name, @target, @port, @address = name, target, port, address
			puts 'you want to chat with ' + @address
			@conversation = @glade.get_widget('conversation')
			@conversation.buffer.text = '' # clear any old conversations
			@window = @glade.get_widget('chatWindow')
			@window.show
			@client = IChatClient.new("GNBUser", name, target, address, "avail", port)
			@client.start do |resp|
				@conversation.buffer.insert(0, "\n<i>#{@name} said:</i> \"#{resp}\"\n")
			end
			@client.send_mesg("Hello World!")
			sleep(20)
			@client.stop
			@window.hide
		end
	end
end
