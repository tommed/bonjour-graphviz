#
#  NetworkBrowserWindowController.rb
#  ZeroConfNetworkBrowser
#
#  Created by Tom Medhurst on 02/02/2009.
#  Copyright (c) 2009 Tom Medhurst. All rights reserved.
#

require 'osx/cocoa'
require 'discoverer'
require 'graphvizproxy'

class NetworkBrowserWindowController < OSX::NSWindowController
	ib_outlet :service_type, :imageField, :serviceBrowser, :throbber
	kvc_accessor :discoverer
	
	# on_load
	def initialize
		puts "->initialize"
		@proxy = GraphVizProxy.new
	end
	
	def windowDidLoad
		puts "->windowDidLoad"
	end
	
	# pressed when service-type is changed
	def look_for
		puts "->look_for"
		@throbber.startAnimation(self)
		@serviceBrowser.displayColumn(0)
		@serviceBrowser.reloadColumn(0)
		@serviceBrowser.setTitle_ofColumn("Service Type (0)", 0)
		Discoverer.instance.start_browser(self, @service_type.stringValue)
	end
	ib_action :look_for
	
	# show an error on the ui
	def showError(mesg)
		err_dialog = OSX::NSAlert.new
		err_dialog.addButtonWithTitle "OK"
		err_dialog.setMessageText "Error generating graph"
		err_dialog.setInformativeText mesg.to_s
		err_dialog.setAlertStyle OSX::NSWarningAlertStyle
		err_dialog.beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo(@imageField.window, self, nil, nil)
	end
	
	# when a change to the services has been made
	def changeOccured(services)
		puts "->changedOccurred(#{services.class})"
		@services = services
		serviceCount = @services.nil? ? 0 : @services.keys.size
		@serviceBrowser.setTitle_ofColumn("Service Type (#{serviceCount})", 0)
		@serviceBrowser.needsDisplay
		begin
			result = @proxy.generate_chart_for(@service_type.stringValue, services)
			if result == true
				@imageField.setObjectValue(OSX::NSImage.alloc.initWithContentsOfFile("/tmp/topology.png"))
			else
				showError("error returned back from graphviz-server, check server logs.")
			end
		rescue => e
			puts "update_ui_ERROR: #{e.inspect}"
			showError("ERR02RDRW: #{e.inspect}")
		end
	end
	
	# browser builder method
	def browser_createRowsForColumn_inMatrix(browser, column, matrix)
		puts "->createRowsForColumn(#{column}) (services:#{@services})"
		if @services != nil && column == 1
			@services.keys.each {|k| matrix.addRow } # add enough rows for the results
		elsif @services != nil && column == 2
			serverIndex = @serviceBrowser.selectedRowInColumn(1)
			@services.values[serverIndex].text_record.each {|t| matrix.addRow } # add rows for the txt_records
		elsif @services != nil && column == 2
			serverIndex = @serviceBrowser.selectedRowInColumn(1)
			matrix.addRow if @services.values[serverIndex].text_record # adds a row for the value if the text_record exists
		else
			matrix.addRow
		end
	end
	
	# browser builder method
	def browser_willDisplayCell_atRow_column(browser, cell, row, column)
		puts "->willDisplayCell(#{column}, #{row})"
		if (column == 0)
			cell.stringValue = @service_type.stringValue
		elsif (@services != nil)
			if (column == 1)
				cell.stringValue = @services.keys[row]
				puts "txt_record: #{@services.values[row].text_record}"
				cell.setLeaf(0) unless @services.values[row].text_record.size > 0
			elsif (column == 2)
				serverIndex = @serviceBrowser.selectedRowInColumn(1)
				text_record = @services.values[serverIndex].text_record
				cell.stringValue = text_record.keys[row] if text_record
			elsif (column == 3)
				serverIndex = @serviceBrowser.selectedRowInColumn(1)
				txtIndex = @serviceBrowser.selectedRowInColumn(2)
				text_record = @services.values[serverIndex].text_record
				cell.stringValue = (text_record && text_record.values[txtIndex]) ? text_record.values[txtIndex] : "(nil)"
				cell.setLeaf(0)
			end
		else
			cell.stringValue = "none"
			cell.setLeaf(0)
		end
	end

end
