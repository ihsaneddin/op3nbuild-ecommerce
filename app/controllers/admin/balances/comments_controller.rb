class Admin::Balances::CommentsController < Admin::BalancesController

	include Comments::Requests::Commentable

	def index
		@comments= comments_for(commentable).paginate(:page => pagination_page, :per_page => pagination_rows)
	end

	def create
		comment = commentable.comments.new requests_comment_params
		comment.user= current_user
		comment.author= current_user
		if comment.save
			respond_to do |f|
				f.html { redirect_to :back, :notice => "Comment created." }
			end
		else
			respond_to do |f|
				f.html { redirect_to :back, :notice => "Comment can not be created." }
			end
		end
	end
	
end