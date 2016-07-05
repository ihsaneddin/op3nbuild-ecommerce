module Tracking
	module Trackable
		extend ActiveSupport::Concern

		included do 
			has_many :tracks, as: :trackable
			
			attr_accessor :last_updated_by

			before_save :tracked!
		end

		module ClassMethods

			def trackable_object_last_updated_by trackable_obj 
				where(trackable_type: trackable_obj.class.name, trackable_id: trackable_obj.id).order("created_at DESC").limit(1).first
			end

		end

		def last_changes_by
			tracks.order("created_at DESC").limit(1).first.try(:user)
		end

		protected

			def tracked!
				if self.last_updated_by.present?
					new_track = tracks.new
					self.last_updated_by = User.find last_updated_by if last_updated_by.is_a?(Integer) rescue nil
					if last_updated_by.is_a? User
						new_track.user = self.last_updated_by
						new_track.save
					end
				end
			end

	end
end