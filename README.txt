AUTHOR: Tom Medhurst (tom.medhurst@gmail.com)
DESCRIPTION: Allows you to generate graphviz-graphs from Bonjour output

REQUIREMENTS
 1. A Mac (although I have got this working on Ubuntu.. details to follow!)
 2. Graphviz (sudo port install graphviz)
 3. Ruby
 4. ruby-graphviz (sudo gem install ruby-graphviz)
 5. dnssd (sudo gem install dnssd)

EXAMPLES
 ruby ./bonjour-graphviz.rb # generates a .dot and .png file for _device-info._tcp
 ruby ./bonjour-graphviz.rb "_http._tcp" # generate a .dot and .png file for _http._tcp


EXTENDING BONJOUR _device-info._tcp
	Inside the ./device-info/ directory is a bonjour config file for a particular platform. 
	This extends the standard _device-info._tcp service to include useful info like: roles, owner, etc.. 
	
	INSTALL ON MAC
		1. Edit the bonjour script file for your device
		2. To install, copy (or link) the bonjour script AND the plist into the 
		   /Library/LaunchDaemons directory and either reboot or type in: 
		   "sudo launchctl load PLIST_FILEPATH".
		3. Now run bonjour-graphviz.rb without any arguments to see a role mapping graph
		
RUNNING THE CLIENT (Mac)
 1. Open a new terminal console
 2. Run `chomod +x PATH_TO_BONJOUR_GRAPHVIZ_SRC/gui-tools/mac/ZeroConfNetworkBrowser/GraphVizServer.rb`
 3. Run `ruby PATH_TO_BONJOUR_GRAPHVIZ_SRC/gui-tools/mac/ZeroConfNetworkBrowser/GraphVizServer.rb`
 4. Open, Build, and Run the XCode-Project