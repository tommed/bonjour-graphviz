#
#  ServerListViewController.rb
#  ZeroConfNetworkBrowser
#
#  Created by Tom Medhurst on 02/02/2009.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'serverlistviewbrowseritem'

class ServerListViewController < OSX::NSViewController
	ib_outlet :browserView, :serverDetailsController
	
	# on-load
	def awakeFromNib
		@cache = []
		@data = []
		@browserView.setAnimates(true)
		@browserView.setDataSource(self)
		@browserView.setDelegate(self)
	end
	
	# delegate[image-browser] get item count
	def numberOfItemsInImageBrowser(browser)
		puts "numberOfItemsInImageBrowser(#{@cache.size})"
		return @cache.size
	end

	# delegate[image-browser] get item at index
	def imageBrowser_itemAtIndex(browser, index)
		puts "->getItem(#{index})"
		return @cache[index || 0]
	end
	
	# called when data has changed to redraw the cache which 
	# controls the server browser
	def setData(servers)
		puts "setData(#{servers.size})"
		@cache.clear; @data.clear
		if servers
			servers.values.each do |server|
				newItem = ServerListViewBrowserItem.new(server.name, server.name.gsub('\032', ' '), server.target)
				@cache.push newItem
				@data.push server
			end
			@browserView.reloadData
		end
	end
	
	# launch server details window
	def imageBrowser_cellWasDoubleClickedAtIndex(browser, index)
		puts "->dblClicked"
		@serverDetailsController.launch_server_details(@data[index])
	end
	
end
