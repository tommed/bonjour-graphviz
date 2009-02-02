#
#  GraphVizProxy.rb
#  RubyCocoa
#
#  Created by Tom Medhurst on 31/01/2009.
#  Copyright (c) 2009 Tom Medhurst. All rights reserved.
#

require 'osx/cocoa'
require 'drb'
require 'singleton'

class GraphVizProxy
	attr_accessor :proxy, :is_ready
	
	# async ctor
	def initialize
		@proxy = DRb.start_service
	end
	
	# generate the chart
	def generate_chart_for(service_type, servers)
		begin
			servers_hash = Hash.new 
			servers.keys.each do |k| 
				s = servers[k]
				servers_hash[k] = {:name => s.name, :type => s.type, :text_record=>Hash.new, :roles => Hash.new, :port => s.port, :target => s.target }
				servers_hash[k][:roles] = (s.text_record["role"].nil? ? "" : s.text_record["role"].split(','))
			end
			File.open("/tmp/servers.yaml", 'w') {|f| f.puts(servers_hash.to_yaml) }
			graphVizServer = DRbObject.new(nil, "druby://localhost:9000")
			result = graphVizServer.generate_chart
			return result
		rescue => e
			puts "error calling server #{e.inspect}"
		end
	end
	
end
