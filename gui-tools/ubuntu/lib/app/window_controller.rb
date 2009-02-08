#!/usr/bin/env ruby
#
#
require File.dirname(__FILE__)+'/service_browser'
require File.dirname(__FILE__)+'/data_builder'
require 'vte'

module GNB
	class WindowController
		# configure controller
		def config(glade)
			@glade = glade
			# configure main window
			@mainWindow = glade.get_widget('mainWindow')
			@mainWindow.signal_connect('delete_event') { stop }
			# configure server list
			@serverListView = @glade.get_widget('serverList')
			@serverListView.signal_connect('row-activated') {|v,p,c| onServerListView_rowDoubleClicked(v,p,c) }
			start
			# configure details window
			@detailsWindow = @glade.get_widget('detailsWindow')
			@glade.get_widget('detailsWindow_closeButton').signal_connect('pressed') { @detailsWindow.hide }
			@glade.get_widget('sshConnectButton').signal_connect('pressed') { onSSHConnect_clicked }
			@glade.get_widget('sftpConnectButton').signal_connect('pressed') { onSFTPConnect_clicked }
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
				GNB::DataBuilder.build(@serverListView, @service_browser.cache)
			end

			def onServerListView_rowDoubleClicked(view, path, column)
				if iter = view.model.get_iter(path)
					show_server_details(iter)
				end
			end

			def onServerDetails_clicked
				if iter = @serverListView.selection.selected
					show_server_details(iter)
				end
			end

			# user is requesting details for server
			def show_server_details(row_data)
				types = []
				@glade.get_widget('sshConnectButton').hide
				@glade.get_widget('sftpConnectButton').hide
				@glade.get_widget('details_name').text = row_data[0]
				@glade.get_widget('details_ports').text = ""
				@glade.get_widget('details_target').text = ""
				GNB::DataBuilder.build_text_record_view(@glade.get_widget('detailsTxtRecords'), row_data[2])
				row_data[2].each do |type,zeroconfData| 
					@glade.get_widget('details_domain').text = zeroconfData.meta.domain
					types << GNB::DataBuilder.resolve_service_type(zeroconfData.meta.type)
					if zeroconfData.details
						@glade.get_widget('details_ports').text += zeroconfData.details.port.to_s+" "
						@glade.get_widget('details_target').text = zeroconfData.details.target
					end
					if zeroconfData.meta.type=="_device-info._tcp."
						@glade.get_widget('details_name').text = zeroconfData.meta.name.match(/([^\(]*)/)[1].capitalize
					elsif zeroconfData.meta.type=="_ssh._tcp."
						@glade.get_widget('sshConnectButton').show 
						@sshData = zeroconfData
					elsif zeroconfData.meta.type=="_sftp-ssh._tcp."
						@glade.get_widget('sftpConnectButton').show	
						@sftpData = zeroconfData
					end
				end
				@glade.get_widget('details_types').text = types.join(', ')
				@detailsWindow.show
			end

			def onSFTPConnect_clicked
				if @sftpData					
					target = @sftpData.meta.name+"."+@sftpData.meta.domain
					system("nautilus sftp://#{target}")
				end
			end

			def onSSHConnect_clicked
				if @sshData
					target = @sshData.meta.name+"."+@sshData.meta.domain
					system("gnome-terminal -e \"ssh #{target}\"")
				end
			end
	end
end
