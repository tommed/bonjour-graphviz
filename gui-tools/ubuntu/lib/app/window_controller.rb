#!/usr/bin/env ruby
#
#
require 'lib/app/service_browser'
require 'lib/app/data_builder'

module GNB
	class WindowController
		# ctor
		def initialize(glade)
			@glade = glade
			@mainWindow = glade.get_widget('mainWindow')
			@mainWindow.signal_connect('delete_event') { stop }
			start
		end

		private

			# start the service browser
			def start
				@service_browser = GNB::ServiceBrowser.new
				Thread.start do
					while (true)
						begin
							if @service_browser.requires_redraw
								@service_browser.requires_redraw = false
								redraw
							end
						rescue => ex
							puts "ERR:SERVICEWATCHERLOOP=>#{ex.inspect}"
						end
						sleep 2
					end
				end
				@service_browser.start
			end

			# mainWindow is closing
			def stop
				puts "exiting app"
				@service_browser.stop
				Gtk.main_quit
			end

			# glade needs updating as data has changed
			def redraw
				puts "NEEDS A REDRAW!"
				GNB::DataBuilder.build(@glade.get_widget('serverList'), @service_browser.cache)
			end
	end
end
