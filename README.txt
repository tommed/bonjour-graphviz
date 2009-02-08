AUTHOR: Tom Medhurst (tom.medhurst@gmail.com)
DESCRIPTION: Scan your network in less than a second and draws the topology out so you can connect quickly to any TCP-based device

EXTENDING BONJOUR _device-info._tcp
	Inside the ./device-info/ directory is a bonjour config file for a particular platform. 
	This extends the standard _device-info._tcp service to include useful info like: roles, owner, etc.. 
	
	INSTALL ON MAC
		1. Edit the bonjour script file for your device
		2. To install, copy (or link) the bonjour script AND the plist into the 
		   /Library/LaunchDaemons directory and either reboot or type in: 
		   "sudo launchctl load PLIST_FILEPATH".
		3. Now run "ruby test/mac/test.rb" to test your installation

	INSTALL ON UBUNTU
	  1. Edit the device-info.service file and add details specific to your machine
		2. Copy it into /etc/avahi/services/
		3. sudo /etc/init.d/avahi-daemon restart
		4. check for errors: tail -n 30 /var/log/daemon.log
		5. Read the instructions below, to learn how to run the Ubuntu client
		
RUNNING THE CLIENT (Mac)
 1. Open a new terminal console
 2. Run `chomod +x PATH_TO_BONJOUR_GRAPHVIZ_SRC/gui-tools/mac/ZeroConfNetworkBrowser/GraphVizServer.rb`
 3. Run `ruby PATH_TO_BONJOUR_GRAPHVIZ_SRC/gui-tools/mac/ZeroConfNetworkBrowser/GraphVizServer.rb`
 4. Open, Build, and Run the XCode-Project

RUNNING THE CLIENT (Ubuntu)
 1. Make sure you have installed: avahi-daemon, avahi-utils, libavahi-compat-libdnssd1, libavahi-compat-libdnssd-dev, ruby1.8, rubygems, ruby-gnome2, glade3, and glade-gnome-3
 2. Open a new terminal
 3. cd PATH_TO_SRC/gui-tools/ubuntu/
 4. sudo gem install ./prereqs/dnssd-0.6.0_linux.gem
 5. chmod +x ./run
 6. Add PATH_TO_SRV/gui-tools/ubuntu/run to your menu as an Application (*NOT* with terminal)
 7. Browse to this menu item and click it (switch to Application with Terminal if you need to debug)
