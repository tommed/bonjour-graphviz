#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'
require 'lib/app/window_controller'

class InterfaceGlade
  include GetText

  attr :glade, :service_browser
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
		@windowController = GNB::WindowController.new(@glade)
  end
  
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "lib/glade/interface.glade"
  PROG_NAME = "Network Browser"
  InterfaceGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
