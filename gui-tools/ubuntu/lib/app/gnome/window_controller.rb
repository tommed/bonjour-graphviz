#!/usr/bin/env ruby
#
#
require File.dirname(__FILE__)+'/../service_browser'
require File.dirname(__FILE__)+'/data_builder'
require File.dirname(__FILE__)+'/chat_window_controller'
require File.dirname(__FILE__)+'/config_controller'
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
			@glade.get_widget('detailsWindow_closeButton').signal_connect('pressed') { hide_details_window }
			@glade.get_widget('sshConnectButton').signal_connect('pressed') { onSSHConnect_clicked }
			@glade.get_widget('sftpConnectButton').signal_connect('pressed') { onSFTPConnect_clicked }
		end

		private

			def hide_details_window
				@detailsWindow.hide
				if @nameHasChanged
					@service_browser.stop
					start
				end
			end

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
						sleep 1
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
				@nameHasChanged = false
				@glade.get_widget('sshConnectButton').hide
				@glade.get_widget('sftpConnectButton').hide
				@glade.get_widget('vncConnectButton').hide
				@glade.get_widget('httpConnectButton').hide
				@glade.get_widget('ichatConnectButton').hide
				@glade.get_widget('details_name').text = row_data[0]
				@glade.get_widget('details_ports').text = ""
				@glade.get_widget('details_target').text = ""
				GNB::DataBuilder.build_text_record_view(@glade.get_widget('detailsTxtRecords'), row_data[2])
				row_data[2].each do |type,zeroconfData| 
					@lastMeta = zeroconfData
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
					elsif zeroconfData.meta.type=="_http._tcp."
						@glade.get_widget('httpConnectButton').show
						@httpData = zeroconfData
					elsif zeroconfData.meta.type=="_rfb._tcp."
						@glade.get_widget('vncConnectButton').show
						@vncData = zeroconfData
					elsif zeroconfData.meta.type=="_presence._tcp."
						@glade.get_widget('ichatConnectButton').show
						@ichatData = zeroconfData
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

			def	onICHATConnect_clicked
				if @ichatData
					target = @ichatData.details.target
					port = @ichatData.details.port
					name = @ichatData.details.text_record['1st']
					address = @ichatData.meta.name
					ChatWindowController.new(@glade).connect(name, target, port, address)
					@detailsWindow.hide
				end
			end

			def onHTTPConnect_clicked
				if @httpData					
					target = @glade.get_widget('details_target').text
					system("firefox http://#{target}")
				end
			end

			def	onVNCConnect_clicked
				if @vncData					
					target = @vncData.meta.name+"."+@vncData.meta.domain
					system("vinagre \"#{target}\"")
				end
			end

			def onSSHConnect_clicked
				if @sshData
					target = @sshData.meta.name+"."+@sshData.meta.domain
					system("gnome-terminal -e \"ssh #{target}\"")
				end
			end

			def onServerDetails_nameChanged
				if @lastMeta
					hash = ConfigController.instance.get_hash(@lastMeta.meta)
					newValue = @glade.get_widget('details_name').text
					ConfigController.instance.set_for(hash, newValue)
					@nameHasChanged = newValue != @lastMeta.meta.name
				end
			end
	end
end