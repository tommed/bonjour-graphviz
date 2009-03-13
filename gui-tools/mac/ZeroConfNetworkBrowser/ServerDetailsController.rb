#
#  Application.rb
#  ZeroConfNetworkBrowser
#
#  Created by Tom Medhurst on 04/02/2009.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class ServerDetailsController < OSX::NSObject
	ib_outlet :parentView, :serverDetailsView

	# launch the server details window
	def launch_server_details(server_info)
		puts "->launchServerDetails"
		@server_info = server_info
		NSApp.beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(@serverDetailsView, @browserView, nil, nil, nil)
		#NSApp.runModalSession(NSApp.beginModalSessionForWindow(@parentView))
		NSApp.runModalForWindow(@serverDetailsView)
		NSApp.endSheet(@serverDetailsView)
		@serverDetailsView.orderOut(self)
	end
	
	def close_sheet(sender)
		puts "->closeSheet"
		NSApp.endSheet(@serverDetailsView)
		NSApp.stopModalWithCode(10)
		@serverDetailsView.orderOut(self)
	end
	ib_action :close_sheet

end
