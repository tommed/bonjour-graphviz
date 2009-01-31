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