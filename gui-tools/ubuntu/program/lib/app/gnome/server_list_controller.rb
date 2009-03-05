require File.dirname(__FILE__)+'/../service_browser'
require File.dirname(__FILE__)+'/data_builder'
require File.dirname(__FILE__)+'/chat_window_controller'
require File.dirname(__FILE__)+'/server_details_controller'
require 'vte'

module GNB
	class ServerListController
		# configure controller
		def run
			# build page
			@window = Window.new
			@window.title='Server List'
			@window.border_width=20
			@window.window_position=Window::POS_CENTER_ALWAYS
			@window.signal_connect('delete_event') { Gtk.main_quit }
			@window.signal_connect('destroy') { false }
			vbox = VBox.new false, 4
			@window.add vbox
			#
			# Title
			#
			table = Table.new 2, 2, false
			vbox.pack_start table, false, false

			icon = Image.new(Stock::NETWORK, IconSize::DIALOG)
			icon.set_alignment 0, 0
			table.attach icon, 0, 1, 0, 2, SHRINK, SHRINK, 10, 0

			title = Label.new 'Your Network'
			title.set_alignment 0, 0.5
			title.modify_font Pango::FontDescription.new 'Sans Bold 14'
			table.attach title, 1, 2, 0, 1

			subtitle = Label.new
			subtitle.text='Double-click on any server to connect or see more details.'
			subtitle.set_alignment 0, 0.5
			table.attach subtitle, 1, 2, 1, 2

			#
			# Server list
			#
			@tree = TreeView.new
			@tree.signal_connect('row-activated') {|v,p,c| onServerListView_rowDoubleClicked(v,p,c) }
			vbox.pack_start @tree, true, true
			start
			@window.show_all
			Gtk.main
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
				GNB::DataBuilder.build(@tree, @service_browser.cache)
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
				@detailsDialog = GNB::ServerDetailsController.new row_data[2]
				@detailsDialog.show
			end

	end
end
