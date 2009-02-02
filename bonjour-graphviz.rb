#!/usr/bin/env ruby
# =============================
# This is a working prototype which contains snippets of code which will be used in the main application.
#   - The top thread represents the BonjourReceiverService
#   - The second part represents the GraphVizRendererService
# =============================

require 'graphviz'
require 'dnssd'

$serviceType = ARGV.length > 0 ? ARGV[0] : "_device-info._tcp"
$requires_redraw = true
$servers = Hash.new
$roles = Hash.new # use hash for quick access

t = Thread.start do
	DNSSD.browse($serviceType) do |reply|
		begin
			if reply.flags.to_i & DNSSD::Flags::Add != 0
				DNSSD.resolve(reply.name, reply.type, reply.domain) do |d| 
					$servers[reply.name] = d
					d.text_record["role"].split(',').each {|role| $roles[role] = true } if d.text_record.key?("role")
				end
			else
				$servers.delete(reply.name) if $servers.key?(reply.name)
			end
			$requires_redraw = true
		rescue => e
			puts "ERROR: #{e}"
		end
	end
end

while (true) do
	if $requires_redraw
		$requires_redraw = false
		puts "Redrawing Graph.."
		g = GraphViz::new("structs", :type => 'digraph')
		g[:rankdir] = "LR"
		g.graph[:label]="Browsing: #{$serviceType}"
		g.node[:color]="#294b76"
		g.node[:style]="rounded"
		g.node[:shape]="box"
		g.node[:fontname]="Trebuchet MS"
		# draw role nodes
		groles = Hash.new
		$roles.keys.each do |role_k|
			role_node = g.add_node(role_k)
			role_node.label = role_k
			role_node.fillcolor = "#116611"
			role_node.style="dotted"
			role_node.fontcolor = "#111166"
			groles[role_k] = role_node
		end
		# draw servers
		$servers.keys.each_with_index do |k,i| 
			server_node = g.add_node(i.to_s)
			server_node.label = k.gsub("\"", "")
			$servers[k].text_record["role"].split(',').each {|role| g.add_edge(server_node, groles[role]) } if $servers[k].text_record.key?("role")
		end
		g.output(:output => "dot", :file => "~/Desktop/example.rb.dot")
		g.output(:output => "png", :file => "~/Desktop/example.rb.dot.png")
	end
	sleep 2
end
t.join