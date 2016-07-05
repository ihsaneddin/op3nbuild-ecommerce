module Openbuild
	module OpenbuildInitInstance
		extend ActiveSupport::Concern
		included do 
			class_attribute :init_instance
			before_action :init, only: [:index]
		end

		protected

		def init
			if params[:init].present?
				render json: init_instance.column_names.to_json, status: 200
			end
		end

		def init_instance
			if self.class.init_instance.nil?
				begin
					self.class.init_instance = controller_name.singularize.capitalize.constantize
				rescue => e
					render json: {error: "Undefined class"}.to_json, status: 404
				end
			end
			return self.class.init_instance
		end
	end

end