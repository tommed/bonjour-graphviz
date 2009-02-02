#
#  Discoverer.rb
#  RubyCocoa
#
#  Created by Tom Medhurst on 31/01/2009.
#  Copyright (c) 2009 Tom Medhurst. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'
require 'graphviz'
require 'dnssd'
require 'yaml'
require 'singleton'

class Discoverer
	attr_accessor :requiresRedraw, :serviceType, :servers, :delegate
	include Singleton
	
	# stop browser
	def stop_browser
		puts "->stop_browser"
		@workerThread.exit if @workerThread
		@renderThread.exit if @renderThread
		@dnssd_obj.stop if @dnssd_obj
	end
	
	# start browser
	def start_browser(delegate, serviceType="_device-info._tcp")
		puts "->start_browser"
		self.stop_browser
		@delegate = delegate
		@servers = Hash.new
		@serviceType = serviceType
		# reset, then check for redraw events
		@requiresRedraw = true
		watch_for_redraw
		# start worker thread 
		@workerThread = Thread.start do 
			DNSSD.browse(@serviceType) do |reply|
				begin
					puts "->DNSSD.browse[reply]"
					if reply.flags.to_i & DNSSD::Flags::Add != 0
						DNSSD.resolve(reply.name, reply.type, reply.domain) do |d| 
							@servers[reply.name] = d
						end
					else
						@servers.delete(reply.name) if @servers.key?(reply.name)
					end
					@requiresRedraw = true
				rescue => e
					puts "ERROR: #{e}"
					@delegate.showError("ERR01BRWS: #{e.inspect}")
				end
			end
		end
	end
	
	private
	
		def watch_for_redraw
			@renderThread = Thread.start do
				while (true) do
					if @requiresRedraw
						@requiresRedraw = false
						puts "redraw required from delegate.."
						@delegate.changeOccured(@servers)
					end
					sleep 2
				end
			end
		end
end