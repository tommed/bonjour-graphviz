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
	ib_outlet :browserView
	
	def awakeFromNib
		@cache = []
		@browserView.setAnimates(true)
		@browserView.setDataSource(self)
		@browserView.setDelegate(self)
	end
	
	def numberOfItemsInImageBrowser(browser)
		puts "numberOfItemsInImageBrowser(#{@cache.size})"
		return @cache.size
	end

	def imageBrowser_itemAtIndex(browser, index)
		puts "->getItem(#{index})"
		return @cache[index || 0]
	end
	
	def setData(servers)
		puts "setData(#{servers.size})"
		@cache.clear
		if servers
			servers.values.each do |server|
				newItem = ServerListViewBrowserItem.new(server.name, server.name, server.target)
				@cache.push(newItem)
			end
			@browserView.reloadData
		end
	end
	
end
