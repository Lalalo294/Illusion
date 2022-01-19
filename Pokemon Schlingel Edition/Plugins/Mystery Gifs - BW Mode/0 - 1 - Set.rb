module MGBW
	@@list = {}

	def self.error(error=nil)
		p error
		Kernel.exit!
	end

	def self.caution
		error = false
		@@list.each { |k, _|
			w = "You need to set #{k} of value @@value in module MGBW"
			if USE_PE
				next unless k.is_a?(Numeric)
				next if k < LIMIT_CODE
				echoln "#{w} is number less than #{LIMIT_CODE}"
				error = true
			else
				next if k.to_s.length <= LIMIT_LENGTH
				echoln "#{w} has length less than or equal to #{LIMIT_LENGTH}"
				error = true
			end
		}
		return error
	end

	def self.r_list = @@list
end