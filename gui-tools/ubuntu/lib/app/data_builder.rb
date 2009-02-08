#!/usr/bin/env ruby
#
# This builder takes the data from the service_browser and the
# list/tree-view from the GUI and merges them together.
# It will not show servers which have no services present.
#

module GNB
	class DataBuilder
		def self.build(view, data)
			puts "binding data to glade-view.."
			model_present = view.model
			view.model = Gtk::ListStore.new(String, String) unless model_present
			view.model.clear
			data.each do |k, v|
				if v.keys.size > 0
					store_entry = view.model.append
					store_entry[0] = k
					store_entry[1] = v.keys.join(', ')
				end
			end
			unless model_present
				renderer = Gtk::CellRendererText.new
				view.append_column(Gtk::TreeViewColumn.new("Target", renderer, :text => 0))
				view.append_column(Gtk::TreeViewColumn.new("Services Available", renderer, :text => 1))
			end
		end
	end
end
