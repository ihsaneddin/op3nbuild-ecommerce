module Tracking
	module Tracked
		extend ActiveSupport::Concern

		included do 
			has_many :tracks
		end

	end
end