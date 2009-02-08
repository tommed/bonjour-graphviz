#!/usr/bin/env ruby
#
# This builder takes the data from the service_browser and the
# list/tree-view from the GUI and merges them together.
# It will not show servers which have no services present.
#

module GNB
	class DataBuilder
		def self.build(view, data)
			puts "binding data to server_list glade-view.."
			model_present = view.model
			view.model = Gtk::ListStore.new(String, String, Hash) unless model_present
			view.model.clear
			data.each do |k, v|
				if v.keys.size > 0
					store_entry = view.model.append
					store_entry[0] = k
					store_entry[1] = v.keys.map{|k| DataBuilder.resolve_service_type(k) }.join(', ')
					store_entry[2] = v
				end
			end
			unless model_present
				renderer = Gtk::CellRendererText.new
				view.append_column(Gtk::TreeViewColumn.new("Target", renderer, :text => 0))
				view.append_column(Gtk::TreeViewColumn.new("Services Available", renderer, :text => 1))
			end
		end

		def self.build_text_record_view(view, data)
			puts "binding data to txt_record glade-view.."
			model_present = view.model
			view.model = Gtk::TreeStore.new(String, String) unless model_present
			view.model.clear
			data.each do |k, v|
				type_entry = view.model.append(nil)
				type_entry[0] = k
				if v.details && v.details.text_record
					v.details.text_record.each do |txt_k, txt_v|
						hash_entry = view.model.append(type_entry)
						hash_entry[0] = txt_k
						hash_entry[1] = txt_v
					end
				end
			end
			unless model_present
				renderer = Gtk::CellRendererText.new
				view.append_column(Gtk::TreeViewColumn.new("Property Name", renderer, :text => 0))
				view.append_column(Gtk::TreeViewColumn.new("Property Value", renderer, :text => 1))
			end
		end

		def self.resolve_service_type(type)
			case type
				when "_device-info._tcp.": "Device-Info"
				when "_workstation._tcp.": "Device-Info (wkstn)"
				when "_ssh._tcp.": "SSH"
				when "_sftp-ssh._tcp.": "SFTP"
				when "_ipp._tcp.": "IP-Printer"
				when "_appletv._tcp.": "AppleTV"
				when "_http._tcp.": "HTTP"
				else "Unknown"
			end
		end
	end
end
