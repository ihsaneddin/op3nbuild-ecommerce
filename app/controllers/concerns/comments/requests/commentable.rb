module Comments 
	module Requests
		module Commentable
			extend ActiveSupport::Concern

			included do 
				helper_method :commentable
				before_action :commentable
			end

			protected

				def requests_comment_params
					params.require(:requests_comment).permit(:note)
				end

				def context
				  @context ||= %w(credits withdraws refunds).find {|p| request.path.split('/').include? p }
				end

				def context_class
				  "Requests::#{context.classify}".constantize
				end

				def commentable
					begin
				  	@commentable ||= context_class.find(params["#{context_class.name.demodulize.downcase}_id"])
					rescue => e
						raise ActiveRecord::RecordNotFound
					end
				end
		end
	end
end