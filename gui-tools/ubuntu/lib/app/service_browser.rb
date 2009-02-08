#!/usr/bin/env ruby
#
#
require 'dnssd'

module GNB

	# services which the ServiceBrowser will search for
	ZEROCONF_SERVICES_TO_LOOK_FOR = ["_device-info._tcp", "_ssh._tcp", "_appletv._tcp", "_http._tcp", "_ipp._tcp", 
																	 "_sftp-ssh._tcp"]

	# 
	# This class is used to link this app to Avahi (bonjour for Linux enabled by default in Ubuntu 8.10)
	# is boots many instances of the avahi-browse app, so the results can be stacked.
	# 
	class ServiceBrowser
		attr_reader :cache, :threads, :browsers
		attr_accessor :requires_redraw
		
		# ctor
		def initialize()
			@cache = Hash.new
			@threads = Array.new
			@browsers = Array.new
			@requires_redraw = false
		end

		# start all service browsers for all configured types
		def start
			ZEROCONF_SERVICES_TO_LOOK_FOR.each { |st| start_browser(st) }
		end

		# stop everything so we can exit this app
		def stop
			puts "shutting down services"
			@browsers.each { |b| b.stop }
			@threads.each { |t| t.exit! }
		end

		private
			# starts a service browser of a particular type
			def start_browser(service_type)
				@threads << Thread.start(service_type, self) do |service_type, _self|
					puts "CTL=> Starting service browser for #{service_type}"
					@browsers << DNSSD.browse(service_type) {|reply| process_reply(reply) } 
				end
			end

			# process reply and register with cache
			def process_reply(reply)
				if reply.flags.to_i & DNSSD::Flags::Add != 0
					register_find(reply)
				else
					register_removal(reply)
				end
				@requires_redraw = true
			end

			# this reply contains a service-added event
			def register_find(reply)
				puts "FOUND=> #{reply.name} (#{reply.type})"
				@cache[reply.name] ||= Hash.new
				@cache[reply.name][reply.type] = reply
				DNSSD.resolve(reply.name, reply.type, reply.domain) do |resolved|
					puts "RESOLVED=>#{reply.name} (#{reply.type})"
					@cache[reply.name][reply.type] = resolved
				end
			end

			# this reply contains a service-removed event
			def register_removal(reply)
				puts "LOST=> #{reply.name} (#{reply.type})"
				@cache[reply.name].delete(reply.type) if @cache[reply.name].key?(reply.type)
			end

	end

end
