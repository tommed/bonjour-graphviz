require 'singleton'
require 'gconf2'
require 'digest/md5'

module GNB
	class ConfigController
		include Singleton

		def initialize
			@client = GConf::Client.new
		end
	
		def get_for(hash)
			result = @client["/apps/gnb-network_browser/#{hash}"]
			puts "result for <#{hash}> = #{result}"
			return result
		end

		def set_for(hash, str_value)
			raise 'InvalidStrValue for Config' unless str_value.is_a?(String)
			puts "setting value for <#{hash}> = #{str_value}"
			@client["/apps/gnb-network_browser/#{hash}"] = str_value
		end

		def get_hash(meta)
			return Digest::MD5.hexdigest(meta.name+meta.domain)
		end

	end
end
