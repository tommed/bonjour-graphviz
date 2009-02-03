#
#  ServerListViewBrowserItem.rb
#  ZeroConfNetworkBrowser
#
#  Created by Tom Medhurst on 02/02/2009.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class ServerListViewBrowserItem

	def initialize(urn, title, subtitle)
		@image_uid = urn
		@title = title
		@subtitle = subtitle
	end
	
	def	imageUID
		return @image_uid
	end
	
	def	imageTitle
		return @title
	end
	
	def imageSubtitle
		return @subtitle
	end
	
	def imageRepresentationType
		return :IKImageBrowserNSImageRepresentationType
	end
	
	def imageRepresentation
		puts "->imageRepresentation"
		return @image unless @image.nil?
		puts "->retrieving image from bundle.."
		imagePath = OSX::NSBundle.mainBundle.pathForResource_ofType("computer", "png")
		return @image = OSX::NSImage.new.initWithContentsOfFile(imagePath)
	end

end
