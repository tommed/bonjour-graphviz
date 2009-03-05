#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/../ichat_client'

module GNB
	class ChatWindowController

		def initialize
			# build the ui
			@window = Window.new
			@window.border_width=4
			@window.window_position=Window::POS_CENTER
			@window.set_size_request 500, 400
			@window.signal_connect('delete_event') { stop }
			vbox = VBox.new false, 4
			@window.add vbox
			# conversation window
			@conversation = TextView.new 
			@conversation.buffer.text='Connecting please wait...'
			@conversation.editable=false
			vbox.pack_start @conversation, true, true
			@hbox = HBox.new
			vbox.pack_start @hbox, false, false
			# chat input
			@chatInput = Entry.new
			@hbox.pack_start @chatInput, true, true
			# chat button
			@chatSendButton = Button.new '_Send', true
			@chatSendButton.image=Image.new(Stock::OK, IconSize::BUTTON)
			@chatSendButton.signal_connect('clicked') { send_message }
			@chatSendButton.sensitive=false
			@hbox.pack_start @chatSendButton, false, false
			@window.show_all	
		end

		def connect(name, target, port, address)
			@name, @target, @port, @address = name, target, port, address
			@handleResponses = true
			@window.title="iChat with #{@name}"
			# clear any old conversations
			puts 'you want to chat with ' + @address
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
			@chatSendButton.sensitive=true
			@conversation.buffer.text = "Connected! You may now send a message to #{@name}!"
		end

		def send_message
			message = @chatInput.text
			@client.send_mesg message
			@conversation.buffer.insert(@conversation.buffer.start_iter, "\nYou said: \"#{message}\"\n\n")
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
