require 'rubygems'
require 'gtk2'
include Gtk

require File.dirname(__FILE__)+'/data_builder'
require File.dirname(__FILE__)+'/chat_window_controller'

module GNB
	class ServerDetailsController
		def initialize(data)

			# get info from data
			data.each do |type,info|
				@data_title = info.meta.name
				@data_types ||= []
				@data_types << info.meta.type
				addr = "#{info.meta.name}.#{info.meta.domain}"
				@can_cnnt = true and @data_cmd_http = "firefox http://#{info.details.target}" 	if info.meta.type=="_http._tcp."
				@can_cnnt = true and @data_cmd_ssh = "gnome-terminal -e \"ssh #{addr}\"" 			if info.meta.type=="_ssh._tcp."
				@can_cnnt = true and @data_cmd_sftp = "nautilus sftp://#{addr}" 								if info.meta.type=="_sftp-ssh._tcp."
				@can_cnnt = true and @data_cmd_vnc = "vinagre \"#{addr}\"" 										if info.meta.type=="_rfb._tcp."
				@can_cnnt = true and @data_cmd_ichat = info 																		if info.meta.type=="_presence._tcp."
			end

			# build page
			@window = Window.new
			@window.title=@data_title
			@window.border_width=20
			@window.set_default_size 500, -1
			@window.window_position=Window::POS_CENTER
			vbox = VBox.new false, 4
			@window.add vbox
			#
			# icon, title, and subtitle
			#
			table = Table.new 2, 2
			vbox.pack_start table, false, false

			icon = Image.new(Stock::NETWORK, IconSize::DIALOG)
			icon.set_alignment 0, 0
			table.attach icon, 0, 1, 0, 2, SHRINK, SHRINK, 10, 0

			title = Label.new @data_title #Entry.new 
			#title.text=@data_title
			title.set_alignment 0, 0.5
			title.modify_font Pango::FontDescription.new 'Sans Bold 14'
			table.attach title, 1, 2, 0, 1

			subtitle = Label.new
			subtitle.text=@data_types.join ', '
			subtitle.set_alignment 0, 0.5
			table.attach subtitle, 1, 2, 1, 2
			#
			# details
			#
			expander = Expander.new 'Show Server Properties'
			tree = TreeView.new
			GNB::DataBuilder.build_text_record_view(tree, data)
			expander.add(tree)
			#expander.signal_connect('notify::expanded') { }
			vbox.pack_start expander, true, true
			#	
			# connect menu 	
			#
			connectMenu = Menu.new
			if @data_cmd_http
				menu_item = ImageMenuItem.new 'Connect to Web Site (HTTP)'
				menu_item.image=Image.new(Stock::CONNECT, IconSize::MENU)
				menu_item.signal_connect('activate') { system(@data_cmd_http) }
				connectMenu.append(menu_item)
			end
			if @data_cmd_ssh
				menu_item = ImageMenuItem.new 'Connect to Terminal (SSH)'
				menu_item.image=Image.new(Stock::NETWORK, IconSize::MENU)
				menu_item.signal_connect('activate') { system(@data_cmd_ssh) }
				connectMenu.append(menu_item)
			end
			if @data_cmd_vnc
				menu_item = ImageMenuItem.new 'Connect to Desktop (VNC)'
				menu_item.image=Image.new(Stock::FULLSCREEN, IconSize::MENU)
				menu_item.signal_connect('activate') { system(@data_cmd_vnc) }
				connectMenu.append(menu_item)
			end
			if @data_cmd_sftp
				menu_item = ImageMenuItem.new 'Connect to File System (SFTP)'
				menu_item.image=Image.new(Stock::OPEN, IconSize::MENU)
				menu_item.signal_connect('activate') { system(@data_cmd_sftp) }
				connectMenu.append(menu_item)
			end
			if @data_cmd_ichat
				menu_item = ImageMenuItem.new 'Connect to iChat'
				menu_item.image=Image.new(Stock::CONNECT, IconSize::MENU)
				menu_item.signal_connect('activate') do
					target = @data_cmd_ichat.details.target
					port = @data_cmd_ichat.details.port
					name = @data_cmd_ichat.details.text_record['1st']
					address = @data_cmd_ichat.meta.name
					ChatWindowController.new.connect(name, target, port, address)
				end
				connectMenu.append(menu_item)
			end
			connectMenu.show_all
			#
			# buttons
			#
			hbuttons = HButtonBox.new
			hbuttons.layout_style=ButtonBox::END
			vbox.pack_end hbuttons, false, false
			vbox.pack_end HSeparator.new, false, false

			connect_button = Button.new 'Connect'
			connect_button.image=Image.new(Stock::NETWORK, IconSize::BUTTON)
			connect_button.signal_connect('button_press_event') do |w,e|
				connectMenu.popup(nil, nil, e.button, e.time) #if e.button == 1
			end
			hbuttons.add(connect_button) if @can_cnnt

			close_button = Button.new Stock::CLOSE
			close_button.signal_connect('clicked') { @window.destroy }
			hbuttons.add(close_button)
		end

		def show
			@window.show_all
		end

		private
			def build_tree
				tree = TreeView.new
				tree.set_size_request -1, 300
				return tree
			end

	end # class
end # mod
