module Requests
	module Eligible
		extend ActiveSupport::Concern

		def is_eligible_to_be_processed?
			raise NotImplementedError.new("You must implement #{__method}.")	
		end

	end
end