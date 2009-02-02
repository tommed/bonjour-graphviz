#
#  GraphVizServer.rb
#  RubyCocoa
#
#  Created by Tom Medhurst on 31/01/2009.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#
require 'yaml'
require 'drb'
require 'dnssd'
require 'graphviz'

class GraphVizServer
	def generate_chart #(service_type=nil)
		begin
			my_servers = YAML::load_file("/tmp/servers.yaml")
			unless my_servers
				puts "ERROR: YAML load failed"
				return
			end
			g = GraphViz::new("structs", :type => 'digraph')
			g.graph[:bgcolor]="#AAAAAA"
			# draw role nodes
			groles = Hash.new # hash as we need only unique role names
			my_servers.values.each do |s| 
				s[:roles].each {|r| groles[r] = true }
			end
			groles.keys.each do |role|
				role_node = g.add_node(role)
				role_node.label = role
				role_node.shape="note"
				groles[role] = role_node
			end
			# draw servers
			my_servers.keys.each_with_index do |k,i| 
				server_node = g.add_node(i.to_s)
				server_node[:rankdir]="TB"
				server_node[:shape]="record"
				server_node[:bgcolor]="#AAFF77"
				server_node[:style]="rounded,filled"
				name = k.gsub("\"", "").gsub(' ', '\ ').gsub('|', '') # encode name so it doesn't break the dot file
				server_node.label = "{ #{name} | #{my_servers[k][:target]} }"
				my_servers[k][:roles].each {|role| g.add_edge(server_node, groles[role]) } 
			end
			g.output(:output => "dot", :file => "/tmp/topology.dot")
			g.output(:output => "png", :file => "/tmp/topology.png")
			return true # passed
		rescue => e
			puts "ERROR: #{e.inspect}"
			return false
		end
	end
end

# don't start this server as part of the Mac application
if __FILE__ == "GraphVizServer.rb"
	puts "Starting server..."
	DRb.start_service('druby://localhost:9000', GraphVizServer.new)
	puts "Server started."
	DRb.thread.join
end