module Trackings
	module Trackable
		extend ActiveSupport::Concern

		included do 
			class_attribute :trackable_resource_name
		end

		module ClassMethods
			def track! options= { except: [:index] }
				around_action :track, options
			end
		end

		protected

			def track 
				if trackable_resource.respond_to? :tracks
					trackable_resource.last_updated_by= current_user if respond_to?(:current_user) and trackable_resource.respond_to?(:last_updated_by)
				end
				yield
			end

			def trackable_resource
				track_resource_name = self.class.trackable_resource_name
				if trackable_resource_name
					instance_variable_get("@#{self.class.trackable_resource_name}")
				end
			end

	end
end